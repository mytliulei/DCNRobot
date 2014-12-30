#!/usr/bin/env python
#-*- coding: UTF-8 -*-
'''Dispatch Robot ixia client message to IxiaProxyServer
   Manage IxiaProxyServer, start and shutdown
'''

import socket
import SocketServer
import subprocess
import time
import hashlib
import re
import os,os.path

IxiaObject = None


class IxiaDispatchTCPHandler(SocketServer.BaseRequestHandler):
    """
    The RequestHandler class for our server.

    It is instantiated once per connection to the server, and must
    override the handle() method to implement communication to the
    client.
    """

    def handle(self):
        # self.request is the TCP socket connected to the client
        self.data = self.request.recv(1024).strip()
        print "{} wrote:".format(self.client_address[0])
        print self.data
        r1 = re.compile(r'close ixia (.*)')
        if self.data == 'init ixia':
            address_str = 'null null'
            ixia_key = 'null'
            if IxiaObject.dispatch_proxy_server():
                address_str = '%s %s' % IxiaObject.dispatch_bind_address
                ixia_key = IxiaObject.dispatch_ixia_key
            self.request.sendall('%s %s' % (address_str,ixia_key))
            IxiaObject.adjust_process_pool()
        elif r1.search(self.data):
            ixia_key = r1.search(self.data).group(1)
            if IxiaObject.close_proxy_server(ixia_key):
                self.request.sendall('OK')
            else:
                self.request.sendall('FAILED')
        else:
            pass


