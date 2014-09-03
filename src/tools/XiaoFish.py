#!/usr/bin/env python
#-*- coding: UTF-8 -*-
'''network stream genertor,for RF testing base on XMLRPC and scapy

   ps: XiaoFish is a little cat, bless her. :)
'''


import os,os.path
import sys
import StringIO
import threading
import select
import time
import traceback

import daemonocle
import robotremoteserver
from scapy.all import *


__version__ = '0.1'
__author__ = 'liuleic'
__copyright__ = 'Copyright 2014, DigitalChina Network'
__license__ = 'Apache License, Version 2.0'
__mail__ = 'liuleic@digitalchina.com'


class XiaoFish(object):
    '''
    '''
    def __init__(self,iflist=None):
        ''''''
        self.ifList = iflist
        if iflist:
            #ifnumlist = [str(i) for i in range(1,len(iflist)+1)]
            self._ifDict = {str(i+1):iflist[i] for i in range(len(iflist))}
            ifilenamelist = ['xiaofish_'+name+'.pcap' for name in iflist]
            self._ifileDict = {str(i+1):ifilenamelist[i] for i in range(len(ifilenamelist))}
            self._sendThreadDict = {str(i+1):None for i in range(len(iflist))}
            self._capThreadDict = {str(i+1):None for i in range(len(iflist))}
            self._ifstatsThreadDict = {str(i+1):None for i in range(len(iflist))}
        else:
            self._ifDict = {}
            self._ifileDict = {}
            self._sendThreadDict = {}
            self._capThreadDict = {}
            self._ifstatsThreadDict = {}
        self._packetDict = {}
        self._packetLenDict = {}
        #self._sendThreadDict = {}
        #self._sendThreadStatsDict = {}
        #self._capThreadDict = {}
        #self._capThreadStatsDict = {}
        #self._ifStatsDict = {}
        self.ifilePath = '/tmp'
        #if stats thread
        #self._ifstats_thread = None
        if iflist:
            self._start_ifstats()

    def _start_ifstats(self):
        if not self.ifList:
            raise AssertionError("Not attach any iface in XiaoFish RobotRemoteServer")
            return False
        for i in range(len(self.ifList)):
            self._ifstatsThreadDict[str(i+1)] = XFIfStats(self.ifList[i])
            if not self._ifstatsThreadDict[str(i+1)].verify_if_file():
                self._ifstatsThreadDict[str(i+1)] = None
                raise AssertionError("can not find /sys/class/net path,stats thread can not start")
                return False
            #start thread
            self._ifstatsThreadDict[str(i+1)].setDaemon(True)
            self._ifstatsThreadDict[str(i+1)].start()

    def init_xfsend(self):
        ''''''
        if self.ifList:
            for i in self._ifDict.keys():
                self.stop_stream(i)
                self.stop_capture(i)
        return 0

    def _get_iface_list(self):
        ''''''
        return self.ifList

    def set_stream_from_hexstr(self,ifNum,packetStrList):
        ''''''
        if type(packetStrList) is not list:
            raise AssertionError("parameter packetStrList is not list")
            return -2
        if not self.ifList:
            raise AssertionError("Not attach any iface in XiaoFish RobotRemoteServer")
            return -1
        if ifNum not in self._ifDict.keys():
            raise AssertionError("iface num %s not in iface List" % ifNum)
            return -1
        try:
            packetList = []
            for ipstr in packetStrList:
                if len(ipstr) % 2 == 1:
                    raise AssertionError('hexstr is not even')
                chr_ipstr_list = [
                    chr(int(ipstr[i:i+2],16)) for i in range(0,len(ipstr)-1,2)
                ]
                chr_ipstr = ''.join(chr_ipstr_list)
                packetList.append(Ether(chr_ipstr))
        except Exception,ex:
            raise AssertionError("can not convert %s to Packet on iface %s" % (ipstr,ifNum))
            return -1
        self._packetDict[ifNum] = packetList
        self._packetLenDict[ifNum] = len(self._packetDict[ifNum])
        return 0

    def set_stream_from_scapy(self,ifNum,packetStrList):
        ''''''
        if type(packetStrList) is not list:
            raise AssertionError("parameter packetStrList is not list")
            return -2
        if not self.ifList:
            raise AssertionError("Not attach any iface in XiaoFish RobotRemoteServer")
            return -1
        if ifNum not in self._ifDict.keys():
            raise AssertionError("iface num %s not in iface List" % ifNum)
            return -1
        try:
            packetList = []
            for ipstr in packetStrList:
                cmd = 'p=' + ipstr
                exec(cmd)
                packetList.append(p)
        except Exception,ex:
            raise AssertionError("can not convert %s to Packet on iface %s: %s" % (ipstr,ifNum,traceback.format_exc()))
            return -1
        self._packetDict[ifNum] = packetList
        self._packetLenDict[ifNum] = len(self._packetDict[ifNum])
        return 0

    @staticmethod
    def _verify_raw(rawstr):
        ''''''
        chr_ipstr_list = [
            chr(int(rawstr[i:i+2],16)) for i in range(0,len(rawstr)-1,2)
        ]
        cmd = "p=Raw(''.join(chr_ipstr_list))"
        try:
            exec(cmd)
        except Exception,ex:
            return Raw()
        else:
            return p

    def set_stream_from_pcap(self,ifNum,packetbytes):
        ''''''
        if not self.ifList:
            raise AssertionError("Not attach any iface in XiaoFish RobotRemoteServer")
            return -1
        if ifNum not in self._ifDict.keys():
            raise AssertionError("iface num %s not in iface List" % ifNum)
            return -1
        filename = os.path.join(self.ifilePath, self._ifileDict[ifNum])
        if not self._write_pcapfile_xf(filename,packetbytes):
            raise AssertionError("wirte %s fail" % filename)
            return -1
        if not self._read_pcapfile_xf(ifNum,filename):
            return -1
        self._packetLenDict[ifNum] = len(self._packetDict[ifNum])
        return 0

    def _read_pcapfile_xf(self,ifNum,filename):
        if ifNum not in self._ifDict.keys():
            return False
        try:
            p = rdpcap(filename)
        except Exception,ex:
            raise AssertionError("read %s fail:%s" % (filename,ex))
            return False
        self._packetDict[ifNum] = p
        return True

    def _write_pcapfile_xf(self,filename,packetbytes):
        with open(filename,'wb') as fhandler:
            fhandler.write(packetbytes)
        return True

    def get_stream(self,ifNum,num=0):
        ''''''
        if type(num) is str:
            num = int(num)
        packet = ''
        old_stdout = sys.stdout
        packetout = StringIO.StringIO()
        sys.stdout = packetout
        try:
            if num > 0:
                if num <= self._packetLenDict[ifNum]:
                    print 'packet num %i:' % num
                    self._packetDict[ifNum][num-1].show()
            elif num == 0:
                for i in range(self._packetLenDict[ifNum]):
                    print 'packet num %i:' % (i+1)
                    self._packetDict[ifNum][i].show()
            else:
                print ''
        except Exception,ex:
            packet = ''
            sys.stdout = old_stdout
            raise AssertionError("read iface %s stream %s fail: %s" % (self._ifDict[ifNum],num,ex))
        else:
            packet += packetout.getvalue()
            sys.stdout = old_stdout
        return packet

    def _modify_stream(self,iface,*args):
        ''''''
        pass

    def send_stream(self,ifNum,count=1,interval=0):
        ''''''
        if type(interval) is str:
            interval = float(interval)
        if type(count) is str:
            count = int(count)
        if ifNum not in self._ifDict.keys():
            return -2
        #iface_name = self._ifDict[ifNum]s4s4ss
        if self._sendThreadDict and self._sendThreadDict[ifNum] and self._sendThreadDict[ifNum].isAlive():
            return self._sendThreadDict[ifNum].xfstats
        try:
            self._sendThreadDict[ifNum] = XFSend(
                self._ifDict[ifNum],self._packetDict[ifNum],
                count,interval
                )
            self._sendThreadDict[ifNum].setDaemon(True)
            self._sendThreadDict[ifNum].start()
        except Exception,ex:
            self._sendThreadDict[ifNum] = None
            raise AssertionError("send iface %s stream fail: %s" % (self._ifDict[ifNum],ex))
            return -3
        return 0

    def stop_stream(self,ifNum):
        ''''''
        if ifNum not in self._ifDict.keys():
            return -2
        if not self._sendThreadDict or not self._sendThreadDict[ifNum]:
            return -1
        if self._sendThreadDict[ifNum].xfstats == -1:
            return 1
        elif self._sendThreadDict[ifNum].xfstats == 0:
            return 2
        elif self._sendThreadDict[ifNum].xfstats == -2:
            return -3
        #stop send
        self._sendThreadDict[ifNum].xfstats = 0
        return 0

    def get_send_stream_num(self,ifNum):
        ''''''
        if ifNum not in self._ifDict.keys():
            return 0
        if not self._sendThreadDict or not self._sendThreadDict[ifNum]:
            return 0
        return self._sendThreadDict[ifNum].xfsendnum

    def get_send_stream_status(self,ifNum):
        '''return status
           - -2 : error
           - -1 : ready to start
           -  1 : running
           -  0 : stoping
        '''
        if ifNum not in self._ifDict.keys():
            return -2
        if not self._sendThreadDict or not self._sendThreadDict[ifNum]:
            return -2
        return self._sendThreadDict[ifNum].xfstats

    def capture_packet(self,ifNum,filter=None,timeout=None,count=0):
        ''''''
        if type(filter) is str and filter == '':
            filter = None
        if type(timeout) is str and timeout == '':
            timeout = None
        if type(timeout) is str:
            timeout = float(timeout)
        if ifNum not in self._ifDict.keys():
            return -2
        if self._capThreadDict and self._capThreadDict[ifNum] and self._capThreadDict[ifNum].isAlive():
            return self._capThreadDict[ifNum].xfstats
        try:
            self._capThreadDict[ifNum] = XFCapture(
                self._ifDict[ifNum],timeout,filter,count)
            self._capThreadDict[ifNum].setDaemon(True)
            self._capThreadDict[ifNum].start()
        except Exception,ex:
            self._capThreadDict[ifNum] = None
            raise AssertionError("capture iface %s stream fail: %s" % (self._ifDict[ifNum],ex))
            return -3
        time.sleep(1)
        return 0

    def stop_capture(self,ifNum):
        ''''''
        if ifNum not in self._ifDict.keys():
            return -2
        if not self._capThreadDict or not self._capThreadDict[ifNum]:
            return -1
        if self._capThreadDict[ifNum].xfstats == -1:
            return 1
        elif self._capThreadDict[ifNum].xfstats == 0:
            return 2
        elif self._capThreadDict[ifNum].xfstats == -2:
            #return self._capThreadDict[ifNum].errmsg
            return -3
        #stop send
        self._capThreadDict[ifNum].xfstats = 0
        #self._capThreadDict[ifNum].xf_stop_capture()
        return 0

    def get_capture_packet_num(self,ifNum):
        ''''''
        if ifNum not in self._ifDict.keys():
            return -2
        if not self._capThreadDict or not self._capThreadDict[ifNum]:
            return -1
        return self._capThreadDict[ifNum].xfcapnum

    def get_capture_packet(self,ifNum):
        ''''''
        if ifNum not in self._ifDict.keys():
            return -3
        if not self._capThreadDict or not self._capThreadDict[ifNum]:
            return -1
        if self._capThreadDict[ifNum].xfstats == 1:
            return 1
        elif self._capThreadDict[ifNum].xfstats == 0:
            return 0
        elif self._capThreadDict[ifNum].xfstats == -2:
            return -2
        return str(self._capThreadDict[ifNum].xfcappacket)

    def get_capture_status(self,ifNum):
        '''return status
           - -2 : error
           - -1 : ready to start or stoped
           -  1 : running
           -  0 : in stoping
        '''
        if ifNum not in self._ifDict.keys():
            return -2
        if not self._capThreadDict or not self._capThreadDict[ifNum]:
            return -2
        return self._capThreadDict[ifNum].xfstats

    def get_statics(self,ifNum,stats=None):
        '''get if stats 

            stats args: string list
            - rxpackets
            - rxbytes
            - rxpps
            - rxBps
            - txpackets
            - txbytes
            - txpps
            - txBps

            return: stats list

            example:
            - get_statics('1',['rxpps','txpps']) 
        '''
        if type(stats) is str and stats == '':
            stats = None
        if ifNum not in self._ifDict.keys():
            raise AssertionError("get_statics fail: %s not in ifList" % ifNum)
            return -2
        #iface = self._ifDict[ifNum]
        strflag = False
        if type(stats) is str:
            strflag = True
            stats = list(stats)
        if stats:
            stats = ['xf'+istats for istats in stats]
        get_stats = stats or ['xfrxpackets','xfrxbytes','xfrxpps','xfrxBps',
                              'xftxpackets','xftxbytes','xftxpps','xftxBps'
                             ]
        ret_stats = []
        if not self._ifstatsThreadDict or not self._ifstatsThreadDict[ifNum]:
            raise AssertionError("get_statics fail: _ifstatsThreadDict not start")
            return -2
        for istats in get_stats:
            if hasattr(self._ifstatsThreadDict[ifNum],istats):
                stats_num = getattr(self._ifstatsThreadDict[ifNum],istats)
                ret_stats.append(stats_num)
        if strflag:
            return(ret_stats[0])
        return ret_stats

    def clear_statics(self,ifNum):
        ''''''
        if ifNum not in self._ifDict.keys():
            raise AssertionError("clear_statics fail: %s not in ifList" % ifNum)
            return -2
        #iface = self._ifDict[ifNum]
        if not self._ifstatsThreadDict or not self._ifstatsThreadDict[ifNum]:
            raise AssertionError("clear_statics fail: _ifstatsThreadDict not start")
            return -2
        self._ifstatsThreadDict[ifNum].clear_stats()
        time.sleep(self._ifstatsThreadDict[ifNum].xftimeout)
        return 0


