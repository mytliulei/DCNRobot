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

    def _get_stream_from_pcapfile(self,filename):
        '''read pcap file and return bytes stream'''
        if not os.path.isfile(filename):
            logger.info('%s is not a file' % filename)
            raise AssertionError('%s is not file or path error' % filename)
        with open(filename,'rb') as handle:
            return handle.read()

    def get_packet_list(self,ixiaFlag=0):
        if ixiaFlag:
            ixia_packetStr = ''
            if self._packetList:
                cmd = 'p=' + self._packetList[0]
                exec(cmd)
                ipstr = hexstr(str(p),0,1)
                ixia_packetStr = '$'.join(ipstr.split())
            return ixia_packetStr
        else:
            return self._packetList

    def empty_packet_list(self):
        self._packetList = []

    def _build_stream(self):
        ''''''
        self._pkt_streamlist_hexstring = self._packetList
        self._packetList = []
        return self._pkt_streamlist_hexstring

    def build_packet(self,length=128,packetstr=None):
        ''''''
        if packetstr:
            cmd = packetstr
        else:
            self._build_payload(length)
            pktstr = '/'.join(self._packetField)
            cmd = pktstr
        self._packetList.append(cmd)
        self._packetField = []
        return 0

    def build_ether(self,dst='ff:ff:ff:ff:ff:ff',src='00:00:00:00:00:00',typeid=None):
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
        if type(typeid) is str:
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
            return len(p)

    def build_arp(self,hwtype=0x1,ptype=0x800,hwlen=6,plen=4,op=1,hwsrc='00:00:00:00:00:00',psrc='0.0.0.0',hwdst='00:00:00:00:00:00',pdst='0.0.0.0'):
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
        if type(hwtype) is str:
            if hwtype.startswith('0x'):
                hwtype = int(hwtype,16)
            else:
                hwtype = int(hwtype)
        if type(ptype) is str:
            if ptype.startswith('0x'):
                ptype = int(ptype,16)
            else:
                ptype = int(ptype)
        if type(hwlen) is str:
            if hwlen.startswith('0x'):
                hwlen = int(hwlen,16)
            else:
                hwlen = int(hwlen)
        if type(plen) is str:
            if plen.startswith('0x'):
                plen = int(plen,16)
            else:
                plen = int(plen)
        if type(op) is str:
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
            return len(p)

    def build_ip(self,version=4,ihl=None,tos=0x0,iplen=None,iden=0,flags=0,frag=0,ttl=64,proto=0,chksum=None,src='0.0.0.0',dst='0.0.0.0',options=None):
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
           - proto   = 0
           - chksum  = None
           - src     = 0.0.0.0
           - dst     = 0.0.0.0
           - options = None  #packets list

           return:
           packet field length

           exapmle:
           | Build Ip | src=10.1.1.1 | dst=10.1.1.254 |
        '''
        if type(version) is str:
            if version.startswith('0x'):
                version = int(version,16)
            else:
                version = int(version)
        if type(tos) is str:
            if tos.startswith('0x'):
                tos = int(tos,16)
            else:
                tos = int(tos)
        if type(iden) is str:
            if iden.startswith('0x'):
                iden = int(iden,16)
            else:
                iden = int(iden)
        if type(flags) is str:
            if flags.startswith('0x'):
                flags = int(flags,16)
            else:
                flags = int(flags)
        if type(frag) is str:
            if frag.startswith('0x'):
                frag = int(frag,16)
            else:
                frag = int(frag)
        if type(ttl) is str:
            if ttl.startswith('0x'):
                ttl = int(ttl,16)
            else:
                ttl = int(ttl)
        if type(proto) is str:
            if proto.startswith('0x'):
                proto = int(proto,16)
            else:
                proto = int(proto)
        if ihl:
            if type(ihl) is str:
                if ihl.startswith('0x'):
                    ihl = int(ihl,16)
                else:
                    ihl = int(ihl)
        if chksum:
            if type(chksum) is str:
                if chksum.startswith('0x'):
                    chksum = int(chksum,16)
                else:
                    chksum = int(chksum)
        if iplen:
            if type(iplen) is str:
                if iplen.startswith('0x'):
                    iplen = int(iplen,16)
                else:
                    iplen = int(iplen)
        if options:
            if type(options) is str:
                if options.startswith('0x'):
                    options = int(options,16)
                else:
                    options = int(options)
        else:
            options = []
        cmd = "IP(version=%i,ihl=%s,tos=%#x,len=%s,id=%i,flags=%i,frag=%i,ttl=%i,proto=%i,chksum=%s,src='%s',dst='%s',options=%s)" % (version,ihl,tos,iplen,iden,flags,frag,ttl,proto,chksum,src,dst,options)
        try:
            exec('p=%s' % cmd)
        except Exception,ex:
            logger.info('cmd %s format may wrong' % cmd)
            return -1
        else:
            self._packetField.append(cmd)
            return len(p)

    def build_dot1q(self,prio=0,cfi=0,vlan=1,typeid=None):
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
        if type(prio) is str:
            if prio.startswith('0x'):
                prio = int(prio,16)
            else:
                prio = int(prio)
        if type(cfi) is str:
            if cfi.startswith('0x'):
                cfi = int(cfi,16)
            else:
                cfi = int(cfi)
        if type(vlan) is str:
            if vlan.startswith('0x'):
                vlan = int(vlan,16)
            else:
                vlan = int(vlan)
        if type(typeid) is str:
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
            return len(p)

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
            return p

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
        if type(length) is str:
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
            filllen = length - ptklen - 4  # remove crc field
            if filllen < 0:
                logger.info('packet length is %i, greater than given para' % ptklen)
                return -1
            elif fillen == 0:
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
            return -1
        else:
            return len(p)