class IxiaManagement(object):
    '''Manage IxiaProxyServer
       start ixia proxy server and return the host,port
       manage ixia proxy server process pool
       shutdown ixia proxy server
    '''
    def __init__(self,version,bind_ip,pool=3):
        ''''''
        self.ixia_tcl_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','tools','ixia','tcl')
        self.proxy_server_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','tools','IxiaProxyServer.tcl')
        self.tcl_path = {
            '4.10':os.path.join(self.ixia_tcl_path,'ixia410','bin'),
            '5.50':os.path.join(self.ixia_tcl_path,'ixia550','bin'),
            '5.60':os.path.join(self.ixia_tcl_path,'ixia560','bin'),
            'default':os.path.join(self.ixia_tcl_path,'ixia410','bin'),
        }
        self.proxy_bind_port = {
            '4.10':0,
            '5.50':0,
            '5.60':0,
            'default':0,
        }
        self.bind_ip = bind_ip if bind_ip else '0.0.0.0'
        self.version = version if version in self.tcl_path.keys() else '4.10'
        self.pool = pool if pool > 0 else 3
        self.proxy_server_process_pool = {}
        self.proxy_server_process_used = {}
        self.proxy_server_timeout = 3600 * 4
        self.proxy_server_bind_address = {}
        self.proxy_server_process_time = {}
        self._dispatch_bind_address = None
        self._dispatch_ixia_key = None
        self.build_proxy_server_pool()

    def __del__(self):
        '''
        '''
        for key in self.proxy_server_process_used.keys():
            try:
                self.proxy_server_process_used[process_key].terminate()
            except Exception:
                pass
        for key in self.proxy_server_process_pool.keys():
            try:
                self.proxy_server_process_pool[process_key].terminate()
            except Exception:
                pass

    def build_proxy_server_pool(self):
        '''
        '''
        for i in range(self.pool):
            if not self.start_proxy_server(self.bind_ip,self.version,0):
                raise AssertionError('not build proxy server pool %s version %s' % (self.pool,self.version))
                return False

    def start_proxy_server(self,bind_ip,version,proxy_server_port,debug=False):
        '''
        '''
        cmdpath = os.path.join(self.tcl_path[version],'tclsh.exe')
        if not os.path.exists(cmdpath):
            raise AssertionError('tcl path: %s is not exists' % cmdpath)
        if not os.path.exists(self.proxy_server_path):
            raise AssertionError('prox server file: %s is not exists' % self.proxy_server_path)
        #process \s in path
        proxy_file_sub = re.compile(r'\\([^\\]*\s+[^\\]*)\\')
        proxy_file = proxy_file_sub.sub(r'\\"\1"\\',self.proxy_server_path)
        cmd = '%s %s bindaddr %s bindport %s ixiaversion %s' % (cmdpath,proxy_file,bind_ip,proxy_server_port,version)
        if debug:
            cmd += ' logflag 1'
        p=subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE)
        searchre = re.compile(r'proxy server listen port:(\d+)')
        timeout = 0
        while p.poll() is None and timeout < 60:
            time.sleep(1)
            timeout += 1
            rdstr = p.stdout.readline()
            ret_port = searchre.search(rdstr)
            if ret_port:
                proxy_server_bind_port = int(ret_port.groups()[0])
                md5_str = '%s %s %s' % (bind_ip,proxy_server_bind_port,time.time())
                md5_obj = hashlib.md5()
                md5_obj.update(md5_str)
                process_key = md5_obj.hexdigest()
                self.proxy_server_process_pool[process_key] = p
                self.proxy_server_bind_address[process_key] = (bind_ip,proxy_server_bind_port)
                return True
        return False

    def shutdown_proxy_server(self,address):
        '''
        '''
        try:
            ixia_client_handle = socket.create_connection(address)
            cmd = 'shutdown_proxy_server\n'
            ixia_client_handle.sendall(cmd)
        except Exception:
            return False
        ixia_client_handle.close()
        return True

    def close_proxy_server(self,process_key):
        '''
        '''
        shut = False
        if process_key in self.proxy_server_process_used.keys():
            address = self.proxy_server_bind_address[process_key]
            if not self.shutdown_proxy_server(address):
                return shut
            del self.proxy_server_process_used[process_key]
            del self.proxy_server_bind_address[process_key]
            if process_key in self.proxy_server_process_time.keys():
                del self.proxy_server_process_time[process_key]
            shut = True
        return shut

    def dispatch_proxy_server(self):
        '''
        '''
        self.check_proxy_server()
        if not self.proxy_server_process_pool.keys():
            if not self.start_proxy_server():
                self._dispatch_bind_address = None
                self._dispatch_ixia_key = None
                return False
        process_key = self.proxy_server_process_pool.keys()[0]
        self.proxy_server_process_used[process_key] = self.proxy_server_process_pool[process_key]
        self.proxy_server_process_time[process_key] = time.time()
        #
        del self.proxy_server_process_pool[process_key]
        self._dispatch_bind_address = self.proxy_server_bind_address[process_key]
        self._dispatch_ixia_key = process_key
        return True

    def check_proxy_server(self):
        '''
        '''
        for key in self.proxy_server_process_used.keys():
            t = time.time()
            if (t - self.proxy_server_process_time[key]) > self.proxy_server_timeout:
                self.close_proxy_server(key)

    def adjust_process_pool(self):
        '''
        '''
        used_num = len(self.proxy_server_process_used)
        pool_num = len(self.proxy_server_process_pool)
        if used_num > 30:
            return False
        if used_num >= (pool_num + used_num) *2/3:
            start_num = used_num *2 - pool_num
            for i in range(start_num):
                if not self.start_proxy_server(self.bind_ip,self.version,0):
                    raise AssertionError('not build proxy server pool %s version %s' % (self.pool,self.version))
                    return False

    @property
    def dispatch_bind_address(self):
        return self._dispatch_bind_address

    @property
    def dispatch_ixia_key(self):
        return self._dispatch_ixia_key


if __name__ == "__main__":
    IxiaObject = IxiaManagement('4.10','192.168.30.22')
    HOST, PORT = '192.168.30.22', 11917
    # Create the server, binding to localhost on port 9999
    server = SocketServer.TCPServer((HOST, PORT), IxiaDispatchTCPHandler)
    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()