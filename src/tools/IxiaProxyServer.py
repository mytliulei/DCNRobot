#!/usr/bin/env python
#-*- coding: UTF-8 -*-
'''proxy server for ixia network stream genertor,for RF testing base on XMLRPC
'''

import robotremoteserver


__version__ = '0.1'
__author__ = 'liuleic'
__copyright__ = 'Copyright 2014, DigitalChina Network'
__license__ = 'Apache License, Version 2.0'
__mail__ = 'liuleic@digitalchina.com'


class IxiaRF(object):
    '''RF keyword for control ixia
    '''


if __name__ == '__main__':
    robotremoteserver.RobotRemoteServer(
        IxiaRF(),host='0.0.0.0',port=11917
    )