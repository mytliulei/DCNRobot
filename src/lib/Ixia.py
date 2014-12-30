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
        #self._ixia_tcl_path = os.path.join(os.path.dirname(os.getcwd()),'src','tools','ixia','tcl')
        self._ixia_tcl_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','tools','ixia','tcl')
        self._ixia_pcapfile_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','tools','ixia','pcapfile')
        #self._proxy_server_path = os.path.join(os.path.dirname(os.getcwd()),'src','tools','IxiaProxyServer.tcl')
        self._proxy_server_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','tools','IxiaProxyServer.tcl')
        self._ixia_version = {
            '172.16.1.252':'5.60',
            '172.16.11.253':'4.10',
            '172.16.1.247':'5.50',
            'default':'4.10',
        }
        self._tcl_path = {
            '4.10':os.path.join(self._ixia_tcl_path,'ixia410','bin'),
            '5.50':os.path.join(self._ixia_tcl_path,'ixia550','bin'),
            '5.60':os.path.join(self._ixia_tcl_path,'ixia560','bin'),
            'default':os.path.join(self._ixia_tcl_path,'ixia410','bin'),
        }
        # self._proxy_bind_port = {
        #     '4.10':11917,
        #     '5.50':11916,
        #     '5.60':11915,
        #     'default':11917,
        # }
        self._proxy_bind_port = {
            '4.10':0,
            '5.50':0,
            '5.60':0,
            'default':0,
        }
        self._initFlag = {
            '4.10':False,
            '5.50':False,
            '5.60':False,
            'default':False
        }
        self._proxy_server_auto_bind_port = None
        self._proxy_server_host = '127.0.0.1'
        self._pkt_streamlist_hexstring = []
        self._pkt_kws = self._lib_kws = None
        self._pkt_class = rfbase.PacketBase()
        self._pkt_class._set_ixia_flag(True)
        self._proxy_server_process = None
        self._proxy_server_retcode = None
        self._ixia_client_handle = None
        self._capture_packet_buffer = {}
        self.expect_err_Re = re.compile(r'ixia proxy error buffer end..',re.DOTALL)
        self.expect_ret_Re = re.compile(r'\n')


    def init_ixia(self,ixia_ip,debug=False):
        '''
        start ixia proxy server and connect to ixia;

        Note: in the beginning of every test suit,please use this keyword,in the end of every test suit,the ixia proxy server will be shutdown

        args:
        - ixia_ip: the ip address of ixia

        return:
        - True or False
        '''
        if ixia_ip in self._ixia_version.keys():
            version = self._ixia_version[ixia_ip]
        else:
            version = self._ixia_version['default']
        if self._initFlag[version]:
            return True,True
        proxy_server_port = self._proxy_bind_port[version]
        sRet = self._start_proxy_server(ixia_ip,proxy_server_port,debug)
        if not sRet:
            return False
        #cRet = self._start_ixia_client(proxy_server_port)
        cRet = self._start_ixia_client(self._proxy_server_auto_bind_port)
        nRet = self._connect_ixia(ixia_ip)
        ret = sRet and cRet and nRet == '0'
        if ret:
            self._initFlag[version] = True
        return ret

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
            excluded = ['get_packet_list','empty_packet_list','get_packet_list_ixiaapi']
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

    def _start_proxy_server(self,_ixia_ip,_proxy_server_port,debug=False):
        '''
        '''
        #debug ixia 
        #return True
        if _ixia_ip in self._ixia_version.keys():
            version = self._ixia_version[_ixia_ip]
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
        cmd = '%s %s ixiaip %s bindport %s ixiaversion %s' % (cmdpath,proxy_file,_ixia_ip,_proxy_server_port,version)
        if debug:
            cmd += ' logflag 1'
        p=subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE)
        #p=subprocess.Popen(cmd,shell=True)
        self._proxy_server_process = p
        searchre = re.compile(r'proxy server listen port:(\d+)')
        #self._proxy_server_auto_bind_port
        timeout = 0
        while p.poll() is None and timeout < 60:
            time.sleep(1)
            timeout += 1
            rdstr = p.stdout.readline()
            ret_port = searchre.search(rdstr)
            if ret_port:
                self._proxy_server_auto_bind_port = int(ret_port.groups()[0])
                self._proxy_server_retcode = p.returncode
                return True
        self._proxy_server_retcode = p.returncode
        return False
        #time.sleep(3)
        #if p.poll() is None:
        #    self._proxy_server_retcode = p.returncode
        #    return True
        #self._proxy_server_retcode = p.returncode
        #return False

    def _connect_ixia(self,ixia_ip):
        '''
        '''
        if self._ixia_client_handle:
            cmd = 'connect_ixia %s\n' % ixia_ip
            try:
                self._ixia_client_handle.sendall(cmd)
            except Exception,ex:
                self._close_ixia_client()
                raise AssertionError('client write cmd to proxy server error: %s' % ex)
            readret = self._read_ret_select()
            if not readret[0]:
                raise AssertionError('ixia proxy server error: %s' % readret[1])
            ret = readret[1]
            return ret.strip()

    def _close_proxy_server(self):
        '''
        '''
        shut = False
        if self._proxy_server_process:
            try:
                cmd = 'shutdown_proxy_server\n'
                self._ixia_client_handle.sendall(cmd)
                readret = self._read_ret_select()
                if not readret[0]:
                    raise AssertionError('ixia proxy server error: %s' % readret[1])
                ret = readret[1]
                if ret.strip() == '-10000':
                    shut = True
            except Exception:
                pass
            self._proxy_server_process = None
            return shut

    def _is_proxyserver_live(self):
        '''
        '''
        #debug ixia
        #return True
        if self._proxy_server_process:
            try:
                return True if self._proxy_server_process.poll() is None else False
            except Exception:
                return False
        else:
            return False

    def _is_proxyserver_alive(self,_proxy_server_port,timeout=5):
        '''
        '''
        #debug ixia
        #return True
        try:
            sock = socket.create_connection((self._proxy_server_host, _proxy_server_port))
        except Exception:
            return False
        #test alive
        cmd = 'test_proxy_server alive\n'
        try:
            sock.sendall(cmd)
        except Exception:
            sock.close()
            raise AssertionError('proxy server error')
        import select
        expectRe = re.compile(r'\n')
        buff = ''
        time_start = time.time()
        while True:
            if timeout is not None:
                elapsed = time.time() - time_start
                if elapsed >= timeout:
                    break
                s_args = ([sock], [], [], timeout-elapsed)
                r, w, x = select.select(*s_args)
                if not r:
                    return False
            c = sock.recv(100)
            buff += c
            if expectRe.search(c):
                break
        buff = expectRe.sub('',buff)
        try:
            ret_code = int(buff)
        except Exception:
            return False
        else:
            if ret_code == 0:
                return True
            else:
                return False

    def _start_ixia_client(self,_proxy_server_port):
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
            self._ixia_client_handle = socket.create_connection((self._proxy_server_host, _proxy_server_port))
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

    def _flush_proxy_server(self):
        '''
        '''
        if self._proxy_server_process and self._proxy_server_process.poll() is None:
            c= self._proxy_server_process.stdout.readline()
            return c
        return False

    def start_transmit(self,chasId,card,port):
        '''
        start to transmit stream

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'start_transmit %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def stop_transmit(self,chasId,card,port):
        '''
        stop to transmit stream

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'stop_transmit %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def start_capture(self,chasId,card,port):
        '''
        start to capture stream

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - non zero: error code
        '''
        capture_index = '%s %s %s' % (chasId,card,port)
        self._capture_packet_buffer[capture_index] = []
        cmd = 'start_capture %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def stop_capture(self,chasId,card,port):
        '''
        stop to capture stream

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'stop_capture %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def clear_statics(self,chasId,card,port):
        '''
        clear all statics of ixia port

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'clear_statics %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def wait_for_transmit_done(self,chasId,card,port,timeout=180):
        '''
        wait for transmiting  done

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - timeout: default 180s

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'get_statistics %s %s %s txstate\n' % (chasId,card,port)
        ret = '1'
        time_start = time.time()
        elapsed = time.time() - time_start
        while elapsed <= timeout:
            try:
                self._ixia_client_handle.sendall(cmd)
            except Exception,ex:
                self._close_ixia_client()
                raise AssertionError('client write cmd to proxy server error: %s' % ex)
            readret = self._read_ret_select()
            if not readret[0]:
                raise AssertionError('ixia proxy server error: %s' % readret[1])
            ret = readret[1]
            self._flush_proxy_server()
            if ret.strip() == '0':
                break
            elapsed = time.time() - time_start
        return ret.strip()

    def get_capture_packet_num(self,chasId,card,port):
        '''
        get capture packet num,please use this keyword after Start Capture and Stop Capture

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - timeout: default 180s

        return:
        - non negative number: num of capture packet
        - negative number: error code
        '''
        cmd = 'get_capture_packet_num %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def set_port_mode_default(self,chasId,card,port):
        '''
        set ixia port default,please use this keyword before Set Stream Packet

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'set_port_mode_default %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def shutdown_proxy_server(self):
        '''
        shutdown proxy sever

        Note: Do not use this keyword unless you know what you are doing

        args:

        return:
        - True or False
        '''
        shut = self._close_proxy_server()
        self._close_ixia_client()
        return shut

    def _get_capture_packet(self,chasId,card,port,packet_from,packet_to):
        '''
        '''
        cmd = 'get_capture_packet %s %s %s %s %s\n' % (chasId,card,port,packet_from,packet_to)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def get_capture_packet(self,chasId,card,port,packet_from=1,packet_to=1000):
        '''
        get capture packet, and save internally

        Note:please use this keyword after Start Capture and Stop Capture

        args:
        - chasId:        normally should be 1
        - card:          ixia card
        - port:          ixia port
        - packet_from:   default 1
        - packet_to:     default 1000, and will be adjust by actual capture num

        return:
        - non negative number: num of capture packet
        - negative number: error code
        '''
        capture_index = '%s %s %s' % (chasId,card,port)
        packetStr = self._get_capture_packet(chasId,card,port,packet_from,packet_to)
        if not packetStr:
            return 0
        packetStrList = packetStr.split('$')
        try:
            err_code = int(packetStr)
        except Exception:
            pass
        else:
            return err_code
        packetList = []
        n = 0
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
            n += 1
        self._capture_packet_buffer[capture_index] = packetList
        return n

    def clear_capture_packet(self,chasId,card,port):
        '''
        clear saved capture packet

        Note:Start Capture will clear saved capture packet automatically

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - negative number: error code
        '''
        capture_index = '%s %s %s' % (chasId,card,port)
        self._capture_packet_buffer[capture_index] = None
        return 0

    def filter_capture_packet(self,chasId,card,port,capFilter=None):
        '''
        filter the capture packet,and return a list including filter num and filter packets

        Note:please use this keyword after Get Capture Packet

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - capFilter: filter expression, default None,not filter capture packets;to know detail information,please visit http://www.ferrisxu.com/WinPcap/html/index.html

        return:
        - (num of filter,packet of filter)
        '''
        capture_index = '%s %s %s' % (chasId,card,port)
        if capture_index not in self._capture_packet_buffer.keys():
            return -2,[]
        if self._capture_packet_buffer[capture_index] is None:
            return -1,[]
        if not self._capture_packet_buffer[capture_index]:
            return 0,[]
        if capFilter:
            if not issubclass(type(capFilter),basestring):
                raise AssertionError('capFilter must be a string')
            try:
                import pcapy
            except Exception:
                raise AssertionError('can not load pcap,may be not installed')
            try:
                matchPkt = pcapy.compile(pcapy.DLT_EN10MB,1500,capFilter,1,0xffffff)
            except Exception:
                raise AssertionError('filter express error')
        else:
            matchPkt = None
        #filter packet
        pktFiltered = []
        i = 0
        for ipkt in self._capture_packet_buffer[capture_index]:
            if not matchPkt or matchPkt.filter(str(ipkt)) > 0:
                pktFiltered.append(ipkt)
                i += 1
        return i,pktFiltered

    def modify_capture_packet(self,pkt,offset=None,hexstring=None):
        '''
        modify a capture packet using offset and hexstr

        Note:please use this keyword after Filter Capture Packet

        args:
        - packet:    the item in list of the sencond return value of Filter Capture Packet or the return value of itself to continue modify
        - offset:    offset of hexstr packet
        - hexstr:    a byte hexstr using space to split, for exapmle: 'FF 00'

        return:
        - packet of scapy format
        '''
        try:
            pStr = hexstr(str(pkt),0,1)
        except Exception,ex:
            raise AssertionError('packet format is error: %s' % ex)
        if issubclass(type(offset),basestring):
            if offset.startswith('0x'):
                offset = int(offset,16)
            else:
                offset = int(offset)
        #modify packet using offset and hexstr
        if offset and hexstring:
            mod_pkt_list = pStr.split()
            hexstr_list = hexstring.split()
            for mp in hexstr_list:
                mod_pkt_list[offset] = mp
                offset += 1
            pStr = ' '.join(mod_pkt_list)
        #transfer packet into scapy cmd str
        pktStr = ''.join(pStr.split())
        if len(pktStr) % 2 == 1:
            raise AssertionError('get capture packet error:pkt str is not even')
        chr_ipstr_list = [
            chr(int(pktStr[i:i+2],16)) for i in range(0,len(pktStr)-1,2)
        ]
        chr_ipstr = ''.join(chr_ipstr_list)
        ret_pkt = Ether(chr_ipstr)
        return ret_pkt

    def set_stream_packet_by_capture(self,chasId,card,port,streamId,pkt):
        '''
        set a capture packet on stream of ixia port

        Note:please use this keyword after Modify Capture Packet or Filter Capture Packet

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - streamId: stream id
        - packet:   the return value of keyword Modify Capture Packet or the item in list of the sencond return value of Filter Capture Packet

        return:
        - 0: ok
        - non zero: error code
        '''
        try:
            pStr = hexstr(str(pkt),0,1)
        except Exception,ex:
            raise AssertionError('packet format is error: %s' % ex)
        streamStr = '#'.join(pStr.split())
        cmd = 'set_stream_from_hexstr %s %s %s %s %s\n' % (chasId,card,port,streamId,streamStr)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()


    def _save_capture_packet(self,chasId,card,port):
        '''
        write the capture packet,normally saved in the path tools/ixia/pcapfile/

        Note:please use this keyword after Get Capture Packet

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - pcap file name including path
        '''
        capture_index = '%s %s %s' % (chasId,card,port)
        if capture_index not in self._capture_packet_buffer.keys():
            return -2
        if self._capture_packet_buffer[capture_index] is None:
            return -1
        if not os.path.exists(self._ixia_pcapfile_path):
            raise AssertionError('pcapfile path: %s is not exists' % self._ixia_pcapfile_path)
        import hashlib
        fn_hash = hashlib.md5('%s %s' % (time.time(),capture_index))
        filename = fn_hash.hexdigest()
        pcapfname = os.path.join(self._ixia_pcapfile_path,filename)
        try:
            wrpcap(pcapfname,self._capture_packet_buffer[capture_index])
        except Exception,ex:
            raise AssertionError('write pcap file %s error: %s' % (pcapfname,ex))
        return pcapfname

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

    # def build_stream(self,chasId,card,port,streamId,streamRate,streamRateMode,streamMode,numFrames=100,ReturnId=1):
    #     '''
    #     '''
    #     streamStr = self._pkt_class.get_packet_list(ixiaFlag=True)
    #     self._pkt_class.empty_packet_list()
    #     cmd = 'set_stream_from_hexstr %s %s %s %s %s %s %s %s %s %s\n' % (chasId,card,port,streamId,streamRateMode,streamRate,streamMode,numFrames,ReturnId,streamStr)
    #     try:
    #         self._ixia_client_handle.sendall(cmd)
    #     except Exception:
    #         self._close_ixia_client()
    #         raise AssertionError('write cmd to proxy server error')
    #     readret = self._read_ret_select()
    #     if not readret[0]:
    #         raise AssertionError('ixia proxy server error: %s' % readret[1])
    #     ret = readret[1]
    #     return ret.strip()

    def set_stream_packet_by_datapattern(self,chasId,card,port,streamId):
        '''
        set a packet on stream of ixia port

        Note:please use this keyword after Build Packet

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - streamId: stream id

        return:
        - 0: ok
        - non zero: error code
        '''
        streamStr = self._pkt_class.get_packet_list(ixiaFlag=True)
        self._pkt_class.empty_packet_list()
        cmd = 'set_stream_from_hexstr %s %s %s %s %s\n' % (chasId,card,port,streamId,streamStr)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def set_stream_packet_by_api(self,chasId,card,port,streamId,fcs=0):
        '''
        set a packet on stream of ixia port

        Note:please use this keyword after Build Packet

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - streamId: stream id
        - fcs:    0: streamErrorGood
                  1: streamErrorAlignment
                  2: streamErrorDribble
                  3: streamErrorBadCRC
                  4: streamErrorNoCRC

        return:
        - 0: ok
        - non zero: error code
        '''
        streamStr = self._pkt_class.get_packet_list_ixiaapi()
        self._pkt_class.empty_packet_list()
        cmd = 'set_stream_from_ixiaapi %s %s %s %s %s %s\n' % (chasId,card,port,streamId,fcs,streamStr)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def set_stream_control(self,chasId,card,port,streamId,streamRate,streamRateMode,streamMode,numFrames=100,ReturnId=1):
        '''
        set stream trasmit mode

        Note:please use this keyword after Set Stream Packet

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - streamId: stream id
        - streamRate: stream send rate
        - streamRateMode: 0:percent ; 1: pps ; 2: bps
        - streamMode: stream control mode;
          0: continuously transmit the frames on this stream;
          1: stop transmission
          2: advance
          3: return to id ,default to stream 1
        - numFrames: stream send packet num,enable when streamMode 1,2,3; default 100
        - ReturnId: enable when streamMode 4 ,default 1

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'set_stream_control %s %s %s %s %s %s %s %s %s\n' % (chasId,card,port,streamId,streamRateMode,streamRate,streamMode,numFrames,ReturnId)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def _set_stream_enable(self,chasId,card,port,streamId,flag):
        '''
        #take no effect,ixia bug
        1: enable
        0: disable
        '''
        cmd = 'set_stream_enable %s %s %s %s %s\n' % (chasId,card,port,streamId,flag)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def get_statistics(self,chasId,card,port,statisType,*args):
        '''
        get port statics

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - statisType: txpps,txBps,txbps,txpackets,txbytes,txbits
                      rxpps,rxBps,rxbps,rxpackets,rxbytes,rxbits
                      updown: 0:down,1:up;
                      txstate: 0:stop,1:start;
                      lineSpeed: The speed configured for the port,unit:Mbps;
                      duplex: 0:half,1:full;
                      flowControlFrames : flow Control Frames Received

        return:
        - non negative number: statics num
        - negative number: error code
        '''
        cmd = 'get_statistics %s %s %s %s' % (chasId,card,port,statisType)
        if args:
            for iarg in args:
                cmd += ' %s' % iarg
        cmd += '\n'
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        retList = ret.strip().split()
        return retList[0] if len(retList) == 1 else retList

    def set_port_speed_duplex(self,chasId,card,port,mode,mulchoice):
        '''
        set port speed duplex

        note: this keyword will cause the port updown and use the keyword of Set Port Config Default to clear this config in the end of testcase

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - mode:   0: autonegotiate;
                  1: force1gfull; *Note: force1gfull will not take effect on ixia*
                  2: force100full;
                  3: force100half;
                  4: force10full;
                  5: force10half;
                  6: no autonegotiate, used for fiber port normally
                  -1: autonegotiate,but type of autonegotiate must be assigned by mulchoice
        - mulchoice: take effect when mode be -1,must be a list including below choice
                  1: force1gfull; *Note: force1gfull will not take effect on ixia*
                  2: force100full;
                  3: force100half;
                  4: force10full;
                  5: force10half;

        return:
        - 0: ok
        - non zero: error code
        '''
        if issubclass(type(mode),basestring):
            mode = int(mode)
        if mode == -1:
            mulchoice = ';'.join(mulchoice)
        if not mulchoice:
            mulchoice = '0'
        cmd = 'set_port_speed_duplex %s %s %s %s %s\n' % (chasId,card,port,mode,mulchoice)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def set_port_flowcontrol(self,chasId,card,port,flag):
        '''
        set port flowcontrol

        note: this keyword will cause the port updown and use set port config default to clear this config in the end of testcase

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - flag:   0: disable;
                  1: enable;
        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'set_port_flowcontrol %s %s %s %s\n' % (chasId,card,port,flag)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def set_port_ignorelink(self,chasId,card,port,flag):
        '''
        set port ignore link

        note:
        - this keyword normally should be used when send stream if port down;
        - this keyword will cause the port updown and use set port config default to clear this config in the end of testcase

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port
        - flag:   0: false; ignore link disable
                  1: true; ignore link enable
        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'set_port_ignorelink %s %s %s %s\n' % (chasId,card,port,flag)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def set_port_config_default(self,chasId,card,port):
        '''
        set ixia port default,please use this keyword after set port flowcontrol or set port speed duplex to clear the config

        note: this keyword will clear the stream config and cause the port updown

        args:
        - chasId: normally should be 1
        - card:   ixia card
        - port:   ixia port

        return:
        - 0: ok
        - non zero: error code
        '''
        cmd = 'set_port_config_default %s %s %s\n' % (chasId,card,port)
        try:
            self._ixia_client_handle.sendall(cmd)
        except Exception,ex:
            self._close_ixia_client()
            raise AssertionError('client write cmd to proxy server error: %s' % ex)
        readret = self._read_ret_select()
        if not readret[0]:
            raise AssertionError('ixia proxy server error: %s' % readret[1])
        ret = readret[1]
        self._flush_proxy_server()
        return ret.strip()

    def _fileno(self):
        """Return the fileno() of the socket object used internally."""
        return self._ixia_client_handle.fileno()

    def _read_ret_select(self,timeout=180):
        '''
        '''
        import select
        #expectRe = re.compile(r'\n')
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
            if self.expect_ret_Re.search(c):
                break
        buff = self.expect_ret_Re.sub('',buff)
        try:
            ret_code = int(buff)
        except Exception:
            pass
        else:
            if -999<= ret_code < -900:
                errbuffer = self._read_err_select()
                return False,errbuffer
            else:
                pass
        return True,buff

    def _read_err_select(self,timeout=180):
        '''
        '''
        import select
        #expectRe = re.compile(r'ixia proxy error buffer end..',re.DOTALL)
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
            if self.expect_err_Re.search(buff):
                break
        buff = self.expect_err_Re.sub('',buff)
        return buff