class XFSend(threading.Thread):
    '''send packet thread'''
    def __init__(self,iface,packet,count,timeout,*args,**kwargs):
        '''xfstats -1: pending
                    1: running
                    0: stop
                   -2: error
        '''
        threading.Thread.__init__(self,*args,**kwargs)
        self._iface = iface
        self._sendPacket = packet
        self._xfcount = count
        self._xftimeout = timeout
        self._xfstats = -1
        self._xfsendnum = 0
        self._args = args
        self._kwargs = kwargs
        self.errmsg = ''

    def start(self):
        ''''''
        self._xfstats = 1
        self._xfsendnum = 0
        threading.Thread.start(self)

    @property
    def xfstats(self):
        return self._xfstats

    @xfstats.setter
    def xfstats(self, value):
        self._xfstats = value

    @property
    def sendPacket(self):
        return self._sendPacket
    @sendPacket.setter
    def sendPacket(self, value):
        self._sendPacket = value

    @property
    def xfcount(self):
        return self._xfcount
    @xfcount.setter
    def xfcount(self, value):
        self._xfcount = value

    @property
    def xftimeout(self):
        return self._xftimeout
    @xftimeout.setter
    def xftimeout(self, value):
        self._xftimeout = value

    @property
    def xfsendnum(self):
        return self._xfsendnum

    def run(self):
        ''''''
        try:
            if self._xfcount > 0:
                self.xfsendp(
                    self._sendPacket,iface=self._iface,loop=0,
                    count=self._xfcount,inter=self._xftimeout,*self._args,
                    **self._kwargs
                    )
            else:
                self.xfsendp(
                    self._sendPacket,iface=self._iface,loop=1,
                    inter=self._xftimeout,*self._args,**self._kwargs
                    )
        except Exception,ex:
            self._xfstats = -2
            self._xfsendnum = 0
            self.errmsg = str(ex)
        else:
            self._xfstats = -1

    def xfsendp(self,x, inter=0, loop=0, iface=None, iface_hint=None, count=None, verbose=None, realtime=None, *args, **kargs):
        '''override sendp'''
        if iface is None and iface_hint is not None:
            iface = conf.route.route(iface_hint)[0]
        self.__xf__gen_send(conf.L2socket(iface=iface, *args, **kargs), x, inter=inter, loop=loop, count=count, verbose=verbose, realtime=realtime)

    def __xf__gen_send(self,s, x, inter=0, loop=0, count=None, verbose=None, realtime=None, *args, **kargs):
        '''override __gen__send'''
        if type(x) is str:
            x = Raw(load=x)
        if not isinstance(x, Gen):
            x = SetGen(x)
        #if verbose is None:
            #verbose = conf.verb
        verbose = None
        #n = 0
        self._xfsendnum = 0
        if count is not None:
            loop = -count
        elif not loop:
            loop=-1
        dt0 = None
        try:
            while loop:
                for p in x:
                    if realtime:
                        ct = time.time()
                        if dt0:
                            st = dt0+p.time-ct
                            if st > 0:
                                time.sleep(st)
                        else:
                            dt0 = ct-p.time 
                    s.send(p)
                    #n += 1
                    self._xfsendnum += 1
                    if self._xfstats == 0:
                        s.close()
                        return self._xfsendnum
                    #if verbose:
                        #sys.stdout.write(".")
                    time.sleep(inter)
                if loop < 0:
                    loop += 1
        except KeyboardInterrupt:
            pass
        s.close()
        #if verbose:
            #print "\nSent %i packets." % n
        return self._xfsendnum


