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
        self._PGDEV = "/proc/net/pktgen/kpktgend_0"
        self.if_pkt_cmdlist = {}
        self.if_control_cmdlist = {}
        self.if_statistics = {}
        self.if_cap_pkt = {}

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
            excluded = ['get_packet_list','empty_packet_list','get_packet_list_ixiaapi', 'build_arp', 'build_icmp', 'build_igmpv1v2', 'build_icmpv6_mldv1_query', 'build_icmpv6_mldv1_report', 'build_icmpv6_mldv1_done', 'build_icmpv6_echo_request', 'build_icmpv6_echo_reply', 'build_payload', 'get_packet_cmd_pktgen']
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
        cmdlist = []
        cmdlist.append("modprobe pktgen")
        return cmdlist

    def uninit_pktgen(self):
        """
        """
        cmdlist = []
        cmdlist.append("rmmod pktgen")
        return cmdlist

    def check_pktgen(self):
        """
        """
        cmdlist = []
        cmdlist.append("test -f /proc/net/pktgen/kpktgend_0")
        return cmdlist

    def set_stream_packet(self,iface):
        """
        """
        cmdlist = []
        cmdstr = self._pkt_class.get_packet_cmd_pktgen()
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
        cmdlist = self.if_pkt_cmdlist[iface] + self.if_control_cmdlist[iface]
        cmdlist.append("start")
        return self._trans_cmd(cmdlist)

    def stop_transmit(self,iface):
        """
        """
        if iface not in self.if_pkt_cmdlist.keys() or iface not in self.if_control_cmdlist.keys():
            raise AssertionError('iface %s not defined' % iface)
        cmdlist = []
        cmdlist.append("stop")
        return self._trans_cmd(cmdlist)

    def start_capture(self,iface):
        """
        """

    def stop_capture(self,iface):
        """
        """

    def clear_statics(self,iface):
        """
        """

    def filter_capture_packet(self,iface,express):
        """
        """

    def get_capture_packet_num(self,if):
        """
        """

    def get_statistics(self,if):
        """
        """

    def set_stream_control(self,iface,count,rate=None,ratep=None):
        """
        """
        cmdlist = []
        cmdlist.append("count %s" % count)
        cmdlist.append("clone_skb 0")
        if ratep:
            cmdlist.append("ratep %s" % ratep)
        elif rate:
            cmdlist.append("rate %s" % rate)
        else:
            cmdlist.append("ratep 10")
        self.if_control_cmdlist[iface] = cmdlist
        return cmdlist

    def _trans_cmd(self,cmdlist=None):
        """
        """
        tran_cmdlist = [ "echo %s > %s" % (icmd,self._PGDEV) for icmd in cmdlist]
        return tran_cmdlist
