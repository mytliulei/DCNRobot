#!/usr/bin/env python
#-*- coding: UTF-8 -*-

#  Copyright 2012 TestLink-API-Python-client developers
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
# ------------------------------------------------------------------------
#参数说明，由脚本执行者按照实际情况修改
#productLine:在testlink网页的右上角"研发中心产品线"项，如'无线产品线'、'交换机产品线'
#testSuite：脚本模块的名称，进入右边的"测试执行"--->"执行测试"可看到左边的"过滤器"--->"测试用例集"下拉框，如'确认测试2.0'
#testPlan:测试计划名称，进入右边的"当前测试计划"下拉框选择.如"售后维护-3950-kelland"
#testBuild：被测设备的版本，进入右边的"测试执行"--->"执行测试"可看到左边的"设置"--->"要执行的版本"下拉框,如果没有平台会自动添加
#testDevice：被测设备的型号，进入右边的"测试执行"--->"执行测试"可看到左边的"设置"--->"产品型号"下拉框，如'Kelland-3950-28C(R5)-19'
#notes：备注信息，不用修改
#user:脚本执行者的itcode，如果在testlink上不存在，请联系管理员
#aftersaleFlag:脚本执行者是否是售后，是:1     不是:0
#aftersaleVersion:执行者是售后需要填写，产品名称-项目名称-流，例如"5960-bobcat-maintain"
#scriptVersion:执行者是售后需要填写，脚本的版本，6.3、7.0patch、7.2、7.3
args = {'productLine':'交换机产品线',
    'testSuite':'确认测试2.0',
    'testPlan':'auto',
    'testBuild':'auto',
    'testDevice':'auto',
    'notes':'',
    'user':'auto',
    'aftersaleFlag':'0',
    'aftersaleVersion':'auto',
    'scriptVersion':'7.0patch'
}