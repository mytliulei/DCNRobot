#!/usr/bin/env python
#-*- coding: UTF-8 -*-
'''network stream genertor Tools,for RF testing 

   ps: XiaoFish is a little cat, bless her.  
'''
import os,os.path
from robot.api import logger
from robot.version import get_version



__version__ = '0.1'
__author__ = 'liuleic'
__copyright__ = 'Copyright 2014, DigitalChina Network'
__license__ = 'Apache License, Version 2.0'
__mail__ = 'liuleic@digitalchina.com'

class XiaoFish(object):
    '''
    '''
    ROBOT_LIBRARY_SCOPE = 'TEST_SUITE'
    ROBOT_LIBRARY_VERSION = get_version()
    def __init__(self):
        ''''''
        pass

    def get_stream_from_pcapfile(self,filename):
        '''read pcap file '''
        if not os.path.isfile(filename):
            logger.info('%s is not a file' % filename)
            raise RuntimeError('%s is not file or path error' % filename)
        #
        #pcapList = rdpcap(filename)
        #logger.info('%s' % pcapList)
        with open(filename,'rb') as handle:
            return handle.read()






