#!/usr/bin/env python
#-*- coding: UTF-8 -*-
'''ixia stream genertor Tools,for RF testing 
'''
import os,os.path
import inspect
import subprocess
import time
import re
import socket

from robot.api import logger
from robot.version import get_version
from robot.libraries import Remote
from scapy.all import *

import rfbase

__version__ = '0.1'
__author__ = 'liuleic'
__copyright__ = 'Copyright 2014, DigitalChina Network'
__license__ = 'Apache License, Version 2.0'
__mail__ = 'liuleic@digitalchina.com'

class Ixia(object):
    '''
    '''
    ROBOT_LIBRARY_SCOPE = 'TEST_SUITE'
    ROBOT_LIBRARY_VERSION = get_version()
    def __init__(self,ixia_ip,listen_port=11917):
        ''''''
        self._ixia_tcl_path = os.path.join(os.path.dirname(os.getcwd()),'tools','ixia','tcl')
        self._proxy_server_path = os.path.join(os.path.dirname(os.getcwd()),'tools','IxiaProxyServer.tcl')
        self._ixia_ip = ixia_ip
        self._ixia_version = {
        '172.16.1.252':'5.60',
        '172.16.11.253':'4.10',
        '172.16.1.247':'5.50',
        'default':'4.10'
        }
        self._tcl_path = {
        '4.10':os.path.join(self._ixia_tcl_path,'ixia410','bin'),
        '5.50':os.path.join(self._ixia_tcl_path,'ixia550','bin'),
        '5.60':os.path.join(self._ixia_tcl_path,'ixia560','bin'),
        'default':os.path.join(self._ixia_tcl_path,'ixia410','bin')
        }
        self._proxy_server_port = listen_port
        self._proxy_server_host = '127.0.0.1'
        self._pkt_streamlist_hexstring = []
        self._pkt_kws = self._lib_kws = None
        self._pkt_class = rfbase.PacketBase()
        self._proxy_server_process = None
        self._proxy_server_retcode = None
        self._ixia_client_handle = None
        self._capture_packet_buffer = {}
        self._capture_filter = {}
        self._start_proxy_server()
        self._start_ixia_client()

    def __del__(self):
        ''''''
        self.shutdown_proxy_server()

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
            excluded = ['get_packet_list','empty_packet_list']
            self._pkt_kws = self._get_keywords(pkt, excluded)
        return self._pkt_kws

    def __getattr__(self, name):
        if name not in self._get_pkt_keywords():
            raise AttributeError(name)
        # This makes it possible for Robot to create keyword
        # handlers when it imports the library.
        return getattr(self._pkt_class, name)

    def _get_stream_from_pcapfile(self,filename):
        '''read pcap file and return bytes stream'''
        if not os.path.isfile(filename):
            logger.info('%s is not a file' % filename)
            raise AssertionError('%s is not file or path error' % filename)
        with open(filename,'rb') as handle:
            return handle.read()

    def build_stream(self):
        ''''''
        self._pkt_streamlist_hexstring = self._pkt_class.get_packet_list()
        self._pkt_class.empty_packet_list()
        return self._pkt_streamlist_hexstring

    def _start_proxy_server(self):
        '''
        '''
        if self._ixia_ip in self._ixia_version.keys():
            version = self._ixia_version[self._ixia_ip]
        else:
            version = self._ixia_version['default']
        cmdpath = os.path.join(self._tcl_path[version],'tclsh.exe')
        if not os.path.exists(cmdpath):
            raise AssertionError('tcl path: %s is not exists' % cmdpath)
        if not os.path.exists(self._proxy_server_path):
            raise AssertionError('prox server file: %s is not exists' % self._proxy_server_path)
        #process \s in path
        proxy_file_sub = re.compile(r'\\([^\\]*\s+[^\\]*)\\')
        proxy_file = proxy_file_sub.sub(r'\\"\1"\\',self._proxy_server_path)
        cmd = '%s %s ixiaip %s bindport %s ixiaversion %s' % (cmdpath,proxy_file,self._ixia_ip,self._proxy_server_port,version)
        p=subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE)
        searchre = re.compile(r'ConnectToIxia success')
        timeout = 0
        while p.poll() is None and timeout < 60:
            time.sleep(1)
            timeout += 1
            rdstr = p.stdout.readline()
            if searchre.search(rdstr):
                break
        if p.returncode is None:
            self._proxy_server_process = p
        else:
            self._proxy_server_retcode = p.returncode

    def _close_proxy_server(self):
        '''
        '''
        shut = False
        if self._proxy_server_process:
            try:
                cmd = 'shutdown_proxy_server\n'
                self._ixia_client_handle.sendall(cmd)
                ret = self._read_ret()
                if ret.strip() == '-10000':
                    shut = True
            except Exception:
                pass
            self._proxy_server_process = None
            return shut

    def _is_proxyserver_live(self):
        '''
        '''
        if self._proxy_server_process:
            try:
                return True if self._proxy_server_process.poll() is None else False
            except Exception:
                return False
        else:
            return False

    def _start_ixia_client(self):
        '''
        '''
        if not self._is_proxyserver_live():
            raise AssertionError('proxy server is not started')
        if self._ixia_client_handle:
            try:
                self._ixia_client_handle.close()
            except Exception:
                self._ixia_client_handle = None
        self._ixia_client_handle = socket.create_connection((self._proxy_server_host, self._proxy_server_port))

    def _close_ixia_client(self):
        '''
        '''
        if self._ixia_client_handle:
            try:
                self._ixia_client_handle.close()
            except Exception:
                pass
        self._ixia_client_handle = None

    def start_transmit(self,chasId,port,card):
        '''
        '''
        cmd = 'start_transmit %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def stop_transmit(self,chasId,port,card):
        '''
        '''
        cmd = 'stop_transmit %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def start_capture(self,chasId,port,card,cap_filter=None):
        '''
        '''
        capture_index = '%s %s' % (port,card)
        self._capture_packet_buffer[capture_index] = []
        self._capture_filter[capture_index] = cap_filter
        cmd = 'start_capture %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def stop_capture(self,chasId,port,card):
        '''
        '''
        cmd = 'stop_capture %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def clear_statics(self,chasId,port,card):
        '''
        '''
        cmd = 'clear_statics %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def _check_transmit_done(self,chasId,port,card):
        '''
        '''
        cmd = 'check_transmit_done %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def get_capture_packet_num(self,chasId,port,card):
        '''
        '''
        cmd = 'get_capture_packet_num %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def set_port_mode_default(self,chasId,port,card):
        '''
        '''
        cmd = 'set_port_mode_default %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def shutdown_proxy_server(self):
        '''
        '''
        shut = self._close_proxy_server()
        self._close_ixia_client()
        return shut

    def _get_capture_packet(self,chasId,port,card,packet_from,packet_to):
        '''
        '''
        cmd = 'get_capture_packet %s %s %s %s %s\n' % (chasId,port,card,packet_from,packet_to)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def get_capture_packet(self,chasId,port,card,packet_from,packet_to):
        '''
        '''
        capture_index = '%s %s' % (port,card)
        packetStr = self._get_capture_packet(chasId,port,card,packet_from,packet_to)
        packetStrList = packetStr.split('$')
        packetList = []
        for pStr in packetStrList:
            pktStr = ''.join(pStr.split())
            chr_ipstr_list = [
                chr(int(pktStr[i:i+2],16)) for i in range(0,len(pktStr)-1,2)
            ]
            chr_ipstr = ''.join(chr_ipstr_list)
            ptk = Ether(chr_ipstr)
            #self._capture_filter[capture_index]
            packetList.append(ptk)
        self._capture_packet_buffer[capture_index] = packetList

    def _read_ret(self):
        '''
        '''
        buff = ''
        try:
            while True:
                c = self._ixia_client_handle.recv(1)
                if c == '\n':
                    break
                buff += c
            return buff
        except Exception:
            self._close_ixia_client()
            raise AssertionError('read return from proxy server error')

    def build_stream(self,chasId,port,card,streamId,streamRate,streamRateMode,streamMode,numFrames=100,ReturnId=1):
        '''
        '''
        streamStr = self._pkt_class.get_packet_list(ixiaFlag=1)
        self._pkt_class.empty_packet_list()
        cmd = 'set_stream_from_hexstr %s %s %s %s %s %s %s %s %s\n' % (chasId,port,card,streamId,streamRateMode,streamRate,streamMode,numFrames,ReturnId)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        return ret.strip()

    def get_statistics(self,chasId,port,card,statisType):
        '''
        args:
        - statisType: txpps,txBps,txbps,txpackets,txbytes,txbits
                      rxpps,rxBps,rxbps,rxpackets,rxbytes,rxbits
        '''
        cmd = 'get_statistics %s %s %s %s\n' % (chasId,port,card,statisType)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret()
        retList = ret.strip().split()
        return retList[0] if len(retList) == 1 else retList


