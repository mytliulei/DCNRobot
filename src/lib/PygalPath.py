#-*- coding:UTF-8 -*-
import socket
import os

__all__ = ['PYGAL_TOOLTIPS_PATH', 'SVG_JQUERY_PATH']

SERVER_WUHAN = '192.168.60.60'
SERVER_WUHAN_PRE = '192.168.6'
SERVER_BEIJING = '192.168.50.193'
SERVER_BEIJING_PRE = '192.168.5'
SERVER = '10.1.145.70'

#根据本机IP获取pygal模块生成svg文件所需的js文件路径
sname=socket.gethostname()
ipList = socket.gethostbyname_ex(sname)[2]
for ip in ipList:
    if SERVER_BEIJING_PRE in ip:
        path = SERVER_BEIJING
        break
    elif SERVER_WUHAN_PRE in ip:
        path = SERVER_WUHAN
        break
    else:
        path = SERVER
        break

PYGAL_TOOLTIPS_PATH = 'http://%s/pygal-tooltips.js' % path
SVG_JQUERY_PATH = 'http://%s/svg.jquery.js' % path