#!/usr/bin/env python
#-*- coding: UTF-8 -*-
'''network stream genertor Tools,for RF testing 

   ps: XiaoFish is a little cat, bless her.  
'''
import os,os.path
import traceback

from robot.api import logger
from robot.version import get_version
from scapy.all import *

__version__ = '0.1'
__author__ = 'liuleic'
__copyright__ = 'Copyright 2014, DigitalChina Network'
__license__ = 'Apache License, Version 2.0'
__mail__ = 'liuleic@digitalchina.com'


class PacketBase(object):
    '''
    define build packet method,used by ixia and xfsend
    '''
    def __init__(self):
        ''''''
        self._pkt_streamlist_hexstring = []
        self._packetList = []
        self._packetField = []
        # ixia para
        self._ixia_flag = False
        self._ixia_packetField = []
        self._ixia_vlan_flag = 0
        self._ixia_vlan_cmd = []
        self._ixia_write_cmd = []
        self._ixia_packet_cmd = []
        self._ixia_frameType = None
        self._ixia_ipProto_flag = 0
        self._ixia_ipv6Proto_flag = 0
        self._ixia_ipProto = 0
        self._ixia_ipv6Proto = 0
        self._ixia_etherType = 0
        self._ixia_ipv6_icmpv6_mld_flag = 0
        self._ixia_mld_kwargs_flag = 0
        self._ixia_mld_kwargs_detail = None
        self._ixia_ipv6_icmpv6_echo_flag = 0
        self._packet_scapy_length = 0
        # pktgen para
        self._pktgen_flag = False
        self._pktgen_packetField = []
        self._pktgen_vlan_flag = 0
        self._pktgen_packet_cmd = None

    def _set_ixia_flag(self,flag):
        old = self._ixia_flag
        self._ixia_flag = flag
        return old

    def _set_pktgen_flag(self,flag):
        old = self._pktgen_flag
        self._pktgen_flag = flag
        return old

    def _get_stream_from_pcapfile(self,filename):
        '''read pcap file and return bytes stream'''
        if not os.path.isfile(filename):
            logger.info('%s is not a file' % filename)
            raise AssertionError('%s is not file or path error' % filename)
        with open(filename,'rb') as handle:
            return handle.read()

    def get_packet_list(self,ixiaFlag=False):
        if ixiaFlag:
            ixia_packetStr = ''
            if self._packetList:
                cmd = 'p=' + self._packetList[0]
                exec(cmd)
                ipstr = hexstr(str(p),0,1)
                ixia_packetStr = '#'.join(ipstr.split())
            return ixia_packetStr
        else:
            return self._packetList

    def get_packet_list_ixiaapi(self):
        if self._ixia_flag:
            return self._ixia_packet_cmd
        else:
            return ""

    def get_packet_cmd_pktgen(self):
        """
        """
        if self._pktgen_flag:
            return self._pktgen_packet_cmd
        else:
            return ""

    def empty_packet_list(self):
        self._packetList = []
        if self._ixia_flag:
            self._ixia_packet_cmd = ""
        elif self._pktgen_flag:
            self._pktgen_packet_cmd = ""

    def _build_stream(self):
        ''''''
        self._pkt_streamlist_hexstring = self._packetList
        self._packetList = []
        return self._pkt_streamlist_hexstring

    def build_packet(self,length=128,packetstr=None):
        '''
        build previous layers to a packet

        args:
        length: packet length; it will automatically complete by 00
        packetstr: if packetstr is filled, packet will be used packetstr to build rather than previous layers
        '''
        if packetstr:
            cmd = packetstr
        else:
            self._build_payload(length)
            pktstr = '/'.join(self._packetField)
            cmd = pktstr
            scapy_length = self._packet_scapy_length
        self._packetList.append(cmd)
        self._packetField = []
        self._packet_scapy_length = 0
        if self._ixia_flag and not packetstr:
            #add icmpv6 mld
            if self._ixia_ipv6_icmpv6_mld_flag:
                self._create_ixia_ipv6_icmpv6_mld(cmd,scapy_length)
            #add icmpv6 echo
            if self._ixia_ipv6_icmpv6_echo_flag:
                self._create_ixia_ipv6_icmpv6_echo(cmd,scapy_length)
            #add framLength
            self._ixia_packetField[0] += '!stream config -frameSizeType sizeFixed!stream config -framesize %s!stream config -frameSizeMIN %s!stream config -frameSizeMAX %s' % (length,length,length)
            #add frameType
            if self._ixia_frameType:
                typeidstr = "%04X" % self._ixia_frameType
                types = '%s %s' % (typeidstr[0:2],typeidstr[2:4])
                self._ixia_packetField[0] += '!stream config -frameType "%s"' % types
            #add 'protocol setDefault'
            self._ixia_packetField[0] += '!protocol setDefault'
            if self._ixia_etherType == 1:
                self._ixia_packetField[0] += '!protocol config -ethernetType ethernetII'
            if self._ixia_vlan_flag == 1:
                self._ixia_packetField[0] += '!protocol config -enable802dot1qTag vlanSingle'
            elif self._ixia_vlan_flag > 1:
                self._ixia_packetField[0] += '!protocol config -enable802dot1qTag vlanStacked'
            #add ip proto
            if self._ixia_ipProto_flag:
                protostr = '!ip config -ipProtocol %s' % self._ixia_ipProto
                ipmatchre = re.compile(r'ip config -')
                istrlen = 0
                for istr in self._ixia_packetField:
                    if ipmatchre.search(istr):
                        self._ixia_packetField[istrlen] += protostr
                        break
                    istrlen += 1
            #add ipv6 next header
            if self._ixia_ipv6Proto_flag:
                protostr = '!ipV6 config -nextHeader %s' % self._ixia_ipv6Proto
                ipmatchre = re.compile(r'ipV6 config -')
                iv6strlen = 0
                for istr in self._ixia_packetField:
                    if ipmatchre.search(istr):
                        self._ixia_packetField[iv6strlen] += protostr
                        break
                    iv6strlen += 1
            #add vlan
            if self._ixia_vlan_flag > 0:
                if self._ixia_vlan_flag == 1:
                    self._ixia_packetField.append(self._ixia_vlan_cmd[0])
                    self._ixia_write_cmd.append("vlan set")
                else:
                    cmdlist = []
                    cmdlist.append("stackedVlan setDefault")
                    i = 1
                    for icmd in self._ixia_vlan_cmd:
                        cmdlist.append(icmd)
                        cmdlist.append("stackedVlan setVlan %s" % i)
                        i += 1
                    vlancmd = '!'.join(cmdlist)
                    self._ixia_packetField.append(vlancmd)
                    self._ixia_write_cmd.append("stackedVlan set")
                self._ixia_vlan_flag = 0
                self._ixia_vlan_cmd = []
            #join ixia cmd
            xcmd = '@'.join(self._ixia_packetField)
            ycmd = '@'.join(self._ixia_write_cmd)
            self._ixia_packet_cmd = xcmd + '$' + ycmd
            self._reset_ixia_parameter()
        elif self._pktgen_flag:
            cmdlist = []
            cmdlist.append("pkt_size %s" % length)
            cmdstr = '!'.join(cmdlist)
            self._pktgen_packetField.append(cmdstr)
            self._pktgen_packet_cmd = "@".join(self._pktgen_packetField)
            self._reset_pktgen_parameter()
        return 0

    def _reset_pktgen_parameter(self):
        """
        """
        self._pktgen_packetField = []
        self._pktgen_vlan_flag = 0

    def _reset_ixia_parameter(self):
        '''
        '''
        self._ixia_packetField = []
        self._ixia_write_cmd = []
        self._ixia_frameType = None
        self._ixia_ipProto_flag = 0
        self._ixia_ipv6Proto_flag = 0
        self._ixia_ipProto = 0
        self._ixia_ipv6Proto = 0
        self._ixia_etherType = 0
        self._ixia_ipv6_icmpv6_mld_flag = 0
        self._ixia_mld_kwargs_detail = None
        self._ixia_mld_kwargs_flag = 0
        self._ixia_ipv6_icmpv6_echo_flag = 0

    def build_ether(self,dst='ff:ff:ff:ff:ff:ff',src='00:00:00:00:00:00',typeid=None,kwargs=None):
        '''build Ethernet field packet

           args:
           - dst    : Dest Mac    = ff:ff:ff:ff:ff:ff
           - src    : Source Mac  = 00:00:00:00:00:00
           - typeid : type        = None

           return:
           packet field length

           exapmle:
           | Build Ether | dst=00:00:00:00:00:01 | src=00:00:00:00:00:02 |
           | Build Ether | src=00:00:00:00:00:02 |
           | Build Ether | dst=00:00:00:00:00:02 |
        '''
        dstlist = dst.split('-')
        dst = ':'.join(dstlist)
        srclist = src.split('-')
        src = ':'.join(srclist)
        if issubclass(type(typeid),basestring):
            if typeid.startswith('0x'):
                typeid = int(typeid,16)
            else:
                typeid = int(typeid)
        if typeid:
            cmd = "Ether(dst='%s', src='%s', type=%#x)" % (dst,src,typeid)
        else:
            cmd = "Ether(dst='%s', src='%s')" % (dst,src)
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_ether_ixia(dst,src,typeid,kwargs)
            elif self._pktgen_flag:
                self._build_ether_pktgen(dst,src,typeid,kwargs)
            return len(p)

    def _build_ether_pktgen(self,dst,src,typeid,kwargs):
        """
        """
        cmdlist = []
        cmdlist.append("dstmac %s" % dst)
        cmdlist.append("srcmac %s" % src)
        if kwargs and "src_mac_count" in kwargs.keys():
            cmdlist.append("src_mac_count %s" % kwargs["src_mac_count"])
        if kwargs and "dst_mac_count" in kwargs.keys():
            cmdlist.append("dst_mac_count %s" % kwargs["dst_mac_count"])
        cmd = '!'.join(cmdlist)
        self._pktgen_packetField.append(cmd)
        return True

    def _build_ether_ixia(self,dst,src,typeid,kwargs):
        '''
        '''
        cmdlist = []
        dstlist = dst.split(':')
        dst = ' '.join(dstlist)
        srclist = src.split(':')
        src = ' '.join(srclist)
        if typeid:
            # _ixia_etherType = 1 : ethernetII
            self._ixia_etherType = 1
        #src mac config
        cmdlist.append('stream config -sa "%s"' % src)
        if kwargs and 'saRepeatCounter' in kwargs.keys():
            cmdlist.append('stream config -saRepeatCounter %s' % kwargs['saRepeatCounter'])
        if kwargs and 'numSA' in kwargs.keys():
            cmdlist.append('stream config -numSA %s' % kwargs['numSA'])
        if kwargs and 'saStep' in kwargs.keys():
            cmdlist.append('stream config -saStep %s' % kwargs['saStep'])
        if kwargs and 'saMaskValue' in kwargs.keys():
            cmdlist.append('stream config -saMaskValue "%s"' % kwargs['saMaskValue'])
        if kwargs and 'saMaskSelect' in kwargs.keys():
            cmdlist.append('stream config -saMaskSelect "%s"' % kwargs['saMaskSelect'])
        #dst mac config
        cmdlist.append('stream config -da "%s"' % dst)
        if kwargs and 'daRepeatCounter' in kwargs.keys():
            cmdlist.append('stream config -daRepeatCounter %s' % kwargs['daRepeatCounter'])
        if kwargs and 'numDA' in kwargs.keys():
            cmdlist.append('stream config -numDA %s' % kwargs['numDA'])
        if kwargs and 'daStep' in kwargs.keys():
            cmdlist.append('stream config -daStep %s' % kwargs['daStep'])
        if kwargs and 'daMaskValue' in kwargs.keys():
            cmdlist.append('stream config -daMaskValue "%s"' % kwargs['daMaskValue'])
        if kwargs and 'daMaskSelect' in kwargs.keys():
            cmdlist.append('stream config -daMaskSelect "%s"' % kwargs['daMaskSelect'])
        #frameType
        cmdlist.append('stream config -patternType nonRepeat')
        cmdlist.append('stream config -dataPattern allZeroes')
        cmdlist.append('stream config -pattern "00 00"')
        #cmdlist.append('protocol setDefault')
        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("none")
        return True

    def build_arp(self,hwtype=0x1,ptype=0x800,hwlen=6,plen=4,op=1,hwsrc='00:00:00:00:00:00',psrc='0.0.0.0',hwdst='00:00:00:00:00:00',pdst='0.0.0.0',kwargs=None):
        '''build arp field packet

           args:
           - hwtype = 0x1
           - ptype  = 0x800
           - hwlen  = 6
           - plen   = 4
           - op     = 1
           - hwsrc  = 00:00:00:00:00:00
           - psrc   = 0.0.0.0
           - hwdst  = 00:00:00:00:00:00
           - pdst   = 0.0.0.0

           return:
           packet field length

           exapmle:
           | Build Arp | hwsrc=00:00:00:00:00:01 | psrc=10.1.1.1 | hwdst=10.1.1.254 |
           | Build Arp | op=${2} | hwsrc=00:00:00:00:00:02 | psrc=10.1.1.254 | pdst=10.1.1.1 |
        '''
        hwsrclist = hwsrc.split('-')
        hwsrc = ':'.join(hwsrclist)
        hwdstlist = hwdst.split('-')
        hwdst = ':'.join(hwdstlist)
        if issubclass(type(hwtype),basestring):
            if hwtype.startswith('0x'):
                hwtype = int(hwtype,16)
            else:
                hwtype = int(hwtype)
        if issubclass(type(ptype),basestring):
            if ptype.startswith('0x'):
                ptype = int(ptype,16)
            else:
                ptype = int(ptype)
        if issubclass(type(hwlen),basestring):
            if hwlen.startswith('0x'):
                hwlen = int(hwlen,16)
            else:
                hwlen = int(hwlen)
        if issubclass(type(plen),basestring):
            if plen.startswith('0x'):
                plen = int(plen,16)
            else:
                plen = int(plen)
        if issubclass(type(op),basestring):
            if op.startswith('0x'):
                op = int(op,16)
            else:
                op = int(op)
        cmd = "ARP(hwtype=%#x,ptype=%#x,hwlen=%i,plen=%i,op=%i,hwsrc='%s', psrc='%s', hwdst='%s', pdst='%s')" % (hwtype,ptype,hwlen,plen,op,hwsrc,psrc,hwdst,pdst)
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_arp_ixia(op,hwsrc,psrc,hwdst,pdst,kwargs)
            return len(p)

    def _build_arp_ixia(self,op,hwsrc,psrc,hwdst,pdst,kwargs):
        '''
        '''
        cmdlist = []
        dstlist = hwdst.split(':')
        hwdst = ' '.join(dstlist)
        srclist = hwsrc.split(':')
        hwsrc = ' '.join(srclist)
        #config protocol
        #cmdlist.append('protocol setDefault')
        cmdlist.append('protocol config -appName Arp')
        cmdlist.append('protocol config -ethernetType ethernetII')
        #config arp
        cmdlist.append('arp setDefault')
        cmdlist.append('arp config -sourceProtocolAddr "%s"' % psrc)
        cmdlist.append('arp config -destProtocolAddr "%s"' % pdst)
        cmdlist.append('arp config -operation %s' % op)
        cmdlist.append('arp config -sourceHardwareAddr "%s"' % hwsrc)
        cmdlist.append('arp config -destHardwareAddr "%s"' % hwdst)
        if kwargs and 'destHardwareAddrMode' in kwargs.keys():
            cmdlist.append('arp config -destHardwareAddrMode %s' % kwargs['destHardwareAddrMode'])
        if kwargs and 'destProtocolAddrMode' in kwargs.keys():
            cmdlist.append('arp config -destProtocolAddrMode %s' % kwargs['destProtocolAddrMode'])
        if kwargs and 'sourceHardwareAddrMode' in kwargs.keys():
            cmdlist.append('arp config -sourceHardwareAddrMode %s' % kwargs['sourceHardwareAddrMode'])
        if kwargs and 'sourceProtocolAddrMode' in kwargs.keys():
            cmdlist.append('arp config -sourceProtocolAddrMode %s' % kwargs['sourceProtocolAddrMode'])
        if kwargs and 'destProtocolAddrRepeatCount' in kwargs.keys():
            cmdlist.append('arp config -destProtocolAddrRepeatCount %s' % kwargs['destProtocolAddrRepeatCount'])
        else:
            cmdlist.append('arp config -destProtocolAddrRepeatCount 1')
        if kwargs and 'sourceProtocolAddrRepeatCount' in kwargs.keys():
            cmdlist.append('arp config -sourceProtocolAddrRepeatCount %s' % kwargs['sourceProtocolAddrRepeatCount'])
        else:
            cmdlist.append('arp config -sourceProtocolAddrRepeatCount 1')
        if kwargs and 'sourceHardwareAddrRepeatCount' in kwargs.keys():
            cmdlist.append('arp config -sourceHardwareAddrRepeatCount %s' % kwargs['sourceHardwareAddrRepeatCount'])
        else:
            cmdlist.append('arp config -sourceHardwareAddrRepeatCount 1')
        if kwargs and 'destHardwareAddrRepeatCount' in kwargs.keys():
            cmdlist.append('arp config -destHardwareAddrRepeatCount %s' % kwargs['destHardwareAddrRepeatCount'])
        else:
            cmdlist.append('arp config -destHardwareAddrRepeatCount 1')
        ##########arp set $chassid $port $card
        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("arp set")
        return True


    def build_ip(self,version=4,ihl=None,tos=0x0,iplen=None,iden=0,flags=0,frag=0,ttl=64,proto=None,chksum=None,src='0.0.0.0',dst='0.0.0.0',options=None,kwargs=None):
        '''build ip field packet

           args:
           - version = 4
           - ihl     = None
           - tos     = 0x0
           - iplen   = None
           - iden    = 0
           - flags   = 0
           - frag    = 0
           - ttl     = 64
           - proto   = None
           - chksum  = None
           - src     = 0.0.0.0
           - dst     = 0.0.0.0
           - options = None  #packets list

           return:
           packet field length

           exapmle:
           | Build Ip | src=10.1.1.1 | dst=10.1.1.254 |
        '''
        if issubclass(type(version),basestring):
            if version.startswith('0x'):
                version = int(version,16)
            else:
                version = int(version)
        if issubclass(type(tos),basestring):
            if tos.startswith('0x'):
                tos = int(tos,16)
            else:
                tos = int(tos)
        if issubclass(type(iden),basestring):
            if iden.startswith('0x'):
                iden = int(iden,16)
            else:
                iden = int(iden)
        if issubclass(type(flags),basestring):
            if flags.startswith('0x'):
                flags = int(flags,16)
            else:
                flags = int(flags)
        if issubclass(type(frag),basestring):
            if frag.startswith('0x'):
                frag = int(frag,16)
            else:
                frag = int(frag)
        if issubclass(type(ttl),basestring):
            if ttl.startswith('0x'):
                ttl = int(ttl,16)
            else:
                ttl = int(ttl)
        if issubclass(type(proto),basestring):
            if proto.startswith('0x'):
                proto = int(proto,16)
            else:
                proto = int(proto)
        if ihl:
            if issubclass(type(ihl),basestring):
                if ihl.startswith('0x'):
                    ihl = int(ihl,16)
                else:
                    ihl = int(ihl)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        if iplen:
            if issubclass(type(iplen),basestring):
                if iplen.startswith('0x'):
                    iplen = int(iplen,16)
                else:
                    iplen = int(iplen)
        if options:
            if issubclass(type(options),basestring):
                if options.startswith('0x'):
                    options = int(options,16)
                else:
                    options = int(options)
        else:
            options = []
        cmd = "IP(version=%i,tos=%#x,flags=%i,frag=%i,ttl=%i,src='%s',dst='%s',id=%i" % (version,tos,flags,frag,ttl,src,dst,iden)
        if ihl:
            cmd += ",ihl=%s" % ihl
        if iplen:
            cmd += ",len=%s" % iplen
        if proto:
            cmd += ",proto=%i" % proto
        if chksum:
            cmd += ",chksum=%#x" % chksum
        if options:
            cmd += ",options=%s" % options
        cmd += ")"
        #cmd = "IP(version=%i,ihl=%s,tos=%#x,len=%s,id=%i,flags=%i,frag=%i,ttl=%i,proto=%i,chksum=%s,src='%s',dst='%s',options=%s)" % (version,ihl,tos,iplen,iden,flags,frag,ttl,proto,chksum,src,dst,options)
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_ip_ixia(ihl,tos,iplen,iden,flags,frag,ttl,proto,chksum,src,dst,options,kwargs)
            elif self._pktgen_flag:
                self._build_ip_pktgen(ihl,tos,iplen,iden,flags,frag,ttl,proto,chksum,src,dst,options,kwargs)
            return len(p)

    def _build_ip_pktgen(self,ihl,tos,iplen,iden,flags,frag,ttl,proto,chksum,src,dst,options,kwargs):
        """
        """
        cmdlist = []
        cmdlist.append("dst_min %s" % dst)
        cmdlist.append("src_min %s" % src)
        if tos:
            cmdlist.append("tos %02X" % tos)
        if kwargs and "src_ip_count" in kwargs.keys():
            import Tools.Tools
            src_max = Tools.Tools.incr_ip(src,int(kwargs["src_ip_count"]))
            cmdlist.append("src_max %s" % src_max)
        if kwargs and "dst_ip_count" in kwargs.keys():
            import Tools.Tools
            dst_max = Tools.Tools.incr_ip(dst,int(kwargs["dst_ip_count"]))
            cmdlist.append("dst_max %s" % dst_max)
        cmd = '!'.join(cmdlist)
        self._pktgen_packetField.append(cmd)
        return True

    def _build_ip_ixia(self,ihl,tos,iplen,iden,flags,frag,ttl,proto,chksum,src,dst,options,kwargs):
        '''
        '''
        cmdlist = []
        #config protocol
        #cmdlist.append('protocol setDefault')
        cmdlist.append('protocol config -name ipV4')
        cmdlist.append('protocol config -appName noType')
        cmdlist.append('protocol config -ethernetType ethernetII')
        #config ip
        cmdlist.append('ip setDefault')
        cmdlist.append('ip config -identifier %s' % iden)
        if iplen:
            cmdlist.append('ip config -totalLength %s' % iplen)
            cmdlist.append('ip config -lengthOverride false')
        cmdlist.append('ip config -ttl %s' % ttl)
        if flags == 1:
            cmdlist.append('ip config -fragment may')
            cmdlist.append('ip config -lastFragment more')
            cmdlist.append('ip config -fragmentOffset %s' % frag)
        elif flags == 2:
            cmdlist.append('ip config -fragment dont')
            cmdlist.append('ip config -lastFragment last')
            cmdlist.append('ip config -fragmentOffset %s' % frag)
        else:
            pass
        if tos:
            ip_reserved = tos & 1
            cmdlist.append('ip config -reserved %i' % ip_reserved)
            ip_cost = (tos >> 1) & 1
            cmdlist.append('ip config -cost %i' % ip_cost)
            ip_reliability = (tos >> 2) & 1
            cmdlist.append('ip config -reliability %i' % ip_reliability)
            ip_throughput = (tos >> 3) & 1
            cmdlist.append('ip config -throughput %i' % ip_throughput)
            ip_delay = (tos >> 4) & 1
            cmdlist.append('ip config -delay %i' % ip_delay)
            ip_precedence = tos >> 5
            cmdlist.append('ip config -precedence %i' % ip_precedence)
        #cmdlist.append('ip config -ipProtocol %s' % proto)
        self._ixia_ipProto_flag = 1
        if chksum:
            cmdlist.append('ip config -useValidChecksum false')
        cmdlist.append('ip config -sourceIpAddr "%s"' % src)
        if kwargs and 'sourceIpMask' in kwargs.keys():
            cmdlist.append('ip config -sourceIpMask "%s"' % kwargs['sourceIpMask'])
        if kwargs and 'sourceIpAddrMode' in kwargs.keys():
            cmdlist.append('ip config -sourceIpAddrMode "%s"' % kwargs['sourceIpAddrMode'])
        if kwargs and 'sourceIpAddrRepeatCount' in kwargs.keys():
            cmdlist.append('ip config -sourceIpAddrRepeatCount "%s"' % kwargs['sourceIpAddrRepeatCount'])
        if kwargs and 'sourceClass' in kwargs.keys():
            cmdlist.append('ip config -sourceClass "%s"' % kwargs['sourceClass'])
        cmdlist.append('ip config -destIpAddr "%s"' % dst)
        if kwargs and 'destIpMask' in kwargs.keys():
            cmdlist.append('ip config -destIpMask "%s"' % kwargs['destIpMask'])
        if kwargs and 'destIpAddrMode' in kwargs.keys():
            cmdlist.append('ip config -destIpAddrMode "%s"' % kwargs['destIpAddrMode'])
        if kwargs and 'destIpAddrRepeatCount' in kwargs.keys():
            cmdlist.append('ip config -destIpAddrRepeatCount "%s"' % kwargs['destIpAddrRepeatCount'])
        if kwargs and 'destClass' in kwargs.keys():
            cmdlist.append('ip config -destClass "%s"' % kwargs['destClass'])

        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("ip set")
        return True

    def build_icmp(self,typeid=8,code=0,chksum=None,iden=0,seq=0,kwargs=None):
        '''build ICMP field packet

           args:
           - typeid    : type    = 8
           - code      : code    = 0
           - chksum    : chksum  = None
           - iden      ：id      = 0
           - seq       : seq     = 0

           return:
           packet field length

           exapmle:
           | Build Icmp | typeid=0 | code=0 |
           | Build Icmp | typeid=8 |
        '''
        if issubclass(type(typeid),basestring):
            if typeid.startswith('0x'):
                typeid = int(typeid,16)
            else:
                typeid = int(typeid)
        if issubclass(type(code),basestring):
            if code.startswith('0x'):
                code = int(code,16)
            else:
                code = int(code)
        if issubclass(type(iden),basestring):
            if iden.startswith('0x'):
                iden = int(iden,16)
            else:
                iden = int(iden)
        if issubclass(type(seq),basestring):
            if seq.startswith('0x'):
                seq = int(seq,16)
            else:
                seq = int(seq)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        if chksum:
            cmd = "ICMP(type=%i, code=%i, id=%i, seq=%i,chksum=%#x)" % (typeid,code,iden,seq,chksum)
        else:
            cmd = "ICMP(type=%i, code=%i, id=%i, seq=%i)" % (typeid,code,iden,seq)
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_icmp_ixia(typeid,code,chksum,iden,seq,kwargs)
            return len(p)

    def _build_icmp_ixia(self,typeid,code,chksum,iden,seq,kwargs):
        '''
        '''
        cmdlist = []
        #config icmp
        cmdlist.append('icmp setDefault')
        cmdlist.append('icmp config -type %s' % typeid)
        cmdlist.append('icmp config -code %s' % code)
        cmdlist.append('icmp config -id %s' % iden)
        cmdlist.append('icmp config -sequence %s' % seq)
        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("icmp set")
        return True

    def build_igmpv1v2(self,version=0x11,maxres=100,chksum=None,group='0.0.0.0',kwargs=None):
        '''build IGMPv1v2 field packet

           args:
           - version    = 0x11
           - maxres     = 100
           - chksum     = None
           - group      = 0.0.0.0
           - kwargs     = None,the detail spec in the doc of keywrod Make Kwargs

           return:
           packet field length

           exapmle:
           | Build Igmpv1v2 | version=0x16 | group=225.1.1.1 |
        '''
        if issubclass(type(version),basestring):
            if version.startswith('0x'):
                version = int(version,16)
            else:
                version = int(version)
        if issubclass(type(maxres),basestring):
            if maxres.startswith('0x'):
                maxres = int(maxres,16)
            else:
                maxres = int(maxres)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        if chksum:
            cmd = "IGMP(version=%i, maxres=%i, group='%s', chksum=%#x)" % (version,maxres,group,chksum)
        else:
            cmd = "IGMP(version=%i, maxres=%i, group='%s')" % (version,maxres,group)
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_igmpv1v2_ixia(version,maxres,chksum,group,kwargs)
            return len(p)

    def _build_igmpv1v2_ixia(self,version,maxres,chksum,group,kwargs):
        '''
        '''
        cmdlist = []
        #config icmp
        cmdlist.append('igmp setDefault')
        if version == 0x11:
            cmdlist.append('igmp config -type 17')
            #cmdlist.append('igmp config -version 2')
        elif version == 0x12:
            cmdlist.append('igmp config -type 18')
            cmdlist.append('igmp config -version 1')
        elif version == 0x16:
            cmdlist.append('igmp config -type 22')
            cmdlist.append('igmp config -version 2')
        elif version == 0x17:
            cmdlist.append('igmp config -type 23')
            cmdlist.append('igmp config -version 2')
        else:
            pass
        cmdlist.append('igmp config -maxResponseTime %s' % maxres)
        cmdlist.append('igmp config -groupIpAddress "%s"' % group)
        if chksum:
            cmdlist.append('igmp config -useValidChecksum false')
        if kwargs and 'mode' in kwargs.keys():
            cmdlist.append('igmp config -mode %s' % kwargs['mode'])
        if kwargs and 'repeatCount' in kwargs.keys():
            cmdlist.append('igmp config -repeatCount %s' % kwargs['repeatCount'])
        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("igmp set")
        return True

    def build_ipv6(self,version=6,tc=0,fl=0,plen=None,nh=None,hlim=64,src='::1',dst='::1',kwargs=None):
        '''build ipv6 field packet

           args:
           - version = 6
           - tc      = 0;      traffic class
           - fl      = 0;      flow label
           - plen    = None;   payload length
           - nh      = None;   next header,default 59
           - hlim    = 64;     hop limit
           - src     = ::1
           - dst     = ::1

           return:
           packet field length

           exapmle:
           | Build Ipv6 | src=2001::1 | dst=2002::1 |
        '''
        if issubclass(type(version),basestring):
            if version.startswith('0x'):
                version = int(version,16)
            else:
                version = int(version)
        if issubclass(type(tc),basestring):
            if tc.startswith('0x'):
                tc = int(tc,16)
            else:
                tc = int(tc)
        if issubclass(type(fl),basestring):
            if fl.startswith('0x'):
                fl = int(fl,16)
            else:
                fl = int(fl)
        if issubclass(type(hlim),basestring):
            if hlim.startswith('0x'):
                hlim = int(hlim,16)
            else:
                hlim = int(hlim)
        if plen:
            if issubclass(type(plen),basestring):
                if plen.startswith('0x'):
                    plen = int(plen,16)
                else:
                    plen = int(plen)
        if nh:
            if issubclass(type(nh),basestring):
                if nh.startswith('0x'):
                    nh = int(nh,16)
                else:
                    nh = int(nh)
        cmd = "IPv6(version=%i,tc=%i,fl=%i,hlim=%i,src='%s',dst='%s'" % (version,tc,fl,hlim,src,dst)
        if nh:
            cmd += ",nh=%i" % nh
        if plen:
            cmd += ",plen=%i" % plen
        cmd += ")"
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_ipv6_ixia(version,tc,fl,plen,nh,hlim,src,dst,kwargs)
            elif self._pktgen_flag:
                self._build_ipv6_pktgen(version,tc,fl,plen,nh,hlim,src,dst,kwargs)
            return len(p)

    def _build_ipv6_pktgen(self,version,tc,fl,plen,nh,hlim,src,dst,kwargs):
        """
        """
        cmdlist = []
        cmdlist.append("dst6 %s" % dst)
        cmdlist.append("src6 %s" % src)
        if tc:
            cmdlist.append("traffic_class %02X" % tc)
        if kwargs and "src_ipv6_count" in kwargs.keys():
            import Tools.Tools
            src6_max = Tools.Tools.incr_ipv6(src,int(kwargs["src_ipv6_count"]))
            cmdlist.append("src6_max %s" % src6_max)
        if kwargs and "dst_ipv6_count" in kwargs.keys():
            import Tools.Tools
            dst6_max = Tools.Tools.incr_ipv6(dst,int(kwargs["dst_ipv6_count"]))
            cmdlist.append("dst6_max %s" % dst6_max)
        cmd = '!'.join(cmdlist)
        self._pktgen_packetField.append(cmd)
        return True

    def _build_ipv6_ixia(self,version,tc,fl,plen,nh,hlim,src,dst,kwargs):
        '''
        '''
        cmdlist = []
        #config protocol
        #cmdlist.append('protocol setDefault')
        cmdlist.append('protocol config -name ipV6')
        cmdlist.append('protocol config -appName noType')
        cmdlist.append('protocol config -ethernetType ethernetII')
        #config ipv6
        cmdlist.append('ipV6 setDefault')
        cmdlist.append('ipV6 config -trafficClass %i' % tc)
        cmdlist.append('ipV6 config -flowLabel %i' % fl)
        cmdlist.append('ipV6 config -hopLimit %i' % hlim)
        #if plen:
        #    cmdlist.append('ipV6 config -totalLength %s' % iplen)
        #    cmdlist.append('ipV6 config -lengthOverride false')
        if nh:
            cmdlist.append('ipV6 config -nextHeader %i' % nh)
        else:
            self._ixia_ipv6Proto_flag = 1
        cmdlist.append('ipV6 config -sourceAddr "%s"' % src)
        if kwargs and 'sourceMask' in kwargs.keys():
            cmdlist.append('ipV6 config -sourceMask "%s"' % kwargs['sourceMask'])
        if kwargs and 'sourceAddrMode' in kwargs.keys():
            cmdlist.append('ipV6 config -sourceAddrMode "%s"' % kwargs['sourceAddrMode'])
        if kwargs and 'sourceAddrRepeatCount' in kwargs.keys():
            cmdlist.append('ipV6 config -sourceAddrRepeatCount "%s"' % kwargs['sourceAddrRepeatCount'])
        if kwargs and 'sourceStepSize' in kwargs.keys():
            cmdlist.append('ipV6 config -sourceStepSize "%s"' % kwargs['sourceStepSize'])
        cmdlist.append('ipV6 config -destAddr "%s"' % dst)
        if kwargs and 'destMask' in kwargs.keys():
            cmdlist.append('ipV6 config -destMask "%s"' % kwargs['destMask'])
        if kwargs and 'destAddrMode' in kwargs.keys():
            cmdlist.append('ipV6 config -destAddrMode "%s"' % kwargs['destAddrMode'])
        if kwargs and 'destAddrRepeatCount' in kwargs.keys():
            cmdlist.append('ipV6 config -destAddrRepeatCount "%s"' % kwargs['destAddrRepeatCount'])
        if kwargs and 'destStepSize' in kwargs.keys():
            cmdlist.append('ipV6 config -destStepSize "%s"' % kwargs['destStepSize'])

        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("ipV6 set")
        return True

    def build_icmpv6_mldv1_query(self,code=0,chksum=None,mrd=10000,reserved=0,mladdr='::',kwargs=None):
        '''build mldv1 query field packet

           args:
           - code        = 0
           - chksum      = None;
           - mrd         = 10000;      max response delay
           - reserved    = 0;
           - mladdr      = ::

           return:
           packet field length

           exapmle:
           | Build Icmpv6 Mld Query |
        '''
        if issubclass(type(code),basestring):
            if code.startswith('0x'):
                code = int(code,16)
            else:
                code = int(code)
        if issubclass(type(mrd),basestring):
            if mrd.startswith('0x'):
                mrd = int(mrd,16)
            else:
                mrd = int(mrd)
        if issubclass(type(reserved),basestring):
            if reserved.startswith('0x'):
                reserved = int(reserved,16)
            else:
                reserved = int(reserved)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        cmd = "IPv6ExtHdrHopByHop(nh=58,options=RouterAlert())/ICMPv6MLQuery(code=%i,mrd=%i,reserved=%i,mladdr='%s'" % (code,mrd,reserved,mladdr)
        if chksum:
            cmd += ",cksum=%i" % chksum
        cmd += ")"
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_icmpv6_mldv1_query_ixia(code,chksum,mrd,reserved,mladdr,kwargs)
            return len(p)

    def _build_icmpv6_mldv1_query_ixia(self,code,chksum,mrd,reserved,mladdr,kwargs):
        '''
        '''
        cmdlist = []
        #config ipv6 hopbyhop
        cmdlist.append('ipV6 clearAllExtensionHeaders')
        cmdlist.append('ipV6HopByHop clearAllOptions')
        cmdlist.append('ipV6OptionRouterAlert setDefault')
        cmdlist.append('ipV6OptionRouterAlert config -length 2')
        cmdlist.append('ipV6OptionRouterAlert config -routerAlert ipV6RouterAlertMLD')
        cmdlist.append('ipV6HopByHop addOption ipV6OptionRouterAlert')
        cmdlist.append('ipV6OptionPADN setDefault')
        cmdlist.append('ipV6OptionPADN config -length 0')
        cmdlist.append('ipV6OptionPADN config -value ""')
        cmdlist.append('ipV6HopByHop addOption ipV6OptionPADN')
        cmdlist.append('ipV6 addExtensionHeader ipV6HopByHopOptions')
        ipv6HopbyHopCmd = '!'.join(cmdlist)
        #look up for ipv6 config
        ipv6matchre = re.compile(r'ipV6 config -')
        iv6strlen = 0
        for istr in self._ixia_packetField:
            if ipv6matchre.search(istr):
                self._ixia_packetField[iv6strlen] += '!' + ipv6HopbyHopCmd
                break
            iv6strlen += 1
        #stream config -patternType nonRepeat
        #stream config -dataPattern userpattern
        #stream config -pattern $pattern
        self._ixia_ipv6_icmpv6_mld_flag = 1
        cmdlist = []
        mld_kwargs_flag = 0
        mld_kwargs_addrmask = 128
        mld_kwargs_addrmode = 'uuuu'
        mld_kwargs_addrrepeatcount = 1
        mld_kwargs_addrstepsize = 1
        if kwargs and 'AddrMask' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['AddrMask']),basestring):
                if kwargs['AddrMask'].startswith('0x'):
                    mld_kwargs_addrmask = int(kwargs['AddrMask'],16)
                else:
                    mld_kwargs_addrmask = int(kwargs['AddrMask'])
            else:
                mld_kwargs_addrmask = kwargs['AddrMask']
        if kwargs and 'AddrMode' in kwargs.keys():
            mld_kwargs_flag = 1
            mld_kwargs_addrmode = kwargs['AddrMode']
        if kwargs and 'AddrRepeatCount' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['AddrRepeatCount']),basestring):
                if kwargs['AddrRepeatCount'].startswith('0x'):
                    mld_kwargs_addrrepeatcount = int(kwargs['AddrRepeatCount'],16)
                else:
                    mld_kwargs_addrrepeatcount = int(kwargs['AddrRepeatCount'])
            else:
                mld_kwargs_addrrepeatcount = kwargs['AddrRepeatCount']
        if kwargs and 'StepSize' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['StepSize']),basestring):
                if kwargs['StepSize'].startswith('0x'):
                    mld_kwargs_addrmode = int(kwargs['StepSize'],16)
                else:
                    mld_kwargs_addrmode = int(kwargs['StepSize'])
            else:
                mld_kwargs_addrmode = kwargs['StepSize']
        if mld_kwargs_flag:
            self._ixia_mld_kwargs_flag = 1
            self._ixia_mld_kwargs_detail = {}
            self._ixia_mld_kwargs_detail['mld_kwargs_addrmask'] = mld_kwargs_addrmask
            self._ixia_mld_kwargs_detail['mld_kwargs_addrmode'] = mld_kwargs_addrmode
            self._ixia_mld_kwargs_detail['mld_kwargs_addrrepeatcount'] = mld_kwargs_addrrepeatcount
            self._ixia_mld_kwargs_detail['mld_kwargs_addrstepsize'] = mld_kwargs_addrstepsize
            #cmdlist.append('udf setDefault')
            #cmdlist.append('udf config -enable true')
        else:
            self._ixia_mld_kwargs_detail = None
        return True

    def build_icmpv6_mldv1_report(self,code=0,chksum=None,mrd=0,reserved=0,mladdr='::',kwargs=None):
        '''build mldv1 query field packet

           args:
           - code        = 0
           - chksum      = None;
           - mrd         = 0;      max response delay
           - reserved    = 0;
           - mladdr      = ::

           return:
           packet field length

           exapmle:
           | Build Icmpv6 Mld Report | mladdr=ff3f::1 |
        '''
        if issubclass(type(code),basestring):
            if code.startswith('0x'):
                code = int(code,16)
            else:
                code = int(code)
        if issubclass(type(mrd),basestring):
            if mrd.startswith('0x'):
                mrd = int(mrd,16)
            else:
                mrd = int(mrd)
        if issubclass(type(reserved),basestring):
            if reserved.startswith('0x'):
                reserved = int(reserved,16)
            else:
                reserved = int(reserved)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        cmd = "IPv6ExtHdrHopByHop(nh=58,options=RouterAlert())/ICMPv6MLReport(code=%i,mrd=%i,reserved=%i,mladdr='%s'" % (code,mrd,reserved,mladdr)
        if chksum:
            cmd += ",cksum=%i" % chksum
        cmd += ")"
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_icmpv6_mldv1_report_ixia(code,chksum,mrd,reserved,mladdr,kwargs)
            return len(p)

    def _build_icmpv6_mldv1_report_ixia(self,code,chksum,mrd,reserved,mladdr,kwargs):
        '''
        '''
        cmdlist = []
        #config ipv6 hopbyhop
        cmdlist.append('ipV6 clearAllExtensionHeaders')
        cmdlist.append('ipV6HopByHop clearAllOptions')
        cmdlist.append('ipV6OptionRouterAlert setDefault')
        cmdlist.append('ipV6OptionRouterAlert config -length 2')
        cmdlist.append('ipV6OptionRouterAlert config -routerAlert ipV6RouterAlertMLD')
        cmdlist.append('ipV6HopByHop addOption ipV6OptionRouterAlert')
        cmdlist.append('ipV6OptionPADN setDefault')
        cmdlist.append('ipV6OptionPADN config -length 0')
        cmdlist.append('ipV6OptionPADN config -value ""')
        cmdlist.append('ipV6HopByHop addOption ipV6OptionPADN')
        cmdlist.append('ipV6 addExtensionHeader ipV6HopByHopOptions')
        ipv6HopbyHopCmd = '!'.join(cmdlist)
        #look up for ipv6 config
        ipv6matchre = re.compile(r'ipV6 config -')
        iv6strlen = 0
        for istr in self._ixia_packetField:
            if ipv6matchre.search(istr):
                self._ixia_packetField[iv6strlen] += '!' + ipv6HopbyHopCmd
                break
            iv6strlen += 1
        #stream config -patternType nonRepeat
        #stream config -dataPattern userpattern
        #stream config -pattern $pattern
        self._ixia_ipv6_icmpv6_mld_flag = 1
        cmdlist = []
        mld_kwargs_flag = 0
        mld_kwargs_addrmask = 128
        mld_kwargs_addrmode = 'uuuu'
        mld_kwargs_addrrepeatcount = 1
        mld_kwargs_addrstepsize = 1
        if kwargs and 'AddrMask' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['AddrMask']),basestring):
                if kwargs['AddrMask'].startswith('0x'):
                    mld_kwargs_addrmask = int(kwargs['AddrMask'],16)
                else:
                    mld_kwargs_addrmask = int(kwargs['AddrMask'])
            else:
                mld_kwargs_addrmask = kwargs['AddrMask']
        if kwargs and 'AddrMode' in kwargs.keys():
            mld_kwargs_flag = 1
            mld_kwargs_addrmode = kwargs['AddrMode']
        if kwargs and 'AddrRepeatCount' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['AddrRepeatCount']),basestring):
                if kwargs['AddrRepeatCount'].startswith('0x'):
                    mld_kwargs_addrrepeatcount = int(kwargs['AddrRepeatCount'],16)
                else:
                    mld_kwargs_addrrepeatcount = int(kwargs['AddrRepeatCount'])
            else:
                mld_kwargs_addrrepeatcount = kwargs['AddrRepeatCount']
        if kwargs and 'StepSize' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['StepSize']),basestring):
                if kwargs['StepSize'].startswith('0x'):
                    mld_kwargs_addrmode = int(kwargs['StepSize'],16)
                else:
                    mld_kwargs_addrmode = int(kwargs['StepSize'])
            else:
                mld_kwargs_addrmode = kwargs['StepSize']
        if mld_kwargs_flag:
            self._ixia_mld_kwargs_flag = 1
            self._ixia_mld_kwargs_detail = {}
            self._ixia_mld_kwargs_detail['mld_kwargs_addrmask'] = mld_kwargs_addrmask
            self._ixia_mld_kwargs_detail['mld_kwargs_addrmode'] = mld_kwargs_addrmode
            self._ixia_mld_kwargs_detail['mld_kwargs_addrrepeatcount'] = mld_kwargs_addrrepeatcount
            self._ixia_mld_kwargs_detail['mld_kwargs_addrstepsize'] = mld_kwargs_addrstepsize
        else:
            self._ixia_mld_kwargs_detail = None
        return True

    def build_icmpv6_mldv1_done(self,code=0,chksum=None,mrd=0,reserved=0,mladdr='::',kwargs=None):
        '''build mldv1 query field packet

           args:
           - code        = 0
           - chksum      = None;
           - mrd         = 0;      max response delay
           - reserved    = 0;
           - mladdr      = ::

           return:
           packet field length

           exapmle:
           | Build Icmpv6 Mld Done | mladdr=ff3f::1 |
        '''
        if issubclass(type(code),basestring):
            if code.startswith('0x'):
                code = int(code,16)
            else:
                code = int(code)
        if issubclass(type(mrd),basestring):
            if mrd.startswith('0x'):
                mrd = int(mrd,16)
            else:
                mrd = int(mrd)
        if issubclass(type(reserved),basestring):
            if reserved.startswith('0x'):
                reserved = int(reserved,16)
            else:
                reserved = int(reserved)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        cmd = "IPv6ExtHdrHopByHop(nh=58,options=RouterAlert())/ICMPv6MLDone(code=%i,mrd=%i,reserved=%i,mladdr='%s'" % (code,mrd,reserved,mladdr)
        if chksum:
            cmd += ",cksum=%i" % chksum
        cmd += ")"
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_icmpv6_mldv1_done_ixia(code,chksum,mrd,reserved,mladdr,kwargs)
            return len(p)

    def _build_icmpv6_mldv1_done_ixia(self,code,chksum,mrd,reserved,mladdr,kwargs):
        '''
        '''
        cmdlist = []
        #config ipv6 hopbyhop
        cmdlist.append('ipV6 clearAllExtensionHeaders')
        cmdlist.append('ipV6HopByHop clearAllOptions')
        cmdlist.append('ipV6OptionRouterAlert setDefault')
        cmdlist.append('ipV6OptionRouterAlert config -length 2')
        cmdlist.append('ipV6OptionRouterAlert config -routerAlert ipV6RouterAlertMLD')
        cmdlist.append('ipV6HopByHop addOption ipV6OptionRouterAlert')
        cmdlist.append('ipV6OptionPADN setDefault')
        cmdlist.append('ipV6OptionPADN config -length 0')
        cmdlist.append('ipV6OptionPADN config -value ""')
        cmdlist.append('ipV6HopByHop addOption ipV6OptionPADN')
        cmdlist.append('ipV6 addExtensionHeader ipV6HopByHopOptions')
        ipv6HopbyHopCmd = '!'.join(cmdlist)
        #look up for ipv6 config
        ipv6matchre = re.compile(r'ipV6 config -')
        iv6strlen = 0
        for istr in self._ixia_packetField:
            if ipv6matchre.search(istr):
                self._ixia_packetField[iv6strlen] += '!' + ipv6HopbyHopCmd
                break
            iv6strlen += 1
        #stream config -patternType nonRepeat
        #stream config -dataPattern userpattern
        #stream config -pattern $pattern
        self._ixia_ipv6_icmpv6_mld_flag = 1
        cmdlist = []
        mld_kwargs_flag = 0
        mld_kwargs_addrmask = 128
        mld_kwargs_addrmode = 'uuuu'
        mld_kwargs_addrrepeatcount = 1
        mld_kwargs_addrstepsize = 1
        if kwargs and 'AddrMask' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['AddrMask']),basestring):
                if kwargs['AddrMask'].startswith('0x'):
                    mld_kwargs_addrmask = int(kwargs['AddrMask'],16)
                else:
                    mld_kwargs_addrmask = int(kwargs['AddrMask'])
            else:
                mld_kwargs_addrmask = kwargs['AddrMask']
        if kwargs and 'AddrMode' in kwargs.keys():
            mld_kwargs_flag = 1
            mld_kwargs_addrmode = kwargs['AddrMode']
        if kwargs and 'AddrRepeatCount' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['AddrRepeatCount']),basestring):
                if kwargs['AddrRepeatCount'].startswith('0x'):
                    mld_kwargs_addrrepeatcount = int(kwargs['AddrRepeatCount'],16)
                else:
                    mld_kwargs_addrrepeatcount = int(kwargs['AddrRepeatCount'])
            else:
                mld_kwargs_addrrepeatcount = kwargs['AddrRepeatCount']
        if kwargs and 'StepSize' in kwargs.keys():
            mld_kwargs_flag = 1
            if issubclass(type(kwargs['StepSize']),basestring):
                if kwargs['StepSize'].startswith('0x'):
                    mld_kwargs_addrmode = int(kwargs['StepSize'],16)
                else:
                    mld_kwargs_addrmode = int(kwargs['StepSize'])
            else:
                mld_kwargs_addrmode = kwargs['StepSize']
        if mld_kwargs_flag:
            self._ixia_mld_kwargs_flag = 1
            self._ixia_mld_kwargs_detail = {}
            self._ixia_mld_kwargs_detail['mld_kwargs_addrmask'] = mld_kwargs_addrmask
            self._ixia_mld_kwargs_detail['mld_kwargs_addrmode'] = mld_kwargs_addrmode
            self._ixia_mld_kwargs_detail['mld_kwargs_addrrepeatcount'] = mld_kwargs_addrrepeatcount
            self._ixia_mld_kwargs_detail['mld_kwargs_addrstepsize'] = mld_kwargs_addrstepsize
            #cmdlist.append('udf setDefault')
            #cmdlist.append('udf config -enable true')
        else:
            self._ixia_mld_kwargs_detail = None
        return True

    def build_icmpv6_echo_request(self,code=0,chksum=None,iden=0,seq=0,data='',kwargs=None):
        '''build icmpv6 echo request field packet

           args:
           - code        = 0
           - chksum      = None;
           - iden        = 0;
           - seq         = 0;
           - data        = ''

           return:
           packet field length

           exapmle:
           | Build Icmpv6 Echo Request |
        '''
        if issubclass(type(code),basestring):
            if code.startswith('0x'):
                code = int(code,16)
            else:
                code = int(code)
        if issubclass(type(iden),basestring):
            if iden.startswith('0x'):
                iden = int(iden,16)
            else:
                iden = int(iden)
        if issubclass(type(seq),basestring):
            if seq.startswith('0x'):
                seq = int(seq,16)
            else:
                seq = int(seq)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        cmd = "ICMPv6EchoRequest(code=%i,id=%i,seq=%i,data='%s'" % (code,iden,seq,data)
        if chksum:
            cmd += ",cksum=%i" % chksum
        cmd += ")"
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_icmpv6_echo_request_ixia(code,chksum,iden,seq,data,kwargs)
            return len(p)

    def _build_icmpv6_echo_request_ixia(self,code,chksum,iden,seq,data,kwargs):
        '''
        '''
        cmdlist = []
        #stream config -patternType nonRepeat
        #stream config -dataPattern userpattern
        #stream config -pattern $pattern
        self._ixia_ipv6_icmpv6_echo_flag = 1
        return True

    def build_icmpv6_echo_reply(self,code=0,chksum=None,iden=0,seq=0,data='',kwargs=None):
        '''build icmpv6 echo reply field packet

           args:
           - code        = 0
           - chksum      = None;
           - iden        = 0;
           - seq         = 0;
           - data        = ''

           return:
           packet field length

           exapmle:
           | Build Icmpv6 Echo Reply |
        '''
        if issubclass(type(code),basestring):
            if code.startswith('0x'):
                code = int(code,16)
            else:
                code = int(code)
        if issubclass(type(iden),basestring):
            if iden.startswith('0x'):
                iden = int(iden,16)
            else:
                iden = int(iden)
        if issubclass(type(seq),basestring):
            if seq.startswith('0x'):
                seq = int(seq,16)
            else:
                seq = int(seq)
        if chksum:
            if issubclass(type(chksum),basestring):
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        cmd = "ICMPv6EchoReply(code=%i,id=%i,seq=%i,data='%s'" % (code,iden,seq,data)
        if chksum:
            cmd += ",cksum=%i" % chksum
        cmd += ")"
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_icmpv6_echo_reply_ixia(code,chksum,iden,seq,data,kwargs)
            return len(p)

    def _build_icmpv6_echo_reply_ixia(self,code,chksum,iden,seq,data,kwargs):
        '''
        '''
        cmdlist = []
        #stream config -patternType nonRepeat
        #stream config -dataPattern userpattern
        #stream config -pattern $pattern
        self._ixia_ipv6_icmpv6_echo_flag = 1
        return True

    def build_dot1q(self,prio=0,cfi=0,vlan=1,typeid=None,kwargs=None):
        '''
           build 802.1Q field packet

           args:
           - prio    = 0
           - cfi      = 0
           - vlan    = 1
           - typeid  = None

           return:
           packet field length

           exapmle:
           | Build Dot1q | prio=${7} | vlan=${10} |
        '''
        if issubclass(type(prio),basestring):
            if prio.startswith('0x'):
                prio = int(prio,16)
            else:
                prio = int(prio)
        if issubclass(type(cfi),basestring):
            if cfi.startswith('0x'):
                cfi = int(cfi,16)
            else:
                cfi = int(cfi)
        if issubclass(type(vlan),basestring):
            if vlan.startswith('0x'):
                vlan = int(vlan,16)
            else:
                vlan = int(vlan)
        if issubclass(type(typeid),basestring):
            if typeid.startswith('0x'):
                typeid = int(typeid,16)
            else:
                typeid = int(typeid)
        if typeid:
            cmd = "Dot1Q(prio=%i, vlan=%i, id=%i, type=%#x)" % (prio,vlan,cfi,typeid)
        else:
            cmd = "Dot1Q(prio=%i, vlan=%i, id=%i)" % (prio,vlan,cfi)
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            if self._ixia_flag:
                self._build_vlan_ixia(prio,cfi,vlan,typeid,kwargs)
            elif self._pktgen_flag:
                self._build_vlan_pktgen(prio,cfi,vlan,typeid,kwargs)
            return len(p)

    def _build_vlan_pktgen(self,prio,cfi,vlan,typeid,kwargs):
        """
        """
        cmdlist = []
        cmdlist.append("vlan_id %s" % vlan)
        cmdlist.append("vlan_p %s" % prio)
        self._pktgen_vlan_flag += 1
        cmd = '!'.join(cmdlist)
        self._pktgen_packetField.append(cmd)
        return True

    def _build_vlan_ixia(self,prio,cfi,vlan,typeid,kwargs):
        '''
        '''
        self._ixia_vlan_flag += 1
        cmdlist = []
        cmdlist.append('vlan setDefault')
        cmdlist.append('vlan config -vlanID %s' % vlan)
        cmdlist.append('vlan config -userPriority %s' % prio)
        if typeid == 0x8100:
            cmdlist.append('vlan config -protocolTagId vlanProtocolTag8100')
        elif typeid == 0x9100:
            cmdlist.append('vlan config -protocolTagId vlanProtocolTag9100')
        elif typeid == 0x9200:
            cmdlist.append('vlan config -protocolTagId vlanProtocolTag9200')
        else:
            cmdlist.append('vlan config -protocolTagId vlanProtocolTag8100')
        if kwargs and 'mode' in kwargs.keys():
            cmdlist.append('vlan config -mode %s' % kwargs['mode'])
        if kwargs and 'repeat' in kwargs.keys():
            cmdlist.append('vlan config -repeat %s' % kwargs['repeat'])
        if kwargs and 'step' in kwargs.keys():
            cmdlist.append('vlan config -step %s' % kwargs['step'])
        cmd = '!'.join(cmdlist)
        self._ixia_vlan_cmd.append(cmd)
        return True

    def build_payload(self,payload):
        '''
           build payload field packet

           args:
           - payload  = None;  filled automatically using \x00; if you fill manually,please assinged using hexstring,and length para is invlaid

           return:
           packet field length

           exapmle:
           | Build Payload | 000102030405 |
        '''
        if payload:
            if len(payload) % 2 == 1:
                raise AssertionError('payload len is not even')
            fillstr = payload
        else:
            return 0
        cmd = "self._verify_raw('%s')" % fillstr
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong:%s' % (cmd,traceback.format_exc()))
            return -1
        else:
            self._packetField.append(cmd)
            return repr(p)

    def _build_payload(self,length=128,pltype=0):
        '''
           invoked by build_packet

           args:
           - length   = 128;  packet length,including crc

           return:
           packet field length

           exapmle:
           | Build Payload |
           | Build Payload | ${256} |
           | Build Payload | payload=000102030405 |
        '''
        if issubclass(type(length),basestring):
            if length.startswith('0x'):
                length = int(length,16)
            else:
                length = int(length)
        payload_type = pltype
        if True:
            if payload_type == 0:
                payload_str = '00'
            else:
                payload_str = '00'
            pktstr = '/'.join(self._packetField)
            cmd = 'p=' + pktstr
            try:
                exec(cmd)
            except Exception,ex:
                logger.info('cmd %s format may wrong' % cmd)
                return -1
            else:
                ptklen = len(p)
                self._packet_scapy_length = ptklen
                if self._ixia_flag:
                    self._ixia_frameType = p.type
                    if self._ixia_ipProto_flag:
                        self._ixia_ipProto = p.proto
                    if self._ixia_ipv6Proto_flag:
                        self._ixia_ipv6Proto = p.nh
            #compute filled packet
            filllen = length - ptklen - 4  # remove crc field
            if filllen < 0:
                logger.info('packet length is %i, greater than given para' % ptklen)
                return -1
            elif filllen == 0:
                return p
            fillstr = payload_str * filllen
        cmd = "self._verify_raw('%s')" % fillstr
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong:%s' % (cmd,traceback.format_exc()))
            return -1
        else:
            self._packetField.append(cmd)
            return p

    @staticmethod
    def _verify_raw(rawstr):
        fillList = [
            chr(int(rawstr[i:i+2],16)) for i in range(0,len(rawstr)-1,2)
        ]
        cmd = "p=Raw(''.join(fillList))"
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            return Raw()
        else:
            return p
    def _create_ixia_ipv6_icmpv6_mld(self,pktstr,scapylen):
        '''
        '''
        cmd = 'p=' + pktstr
        try:
            exec(cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            ptklen = len(p)
        #config mld icmpv6 packet field
        if self._ixia_ipv6_icmpv6_mld_flag:
            mldStr = hexstr(str(p),0,1)
            cmdlist = []
            cmdlist.append('stream config -patternType nonRepeat')
            cmdlist.append('stream config -dataPattern userpattern')
            pattern = ' '.join(mldStr.split()[scapylen-ptklen-24:scapylen-ptklen])
            cmdlist.append('stream config -pattern "%s"' % pattern)
            ipv6Icmpv6MldCmd = '!'.join(cmdlist)
            self._ixia_packetField[0] += '!' + ipv6Icmpv6MldCmd
            self._ixia_ipv6_icmpv6_mld_flag = 0
        #config ipv6 hopbyhop nextheader to 58
        cmdlist = []
        cmdlist.append('udf setDefault')
        cmdlist.append('udf config -enable true')
        offset1 = 54 + self._ixia_vlan_flag * 4
        initval1 = '3A'
        cmdlist.append('udf config -offset %s' % offset1)
        cmdlist.append('udf config -initval %s' % initval1)
        cmdlist.append('udf set 1')
        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("none")
        #config mld kwargs used by udf2 and udf 3
        if self._ixia_mld_kwargs_flag:
            if self._ixia_mld_kwargs_detail:
                mask = self._ixia_mld_kwargs_detail['mld_kwargs_addrmask']
                mode = self._ixia_mld_kwargs_detail['mld_kwargs_addrmode']
                count = self._ixia_mld_kwargs_detail['mld_kwargs_addrrepeatcount']
                size = self._ixia_mld_kwargs_detail['mld_kwargs_addrstepsize']
                cmdlist = []
                cmdlist.append('udf setDefault')
                cmdlist.append('udf config -enable true')
                offset1 = scapylen - 24 + 8 + mask/8 - 1
                initval1 = mldStr.split()[offset1]
                cmdlist.append('udf config -offset %s' % offset1)
                cmdlist.append('udf config -initval %s' % initval1)
                cmdlist.append('udf config -repeat %s' % count)
                cmdlist.append('udf config -updown %s' % mode)
                cmdlist.append('udf config -step %s' % size)
                cmdlist.append('udf set 2')
                #compute crc
                offset2 = scapylen - 24 + 2
                initval21 = mldStr.split()[offset2]
                initval22 = mldStr.split()[offset2+1]
                cmdlist.append('udf setDefault')
                cmdlist.append('udf config -enable true')
                cmdlist.append('udf config -countertype c16')
                cmdlist.append('udf config -offset %s' % offset2)
                cmdlist.append('udf config -initval {%s %s}' % (initval21,initval22))
                cmdlist.append('udf config -repeat %s' % count)
                if mode == 'uuuu':
                    cmdlist.append('udf config -updown dddd')
                else:
                    cmdlist.append('udf config -updown uuuu')
                cmdlist.append('udf config -step %s' % size)
                cmdlist.append('udf set 3')
                cmd = '!'.join(cmdlist)
                self._ixia_packetField.append(cmd)
                self._ixia_write_cmd.append("none")
            self._ixia_mld_kwargs_detail = None
            self._ixia_mld_kwargs_flag = 0

    def _create_ixia_ipv6_icmpv6_echo(self,pktstr,scapylen):
        '''
        '''
        cmd = 'p=' + pktstr
        try:
            exec(cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            ptklen = len(p)
        #config mld icmpv6 packet field
        if self._ixia_ipv6_icmpv6_echo_flag:
            mldStr = hexstr(str(p),0,1)
            cmdlist = []
            cmdlist.append('stream config -patternType nonRepeat')
            cmdlist.append('stream config -dataPattern userpattern')
            pattern = ' '.join(mldStr.split()[scapylen-ptklen-8:scapylen-ptklen])
            cmdlist.append('stream config -pattern "%s"' % pattern)
            ipv6Icmpv6EchoCmd = '!'.join(cmdlist)
            self._ixia_packetField[0] += '!' + ipv6Icmpv6EchoCmd
            self._ixia_ipv6_icmpv6_echo_flag = 0
        #disable ipv6 Proto
        self._ixia_ipv6Proto_flag = 0
        #config ipv6 nextheader to 58
        cmdlist = []
        cmdlist.append('udf setDefault')
        cmdlist.append('udf config -enable true')
        offset1 = 20 + self._ixia_vlan_flag * 4
        initval1 = '3A'
        cmdlist.append('udf config -offset %s' % offset1)
        cmdlist.append('udf config -initval %s' % initval1)
        cmdlist.append('udf set 1')
        cmd = '!'.join(cmdlist)
        self._ixia_packetField.append(cmd)
        self._ixia_write_cmd.append("none")
