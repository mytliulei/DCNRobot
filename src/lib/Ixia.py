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
import select

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
    def __init__(self):
        ''''''
        self._ixia_tcl_path = os.path.join(os.path.dirname(os.getcwd()),'src','tools','ixia','tcl')
        self._proxy_server_path = os.path.join(os.path.dirname(os.getcwd()),'src','tools','IxiaProxyServer.tcl')
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
        self._proxy_server_host = '127.0.0.1'
        self._pkt_streamlist_hexstring = []
        self._pkt_kws = self._lib_kws = None
        self._pkt_class = rfbase.PacketBase()
        self._proxy_server_process = None
        self._proxy_server_retcode = None
        self._ixia_client_handle = None
        self._capture_packet_buffer = {}

    def init_ixia(self,ixia_ip,listen_port=11917):
        '''
        '''
        self._ixia_ip = ixia_ip
        self._proxy_server_port = listen_port
        sRet = self._start_proxy_server()
        cRet = self._start_ixia_client()
        return sRet and cRet

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
        self._proxy_server_process = p
        searchre = re.compile(r'ConnectToIxia success')
        timeout = 0
        while p.poll() is None and timeout < 60:
            time.sleep(1)
            timeout += 1
            rdstr = p.stdout.readline()
            if searchre.search(rdstr):
                self._proxy_server_retcode = p.returncode
                return True
        self._proxy_server_retcode = p.returncode
        return False

    def _close_proxy_server(self):
        '''
        '''
        shut = False
        if self._proxy_server_process:
            try:
                cmd = 'shutdown_proxy_server\n'
                self._ixia_client_handle.sendall(cmd)
                ret = self._read_ret_select()
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
        try:
            self._ixia_client_handle = socket.create_connection((self._proxy_server_host, self._proxy_server_port))
        except Exception:
            self._ixia_client_handle = None
            return False
        return True

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
        ret = self._read_ret_select()
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
        ret = self._read_ret_select()
        return ret.strip()

    def start_capture(self,chasId,port,card):
        '''
        '''
        capture_index = '%s %s' % (port,card)
        self._capture_packet_buffer[capture_index] = []
        cmd = 'start_capture %s %s %s\n' % (chasId,port,card)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret_select()
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
        ret = self._read_ret_select()
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
        ret = self._read_ret_select()
        return ret.strip()

    def wait_for_transmit_done(self,chasId,port,card,timeout=180):
        '''
        '''
        cmd = 'get_statistics %s %s %s txstate\n' % (chasId,port,card)
        ret = '1'
        time_start = time.time()
        elapsed = time.time() - time_start
        while elapsed <= timeout:
            try:
                self._ixia_client_handle.sendall(cmd)
            except Exception:
                self._close_ixia_client()
                raise AssertionError('write cmd to proxy server error')
            ret = self._read_ret_select()
            if ret.strip() == '0':
                break
            elapsed = time.time() - time_start
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
        ret = self._read_ret_select()
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
        ret = self._read_ret_select()
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
        ret = self._read_ret_select()
        return ret.strip()

    def get_capture_packet(self,chasId,port,card,packet_from,packet_to):
        '''
        '''
        capture_index = '%s %s' % (port,card)
        packetStr = self._get_capture_packet(chasId,port,card,packet_from,packet_to)
        packetStrList = packetStr.split('$')
        packetList = []
        i = 0
        for pStr in packetStrList:
            pktStr = ''.join(pStr.split())
            if len(pktStr) % 2 == 1:
                raise AssertionError('get capture packet error:pkt str is not even')
            chr_ipstr_list = [
                chr(int(pktStr[i:i+2],16)) for i in range(0,len(pktStr)-1,2)
            ]
            chr_ipstr = ''.join(chr_ipstr_list)
            ptk = Ether(chr_ipstr)
            packetList.append(ptk)
            i += 1
        self._capture_packet_buffer[capture_index] = packetList
        return i

    def filter_capture_packet(self,,chasId,port,card,capFilter):
        '''
        '''
        capture_index = '%s %s' % (port,card)
        if capture_index not in self._capture_packet_buffer.keys():
            return 0
        if not self._capture_packet_buffer[capture_index]:
            return 0
        if type(capFilter) is not str:
            raise AssertionError('capFilter must be a string')
        import pcapy
        try:
            matchPkt = pcapy.compile(pcapy.DLT_EN10MB,1500,capFilter,1,0xffffff)
        except Exception:
            raise AssertionError('filter express error')
        #filter packet 
        pktFiltered = []
        i = 0
        for ipkt in self._capture_packet_buffer[capture_index]:
            if matchPkt.filter(str(ipkt)) > 0:
                pktFiltered.append(ipkt)
                i += 1
        return i,pktFiltered

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
        streamStr = self._pkt_class.get_packet_list(ixiaFlag=True)
        self._pkt_class.empty_packet_list()
        cmd = 'set_stream_from_hexstr %s %s %s %s %s %s %s %s %s %s\n' % (chasId,port,card,streamId,streamRateMode,streamRate,streamMode,numFrames,ReturnId,streamStr)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret_select()
        return ret.strip()

    def get_statistics(self,chasId,port,card,statisType,*args):
        '''
        args:
        - statisType: txpps,txBps,txbps,txpackets,txbytes,txbits
                      rxpps,rxBps,rxbps,rxpackets,rxbytes,rxbits
                      updown: 0:down,1:up;
                      txstate: 0:stop,1:start;
        '''
        cmd = 'get_statistics %s %s %s %s' % (chasId,port,card,statisType)
        if args:
            for iarg in args:
                cmd += ' %s' % iarg
        cmd += '\n'
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception:
            self._close_ixia_client()
            raise AssertionError('write cmd to proxy server error')
        ret = self._read_ret_select()
        retList = ret.strip().split()
        return retList[0] if len(retList) == 1 else retList

    def _fileno(self):
        """Return the fileno() of the socket object used internally."""
        return self._ixia_client_handle.fileno()

    def _read_ret_select(self,timeout=180):
        '''
        '''
        import select
        expectRe = re.compile(r'\n')
        buff = ''
        time_start = time.time()
        while True:
            if timeout is not None:
                elapsed = time.time() - time_start
                if elapsed >= timeout:
                    break
                s_args = ([self._fileno()], [], [], timeout-elapsed)
                r, w, x = select.select(*s_args)
                if not r:
                    break
            c = self._ixia_client_handle.recv(100)
            buff += c
            if expectRe.search(c):
                break
        buff = expectRe.sub('',buff)
        return buff
