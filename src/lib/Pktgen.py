#!/usr/bin/env python
#-*- coding: UTF-8 -*-
'''linux stream genertor Tools,for RF testing
'''
import os
import inspect
import time
import re


from robot.api import logger
from robot.version import get_version


import rfbase

__version__ = '0.1'
__author__ = 'liuleic'
__copyright__ = 'Copyright 2015, DigitalChina Network'
__license__ = 'Apache License, Version 2.0'
__mail__ = 'liuleic@digitalchina.com'

class Pktgen(object):
    '''
    '''
    ROBOT_LIBRARY_SCOPE = 'TEST_SUITE'
    ROBOT_LIBRARY_VERSION = get_version()
    def __init__(self):
        ''''''
        self._pkt_kws = self._lib_kws = None
        self._pkt_class = rfbase.PacketBase()
        self._pkt_class._set_pktgen_flag(True)
        self._pg_thread = "/proc/net/pktgen/kpktgend_0"
        self._pg_dev = "/proc/net/pktgen/"
        self._pg_ctrl = "/proc/net/pktgen/pgctrl"
        self.if_pkt_cmdlist = {}
        self.if_control_cmdlist = {}
        self.if_statistics = {}
        self.if_cap_pkt = {}
        self.if_cap_file = {}
        self.if_cap_num = {}
        self.if_pkt_size = {}
        self.if_control_delay = {}

    def __del__(self):
        ''''''
        pass

    def get_keyword_names(self):
        return self._get_library_keywords() + self._get_pkt_keywords()

    def _get_library_keywords(self):
        if self._lib_kws is None:
            self._lib_kws = self._get_keywords(self, ['get_keyword_names'])
        return self._lib_kws

    def _get_keywords(self, source, excluded):
        return [name for name in dir(source)
                if self._is_keyword(name, source, excluded)]

    def _is_keyword(self, name, source, excluded):
        return (name not in excluded and
                not name.startswith('_') and
                name != 'get_keyword_names' and
                inspect.ismethod(getattr(source, name)))

    def _get_pkt_keywords(self):
        if self._pkt_kws is None:
            pkt = self._pkt_class
            excluded = ['get_packet_list','empty_packet_list','get_packet_list_ixiaapi', 'build_arp', 'build_icmp', 'build_igmpv1v2', 'build_icmpv6_mldv1_query', 'build_icmpv6_mldv1_report', 'build_icmpv6_mldv1_done', 'build_icmpv6_echo_request', 'build_icmpv6_echo_reply', 'build_payload', 'get_packet_cmd_pktgen', 'build_ether', 'build_ip', 'build_ipv6']
            self._pkt_kws = self._get_keywords(pkt, excluded)
        return self._pkt_kws

    def __getattr__(self, name):
        if name not in self._get_pkt_keywords():
            raise AttributeError(name)
        # This makes it possible for Robot to create keyword
        # handlers when it imports the library.
        return getattr(self._pkt_class, name)

    def init_pktgen(self):
        """
        """
        cmd = "modprobe pktgen"
        return cmd

    def uninit_pktgen(self):
        """
        """
        cmd = "rmmod pktgen"
        return cmd

    def check_pktgen(self):
        """
        """
        cmd = "test -f /proc/net/pktgen/kpktgend_0"
        return cmd

    def check_tcpdump(self):
        """
        """
        cmd = "which tcpdump"
        return cmd

    def check_tcpdump_paramter_in(self):
        """
        """
        cmd = "tcpdump -h"
        return cmd

    def set_stream_packet(self,iface):
        """
        """
        cmdlist = []
        cmdstr = self._pkt_class.get_packet_cmd_pktgen()[0]
        self.if_pkt_size[iface] = self._pkt_class.get_packet_cmd_pktgen()[1]
        for icmd in cmdstr.split("@"):
            for jcmd in icmd.split("!"):
                cmdlist.append(jcmd)
        self.if_pkt_cmdlist[iface] = cmdlist
        return cmdlist

    def start_transmit(self,iface):
        """
        """
        if iface not in self.if_pkt_cmdlist.keys() or iface not in self.if_control_cmdlist.keys():
            raise AssertionError('iface %s not define packet or stream control' % iface)
        cmdlist = []
        cmdlist.append(["echo rem_device_all > ", self._pg_thread])
        cmdlist.append(["echo add_device %s > " % iface, self._pg_thread])
        cmdlist += self._trans_cmd(iface, self.if_control_cmdlist[iface] + self.if_pkt_cmdlist[iface])
        cmd_start = "echo start > %s" % self._pg_ctrl
        return cmdlist,cmd_start

    def stop_transmit(self,iface):
        """
        """
        if iface not in self.if_pkt_cmdlist.keys() or iface not in self.if_control_cmdlist.keys():
            raise AssertionError('iface %s not defined' % iface)
        cmd_stop = "ps -ef | grep \"echo start > %s\" | head -n 1 | awk '{print $2}' | xargs kill" % self._pg_ctrl
        return cmd_stop

    def start_capture(self,iface,in_flag=True):
        """
        """
        fname = "/tmp/%s.pcap" % int(time.time())
        if in_flag:
            cmd = "tcpdump -n -U -P in -i %s -w %s" % (iface,fname)
        else:
            cmd = "tcpdump -n -U -i %s -w %s" % (iface,fname)
        self.if_cap_file[iface] = fname
        return cmd

    def stop_capture(self,iface,in_flag=True):
        """
        """
        if iface not in self.if_cap_file.keys():
            raise AssertionError('iface %s not defined' % iface)
        fname = self.if_cap_file[iface]
        if in_flag:
            cmd = "ps -ef | grep \"tcpdump -n -P in -i %s -w %s\" | head -n 1 | awk '{print $2}' | xargs kill" % (iface,fname)
        else:
            cmd = "ps -ef | grep \"tcpdump -n -i %s -w %s\" | head -n 1 | awk '{print $2}' | xargs kill" % (iface,fname)
        return cmd

    def _clear_statics(self,iface):
        """
        """
        pass

    def filter_capture_packet(self,iface,express):
        """
        """
        if iface not in self.if_cap_file.keys():
            raise AssertionError('iface %s not defined' % iface)
        fname = self.if_cap_file[iface]
        if express:
            cmd = "tcpdump -n -r %s '%s' | wc -l" % (fname,express)
        else:
            cmd = "tcpdump -n -r %s | wc -l" % fname
        return cmd

    def get_filter_capture_packet(self,iface,express):
        """
        """
        if iface not in self.if_cap_file.keys():
            raise AssertionError('iface %s not defined' % iface)
        fname = self.if_cap_file[iface]
        if express:
            cmd = "tcpdump -n -XX -r %s '%s'" % (fname,express)
        else:
            cmd ="tcpdump -n -XX -r %s" % fname
        return cmd

    def get_capture_packet_num(self,iface):
        """
        """
        if iface not in self.if_cap_file.keys():
            raise AssertionError('iface %s not defined' % iface)
        fname = self.if_cap_file[iface]
        cmd = "tcpdump -n -r %s | wc -l" % fname
        return cmd

    def _get_statistics(self,iface):
        """
        """
        pass

    def _get_statis_beckmark(self,iface):
        """
        """
        cmdlist = []
        cmdlist.append("cat /sys/class/net/%s/statistics/tx_packets" % iface)
        cmdlist.append("cat /sys/class/net/%s/statistics/tx_bytes" % iface)
        cmdlist.append("cat /sys/class/net/%s/statistics/rx_packets" % iface)
        cmdlist.append("cat /sys/class/net/%s/statistics/rx_bytes" % iface)
        return cmdlist

    def set_stream_control(self,iface,count,rate=None,ratep=None):
        """
        """
        cmdlist = []
        cmdlist.append("count %s" % count)
        cmdlist.append("clone_skb 0")
        cmdlist.append("pkt_size %s" % self.if_pkt_size[iface])
        if ratep:
            cmdlist.append("ratep %s" % ratep)
            t_delay = 1000000000 / int(ratep)
        elif rate:
            cmdlist.append("rate %s" % rate)
            t_delay = 1000000000 / int(rate) / (int(self.if_pkt_size[iface]) * 8)
        else:
            cmdlist.append("ratep 10")
            t_delay = 100000000
        self.if_control_delay[iface] = t_delay
        self.if_control_cmdlist[iface] = cmdlist
        return cmdlist

    def get_stream_delay(self,iface):
        """
        """
        if iface not in self.if_control_delay.keys():
            raise AssertionError('iface %s not defined' % iface)
        cmd = "echo delay %s >" % self.if_control_delay[iface]
        return cmd

    def _trans_cmd(self, iface, cmdlist=None):
        """
        """
        pgdev = self._pg_dev + iface
        #tran_cmdlist = [ "echo %s > %s" % (icmd,pgdev) for icmd in cmdlist]
        tran_cmdlist = [ ["echo %s > " % icmd, pgdev] for icmd in cmdlist]
        return tran_cmdlist

    def build_ether(self, dst, src, dst_mac_count=None, src_mac_count=None):
        '''build Ethernet field packet

           args:
           - dst    : Dest Mac
           - src    : Source Mac
           - dst_mac_count : dst mac count   = None
           - src_mac_count : src mac count   = None

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
        if not dst_mac_count and not src_mac_count:
            pktlen = self._pkt_class.build_ether(dst,src)
        else:
            kdict = {}
            if dst_mac_count:
                kdict["dst_mac_count"] = dst_mac_count
            if src_mac_count:
                kdict["src_mac_count"] = src_mac_count
            pktlen = self._pkt_class.build_ether(dst,src,kwargs=kdict)
        return pktlen

    def build_ip(self, tos, dst, src, dst_ip_max=None, src_ip_max=None):
        '''build ip field packet

           args:
           - tos     :  type of service
           - dst     :  dst ip address
           - src     :  src ip address
           - dst_ip_max = None
           - src_ip_max = None

           return:
           packet field length

           exapmle:
           | Build Ip | src=10.1.1.1 | dst=10.1.1.254 |
        '''
        if issubclass(type(tos),basestring):
            if tos.startswith('0x'):
                tos = int(tos,16)
            else:
                tos = int(tos)
        if not dst_ip_max and not src_ip_max:
            pktlen = self._pkt_class.build_ip(tos=tos, dst=dst,src=src)
        else:
            kdict = {}
            if dst_ip_max:
                kdict["dst_ip_max"] = dst_ip_max
            if src_ip_max:
                kdict["src_ip_max"] = src_ip_max
            pktlen = self._pkt_class.build_ip(tos=tos, dst=dst,src=src,kwargs=kdict)
        return pktlen

    def build_ipv6(self, tc, dst, src, dst_ipv6_max=None, src_ipv6_max=None):
        '''build ipv6 field packet

           args:
           - tc      :   traffic class
           - src     :   src ip address
           - dst     :   dst ip address
           - dst_ipv6_max = None
           - src_ipv6_max = None

           return:
           packet field length

           exapmle:
           | Build Ipv6 | src=2001::1 | dst=2002::1 |
        '''
        if issubclass(type(tc),basestring):
            if tc.startswith('0x'):
                tc = int(tc,16)
            else:
                tc = int(tc)
        if not dst_ipv6_max and not src_ipv6_max:
            pktlen = self._pkt_class.build_ipv6(tc=tc, dst=dst,src=src)
        else:
            kdict = {}
            if dst_ipv6_max:
                kdict["dst_ipv6_max"] = dst_ipv6_max
            if src_ipv6_max:
                kdict["src_ipv6_max"] = src_ipv6_max
            pktlen = self._pkt_class.build_ipv6(tc=tc, dst=dst,src=src,kwargs=kdict)
        return pktlen