class XFCapture(threading.Thread):
    '''capture packet thread'''

    def __init__(self,iface,timeout=0,xffilter=None,count=0,*args,**kwargs):
        '''xfstats -1: pending
                    1: running
                    0: stop
                   -2: error
        '''
        threading.Thread.__init__(self,*args,**kwargs)
        self._iface = iface
        self._xftimeout = timeout
        self._xfstats = -1
        self._xfcapnum = -1
        self._xfcount = count
        self._args = args
        self._kwargs = kwargs
        self.errmsg = ''
        self._has_epoll = True
        #self._has_epoll = hasattr(select, 'epoll')
        self._xfcappacket = None
        self._xffilter = xffilter
        self._xf_stop_pipe = None

    @property
    def xftimeout(self):
        return self._xftimeout
    @xftimeout.setter
    def xftimeout(self, value):
        self._xftimeout = value

    @property
    def xfstats(self):
        return self._xfstats
    @xfstats.setter
    def xfstats(self, value):
        self._xfstats = value
        if value == 0:
            if self._xf_stop_pipe:
                os.write(self._xf_stop_pipe[1],'s')

    @property
    def xfcount(self):
        return self._xfcount
    @xfcount.setter
    def xfcount(self, value):
        self._xfcount = value

    @property
    def xffilter(self):
        return self._xffilter
    @xffilter.setter
    def xffilter(self, value):
        self._xffilter = value

    @property
    def xfcapnum(self):
        return self._xfcapnum

    @property
    def xfcappacket(self):
        return self._xfcappacket

    def xf_stop_capture(self):
        ''''''
        self._xfstats = 0
        if self._xf_stop_pipe:
            os.write(self._xf_stop_pipe[1],'s')

    def start(self):
        ''''''
        self._xfstats = 1
        self._xfcapnum = 0
        self._xf_stop_pipe = os.pipe()
        threading.Thread.start(self)

    def run(self):
        ''''''
        try:
            if self._has_epoll:
                self._xfcappacket = self._xf_sniff_epoll(
                    count=self._xfcount,iface=self._iface,
                    timeout=self._xftimeout,filter=self._xffilter
                    )
            else:
                self._xfcappacket = self._xf_sniff_select(
                    count=self._xfcount,iface=self._iface,
                    timeout=self._xftimeout,filter=self._xffilter
                    )
        except Exception,ex:
            self._xfstats = -2
            self._xfcapnum = 0
            self._xfcappacket = None
            self.errmsg = str(sys.exc_info())
        else:
            self._xfstats = -1
            #self._xfcapnum = len(self._xfcappacket)
        if self._xf_stop_pipe:
            #os.read(self._xf_stop_pipe[0],1)
            self._xf_stop_pipe = None

    def _xf_sniff_select(self,count=0, store=1, offline=None, prn = None, lfilter=None, L2socket=None, timeout=None,opened_socket=None, stop_filter=None, *arg, **karg):
        """Sniff packets
            sniff([count=0,] [prn=None,] [store=1,] [offline=None,] [lfilter=None,] + L2ListenSocket args) -> list of packets
            count: number of packets to capture. 0 means infinity
            store: wether to store sniffed packets or discard them
            prn: function to apply to each packet. If something is returned,
            it is displayed. Ex:
            ex: prn = lambda x: x.summary()
            lfilter: python function applied to each packet to determine
            if further action may be done
            ex: lfilter = lambda x: x.haslayer(Padding)
            offline: pcap file to read packets from, instead of sniffing them
            timeout: stop sniffing after a given time (default: None)
            L2socket: use the provided L2socket
            opened_socket: provide an object ready to use .recv() on
            stop_filter: python function applied to each packet to determine
            if we have to stop the capture after this packet
            ex: stop_filter = lambda x: x.haslayer(TCP)
        """
        import select
        c = 0
        if opened_socket is not None:
            s = opened_socket
        else:
            if offline is None:
                if L2socket is None:
                    L2socket = conf.L2listen
                s = L2socket(type=ETH_P_ALL, *arg, **karg)
            else:
                s = PcapReader(offline)

        lst = []
        if timeout is not None:
            stoptime = time.time()+timeout
        remain = None
        while 1:
            try:
                if timeout is not None:
                    remain = stoptime-time.time()
                    if remain <= 0:
                        break
                sel = select.select([s,self._xf_stop_pipe[0]],[],[],remain)
                if s in sel[0] or self._xf_stop_pipe[0] in sel[0]:
                    if self._xfstats == 0:
                        break
                    p = s.recv(MTU)
                    if p is None:
                        break
                    if lfilter and not lfilter(p):
                        continue
                    if store:
                        lst.append(p)
                    c += 1
                    self._xfcapnum += 1
                    if prn:
                        r = prn(p)
                        if r is not None:
                            print r
                    if stop_filter and stop_filter(p):
                        break
                    if count > 0 and c >= count:
                        break
                    #if self._xfstats == 0:
                    #    break
            except KeyboardInterrupt:
                break
        if opened_socket is None:
            s.close()
        return plist.PacketList(lst,"Sniffed")

    def _xf_sniff_epoll(self,count=0, store=1, offline=None, prn = None,
        lfilter=None,L2socket=None, timeout=None,opened_socket=None, stop_filter=None, *arg, **karg):
        """ override scapy sniff
        Sniff packets
        sniff([count=0,] [prn=None,] [store=1,] [offline=None,] [lfilter=None,] + L2ListenSocket args) -> list of packets

        count: number of packets to capture. 0 means infinity
        store: wether to store sniffed packets or discard them
        prn: function to apply to each packet. If something is returned,
            it is displayed. Ex:
            ex: prn = lambda x: x.summary()
        lfilter: python function applied to each packet to determine
             if further action may be done
            ex: lfilter = lambda x: x.haslayer(Padding)
        offline: pcap file to read packets from, instead of sniffing them
        timeout: stop sniffing after a given time (default: None)
        L2socket: use the provided L2socket
        opened_socket: provide an object ready to use .recv() on
        stop_filter: python function applied to each packet to determine
             if we have to stop the capture after this packet
             ex: stop_filter = lambda x: x.haslayer(TCP)
        """
        import select,socket
        c = 0
        if opened_socket is not None:
            s = opened_socket
        else:
            if offline is None:
                if L2socket is None:
                    L2socket = conf.L2listen
                s = L2socket(type=ETH_P_ALL, *arg, **karg)
                s.ins.setblocking(0)
            else:
                s = PcapReader(offline)

        lst = []
        if timeout is not None:
            stoptime = time.time()+timeout
        remain = None
        poller = select.epoll()
        poll_in_or_priority_flags = select.EPOLLIN
        poller.register(s, poll_in_or_priority_flags | select.EPOLLET)
        poller.register(self._xf_stop_pipe[0],poll_in_or_priority_flags | select.EPOLLET)
        while 1:
            try:
                if timeout is not None:
                    remain = stoptime-time.time()
                    if remain <= 0:
                        break
                #sel = select([s],[],[],remain)
                ready = poller.poll(-1 if remain is None
                                    else remain)
                for fd, mode in ready:
                    if self._xf_stop_pipe[0] == fd:
                        if opened_socket is None:
                            s.close()
                        return plist.PacketList(lst,"Sniffed")
                    else:
                        try:
                            while True:
                                p = s.recv(MTU)
                                if p is None:
                                    break
                                if lfilter and not lfilter(p):
                                    continue
                                if store:
                                    lst.append(p)
                                c += 1
                                self._xfcapnum += 1
                                if prn:
                                    r = prn(p)
                                    if r is not None:
                                        print r
                                if stop_filter and stop_filter(p):
                                    if opened_socket is None:
                                        s.close()
                                    return plist.PacketList(lst,"Sniffed")
                                if count > 0 and c >= count:
                                    if opened_socket is None:
                                        s.close()
                                    return plist.PacketList(lst,"Sniffed")
                        except socket.error:
                            pass
                if self._xfstats == 0:
                    break
            except KeyboardInterrupt:
                break
        if opened_socket is None:
            s.close()
        return plist.PacketList(lst,"Sniffed")


class XFIfStats(threading.Thread):
    '''interface throuput stats'''
    def __init__(self,iface,timeout=None,*args,**kwargs):
        '''xfstats -1: pending
                    1: running
                    0: stop
                   -2: error
        '''
        threading.Thread.__init__(self,*args,**kwargs)
        self._iface = iface
        self._xftimeout = timeout or 1
        self._xfstats = -1
        # self._xftxbytes = {ifstr:0 for ifstr in self._ifaceList}
        # self._xftxbytes = {ifstr:0 for ifstr in self._ifaceList}
        # self._xftxpackets = {ifstr:0 for ifstr in self._ifaceList}
        # self._xftxpackets = {ifstr:0 for ifstr in self._ifaceList}
        # self._xftxpps = {ifstr:0 for ifstr in self._ifaceList}
        # self._xftxpps = {ifstr:0 for ifstr in self._ifaceList}
        # self._xfrxbytes = {ifstr:0 for ifstr in self._ifaceList}
        # self._xfrxbytes = {ifstr:0 for ifstr in self._ifaceList}
        # self._xfrxpackets = {ifstr:0 for ifstr in self._ifaceList}
        # self._xfrxpps = {ifstr:0 for ifstr in self._ifaceList}
        # self._xftxBps = {ifstr:0 for ifstr in self._ifaceList}
        # self._xfrxBps = {ifstr:0 for ifstr in self._ifaceList}
        # self._xf_bm_txbytes = {ifstr:0 for ifstr in self._ifaceList}
        # self._xf_bm_rxbytes = {ifstr:0 for ifstr in self._ifaceList}
        # self._xf_bm_txpackets = {ifstr:0 for ifstr in self._ifaceList}
        # self._xf_bm_rxpackets = {ifstr:0 for ifstr in self._ifaceList}
        self._xftxbytes = 0
        self._xftxbytes = 0
        self._xftxpackets = 0
        self._xftxpackets = 0
        self._xftxpps = 0
        self._xftxpps = 0
        self._xfrxbytes = 0
        self._xfrxbytes = 0
        self._xfrxpackets = 0
        self._xfrxpps = 0
        self._xftxBps = 0
        self._xfrxBps = 0
        self._xf_bm_txbytes = 0
        self._xf_bm_rxbytes = 0
        self._xf_bm_txpackets = 0
        self._xf_bm_rxpackets = 0
        self._args = args
        self._kwargs = kwargs
        self.errmsg = ''
        self._net_dir = '/sys/class/net'
        # self._xf_rxbytes_file = {ifstr:None for ifstr in self._ifaceList}
        # self._xf_rxpackets_file = {ifstr:None for ifstr in self._ifaceList}
        # self._xf_txbytes_file = {ifstr:None for ifstr in self._ifaceList}
        # self._xf_txpackets_file = {ifstr:None for ifstr in self._ifaceList}
        # self._xfclearstats = {ifstr:0 for ifstr in self._ifaceList}
        self._xf_rxbytes_file = None
        self._xf_rxpackets_file = None
        self._xf_txbytes_file = None
        self._xf_txpackets_file = None
        self._xfclearstats = 0

    def verify_if_file(self):
        ''''''
        #for ifname in self._ifaceList:
        ifStatsPath = os.path.join(self._net_dir,self._iface,'statistics')
        if not os.path.exists(ifStatsPath):
            return False
        self._xf_rxbytes_file = os.path.join(ifStatsPath,'rx_bytes')
        self._xf_rxpackets_file = os.path.join(ifStatsPath,'rx_packets')
        self._xf_txbytes_file = os.path.join(ifStatsPath,'tx_bytes')
        self._xf_txpackets_file = os.path.join(ifStatsPath,'tx_packets')
        return True

    @property
    def xftxbytes(self):
        return self._xftxbytes

    @property
    def xftxpps(self):
        return self._xftxpps

    @property
    def xfrxbytes(self):
        return self._xfrxbytes

    @property
    def xfrxpps(self):
        return self._xfrxpps

    @property
    def xftxpackets(self):
        return self._xftxpackets

    @property
    def xfrxpackets(self):
        return self._xfrxpackets

    @property
    def xftxBps(self):
        return self._xftxBps

    @property
    def xfrxBps(self):
        return self._xfrxBps

    @property
    def xfstats(self):
        return self._xfstats
    @xfstats.setter
    def xfstats(self, value):
        self._xfstats = value

    @property
    def xftimeout(self):
        return self._xftimeout
    @xftimeout.setter
    def xftimeout(self, value):
        self._xftimeout = value
    

    def clear_stats(self):
        ''''''
        self._xfclearstats = 1

    def start(self):
        ''''''
        self._xfstats = 1
        #for ifname in self._ifaceList:
        self._xfclearstats = 0
        self.build_benchmark()
        threading.Thread.start(self)

    def build_benchmark(self):
        with open(self._xf_rxpackets_file) as f:
            self._xf_bm_rxpackets = long(f.read())
        with open(self._xf_txpackets_file) as f:
            self._xf_bm_txpackets = long(f.read())
        with open(self._xf_rxbytes_file) as f:
            self._xf_bm_rxbytes = long(f.read())
        with open(self._xf_txbytes_file) as f:
            self._xf_bm_txbytes = long(f.read())

    def run(self):
        ''''''
        while self._xfstats:
            #check all iface
            #for ifname in self._ifaceList:
                #check clear_stats flag
            if self._xfclearstats:
                self._xfrxpackets = 0
                self._xftxpackets = 0
                self._xftxbytes = 0
                self._xfrxbytes = 0
                self.build_benchmark()
                self._xfclearstats = 0
            #save prio stats to compute rate
            prio_rx_packets = self._xfrxpackets
            prio_tx_packets = self._xftxpackets
            prio_tx_bytes = self._xftxbytes
            prio_rx_bytes = self._xfrxbytes
            #read stats file
            with open(self._xf_rxpackets_file) as f:
                rx_packets = long(f.read()) - self._xf_bm_rxpackets
            with open(self._xf_txpackets_file) as f:
                tx_packets = long(f.read()) - self._xf_bm_txpackets
            with open(self._xf_rxbytes_file) as f:
                rx_bytes = long(f.read()) - self._xf_bm_rxbytes
            with open(self._xf_txbytes_file) as f:
                tx_bytes = long(f.read()) - self._xf_bm_txbytes + 4*tx_packets
            #compute stats num
            self._xftxbytes = tx_bytes
            self._xftxpackets = tx_packets
            self._xfrxbytes = rx_bytes
            self._xfrxpackets = rx_packets
            #compute stats rate
            self._xftxpps = tx_packets - prio_tx_packets
            self._xfrxpps = rx_packets - prio_rx_packets
            self._xftxBps = tx_bytes - prio_tx_bytes
            self._xfrxBps = rx_bytes - prio_rx_bytes
            #sleep 1s
            time.sleep(self._xftimeout)


def main():
    robotremoteserver.RobotRemoteServer(
        XiaoFish(['eth0','eth1']),host='0.0.0.0',port=11918
    )

if __name__ == '__main__':
    #main()
    daemon = daemonocle.Daemon(
        worker=main,pidfile='/tmp/daemonocle_xiaofish.pid',
        )
    daemon.do_action(sys.argv[1])