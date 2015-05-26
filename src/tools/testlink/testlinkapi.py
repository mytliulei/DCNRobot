#! /usr/bin/python
# -*- coding: UTF-8 -*-

#  Copyright 2011-2012 Olivier Renault, James Stock, TestLink-API-Python-client developers
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

import xmlrpclib
import code
import socket
import time
import os

from testlinkhelper import TestLinkHelper, VERSION
import testlinkerrors
from args import args

class TestlinkAPIClient(object):    
    
    __slots__ = ['server', 'devKey', 'stepsList', '_server_url']
 
    __VERSION__ = VERSION
    __args__ = args
    def __init__(self, server_url, devKey):
        self.server = xmlrpclib.Server(server_url)
        self.devKey = devKey
        socket.setdefaulttimeout(10)
        self.stepsList = []
        self._server_url = server_url

    def write_log(self,text):
        filename = time.strftime('%Y-%m-%d',time.localtime(time.time())) + "_call_xmlrpc_API.log"
        if(os.path.isfile(os.path.join("c:\\testlink_dcnrdc",filename))):
            logfile = open(os.path.join("c:\\testlink_dcnrdc",filename),'a')
        else:
            logfile = open(os.path.join("c:\\testlink_dcnrdc",filename),'w')
        nowtime = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        logfile.write(str(nowtime) + " : " + text + "\n")
        logfile.close()
	
    def _callServer(self, methodAPI, argsAPI=None):
        """ call server method METHODAPI with error handling and returns the 
        responds """

        response = None
        try:
            if argsAPI is None:
                self.write_log(str(methodAPI))
                response = getattr(self.server.tl, methodAPI)()
            else:
                self.write_log(str(methodAPI) + str(argsAPI))
                response = getattr(self.server.tl, methodAPI)(argsAPI)
        except (IOError, xmlrpclib.ProtocolError), msg:
            new_msg = 'problems connecting the TestLink Server %s\n%s' %\
            (self._server_url, msg) 
            raise testlinkerrors.TLConnectionError(new_msg)
        except xmlrpclib.Fault, msg:
            new_msg = 'problems calling the API method %s\n%s' %\
            (methodAPI, msg) 
            raise testlinkerrors.TLAPIError(new_msg)
        return response
        
    #  BUILT-IN API CALLS
    
    def about(self):
        """ about :
        Gives basic information about the API    
        """
        return self._callServer('about')

    def doesUserExist(self, user):
        """ doesUserExist :
        Checks if a user name exists 
        """
        argsAPI = {'devKey' : self.devKey,
                'user':str(user)}
        return self._callServer('doesUserExist', argsAPI)

    def isProductLineExist(self, productlinename):
        productlinename = productlinename.decode('utf8')
        argsAPI = {'devKey' : self.devKey,'testprojectname' : productlinename}    
        temp = self._callServer('getTestProjectByName', argsAPI)    
        if type(temp) == dict: #getTestProjectByName will return dict if success，or a list if fail
            if temp.has_key('name'):
                return 0
        else :
            return -1
			
    def isTestplanExist(self, productlinename, testplanname):
        argsAPI = {'devKey' : self.devKey,
                'testprojectname' : productlinename,
                'testplanname' : testplanname}    
        temp = self._callServer('getTestPlanByName', argsAPI)
        if type(temp) == list:
            if temp[0].has_key('is_open') :
                if temp['is_open'] == '1' and plan['active'] == '1':                
                    return 0
        return -1

    def isBuildLinkedToTestplan(self,productlinename,testplanname,buildname):
        testplanid = self.getTestPlanByName(productlinename,testplanname)[0].get('id')
        argsAPI = {'devKey' : self.devKey,
                'testplanid':str(testplanid)}   
        builds = self._callServer('getBuildsForTestPlan', argsAPI)
        result = -1
        import code
        buildname = buildname.decode('utf8')
        if type(builds) == list:
             	for i in xrange(len(builds)):
                    build = builds[i].get('name')
                    if build == buildname:
                        result = 0
		return result	
  	
    def isDeviceLinkedToTestplan(self,productlinename,testplanname,devicename):
        devices = self.getTestPlanDevicesByName(productlinename,testplanname)
        result = -1
        import code
        devicename = devicename.decode('utf8')
        if type(devices) == list:
             	for i in range(len(devices)):
                    device = devices[i].get('name')
                    if device == devicename:
                        result = 0
		return result
		
    def createBuild(self,productlinename,testplanname,buildname,buildnotes = ''):
        testplanid = self.getTestPlanByName(productlinename,testplanname)[0].get('id')
        argsAPI = {'devKey' : self.devKey,
                'testplanid' : testplanid,
                'buildname': buildname,
                'buildnotes': buildnotes
                }
        return self._callServer('createBuild', argsAPI)
		
    def reportTestResult(self, productlinename, testsuitename, testcasename, testplanname, buildname, devicetype, result, user, overwrite = 0, notes = ''):
        testcasename = testcasename.decode('utf8')
        testplanname = testplanname.decode('utf8')
        buildname = buildname.decode('utf8')
        devicetype = devicetype.decode('utf8')
        notes = notes.decode('utf8')
        testcase = self.getTestCaseByName(productlinename,testsuitename,testcasename)
        testcaseid = testcase[0].get('id')

        testplanid = self.getTestPlanByName(productlinename,testplanname)[0].get('id')
        argsAPI = {'devKey' : self.devKey,
                'testcaseid' : testcaseid,
                'testplanid' : testplanid,
                'status': result,
                'buildname': buildname,
                'notes': notes,
                'platformname': devicetype,
				'user': user,
				'overwrite': overwrite
                }
        return self._callServer('reportTCResult', argsAPI)
		
    def reportTestResultByKey(self, **kwargs):
        for args in ["productLine", "testSuite", "testCase","testPlan", "testDevice","testBuild","result","user"]:
            if not kwargs.has_key(args):
                return "Your provided parameters are not completed,please check what is missing!!!"
        if kwargs['result'] not in ['p','f','b','w','x','s','c']: #p-pass f-fail b-block w-warn x-NA s-skip c-accept
            return "Your Test result is not in 'p'-pass 'f'-fail 'b'-block 'w'-warn 'x'-NA 's'-skip 'c'-accept"

        productLine = kwargs['productLine']
        testSuite = kwargs['testSuite']
        testCase = kwargs['testCase']
        testcaseid = ''
        testBuild = kwargs['testBuild'].decode('utf8')
        testDevice = kwargs['testDevice'].decode('utf8')
        testcase = self.getTestCaseByName(productLine,testSuite,testCase)
        if type(testcase) == list:
            if testcase[0].has_key('id'):
                testcaseid = testcase[0].get('id')
        else:
            return "error when get testCase"			
        testplanid = self.getTestPlanByName(kwargs['productLine'],kwargs['testPlan'])[0].get('id')

        argsAPI = {'devKey' : self.devKey,
                'testcaseid' : testcaseid,
                'testplanid' : testplanid,
                'status': kwargs['result'],
                'buildname': kwargs['testBuild'].decode('utf8'),
                'platformname': kwargs['testDevice'].decode('utf8')
                }
        if  kwargs.has_key('notes'):
            argsAPI['notes'] = kwargs['notes'].decode('utf8')
        if kwargs.has_key('overwrite'):
            argsAPI['overwrite'] = kwargs['overwrite']
        if kwargs.has_key('user'):
            argsAPI['user'] = kwargs['user']
        if kwargs.has_key('job_id'):
            argsAPI['job_id'] = kwargs['job_id']
        if kwargs.has_key('stack'):
            argsAPI['stack'] = kwargs['stack']
        return self._callServer('reportTCResult', argsAPI)
		
    def createDailyBuildJob(self,**kwargs):
        for args in ['productLine','testPlan','testDevice','testBuild','user','vdi_ip']:
            if not kwargs.has_key(args):
                return [{'status':'false','message':'Your provided parameters are not completed'}]
        
        argsAPI = {'devKey' : self.devKey,
                'productLine' : kwargs['productLine'].decode('utf8'),
                'testPlan': kwargs['testPlan'].decode('utf8'),
                'testDevice': kwargs['testDevice'].decode('utf8'),
                'testBuild': kwargs['testBuild'].decode('utf8'),
                'user': kwargs['user'],
                'vdi_ip': kwargs['vdi_ip'],
                's1ip': 's1ip',
                's2ip': 's2ip',
                's1p1': 's1p1',
                's1p2': 's1p2',
                's1p3': 's1p3',
                's2p1': 's2p1',
                's2p2': 's2p2',
                's2p3': 's2p3',
                'ixia_ip': 'ixia_ip',
                'tp1': 'tp1',
                'tp2': 'tp2'
                }
				
        if kwargs.has_key('s1ip'):
            argsAPI['s1ip'] = kwargs['s1ip']
        if kwargs.has_key('s2ip'):
            argsAPI['s2ip'] = kwargs['s2ip']
        if kwargs.has_key('s1p1'):
            argsAPI['s1p1'] = kwargs['s1p1']
        if kwargs.has_key('s1p2'):
            argsAPI['s1p2'] = kwargs['s1p2']
        if kwargs.has_key('s1p3'):
            argsAPI['s1p3'] = kwargs['s1p3']
        if kwargs.has_key('s2p1'):
            argsAPI['s2p1'] = kwargs['s2p1']
        if kwargs.has_key('s2p2'):
            argsAPI['s2p2'] = kwargs['s2p2']
        if kwargs.has_key('s2p3'):
            argsAPI['s2p3'] = kwargs['s2p3']
        if kwargs.has_key('ixia_ip'):
            argsAPI['ixia_ip'] = kwargs['ixia_ip']
        if kwargs.has_key('tp1'):
            argsAPI['tp1'] = kwargs['tp1']
        if kwargs.has_key('tp2'):
            argsAPI['tp2'] = kwargs['tp2']

        return self._callServer('createJob', argsAPI)
		
    def getIssueInfo(self, productlinename, product, script, testcase, step):
        """ getIssueInfo :
        Gets issue info
        """
        productlinename = productlinename.decode('utf8')
        argsAPI = {'devKey' : self.devKey,'testprojectname' : productlinename}    
        temp = self._callServer('getTestProjectByName', argsAPI)
        testProjectID = temp['id']
        argsAPI = {'devKey' : self.devKey,
                'testProjectID' : testProjectID,
                'product' : product,
                'script' : script,
                'testcase' : testcase,
                'step' : step}
        return self._callServer('getIssueInfo', argsAPI)    

    def reportJobResult(self, jobid, exeid):
        """ reportJobResult :
        report job result info
        """
        argsAPI = {'devKey' : self.devKey,
        'jobid' : jobid,
        'exeid': exeid}
        return self._callServer('reportJobResult_new', argsAPI)
		
    def getJobInfo(self, jobid):
        """ getJobInfo :
        Gets job general info
        """
        argsAPI = {'devKey' : self.devKey,
                'jobid' : str(jobid)}
        return self._callServer('getJobInfo', argsAPI)
		
    def getJobEnv(self, jobid):
        """ getJobEnv :
        Gets job environment info
        """
        argsAPI = {'devKey' : self.devKey,
                'jobid' : str(jobid)}
        return self._callServer('getJobEnv', argsAPI)    

    def getJobCases(self, jobid):
        """ getJobCases :
        Gets test cases which job need to execute
        """
        argsAPI = {'devKey' : self.devKey,
                'jobid' : str(jobid)}
        return self._callServer('getJobCases', argsAPI)

    def updateJobInfo(self, jobid, status, testcase=''):
        """ updateJobInfo :
        Update job information
        """
        argsAPI = {'devKey' : self.devKey,
                'jobid' : str(jobid),
                'status' : status,
                'case' : str(testcase)}
        return self._callServer('updateJobInfo', argsAPI)
		
    def updateJobBuild(self, jobid, buildid):
        """ updateJobBuild :
        Update build id for a job
        """
        argsAPI = {'devKey' : self.devKey,
                'jobid' : str(jobid),
                'id' : str(buildid)}
        return self._callServer('updateJobBuild', argsAPI)

    def uploadExecutionAttachment(self,filename,executionid):
        """
        Attach a file to a test execution
        attachmentfile: python file descriptor pointing to the file
        name : name of the file
        title : title of the attachment
        description : description of the attachment
        content type : mimetype of the file
        """
        import mimetypes
        import base64
        import os
        import os.path
        attachmentfile = file(filename)
        argsAPI={'devKey' : self.devKey,
                 'executionid':executionid,
                 # 'title':title,
                 'filename':os.path.basename(attachmentfile.name),
                 # 'description':description,
                 'filetype':mimetypes.guess_type(attachmentfile.name)[0],
                 'content':base64.encodestring(attachmentfile.read())
                 }
        return self._callServer('uploadExecutionAttachment', argsAPI)	
	
    def getProductLineByName(self, productlinename):
        """ getProductLineByName :
        Gets info about target product line    
        """
        productlinename = productlinename.decode('utf8')
        argsAPI = {'devKey' : self.devKey,'testprojectname' : productlinename}    
        return self._callServer('getTestProjectByName', argsAPI)

    def getTestPlanByName(self, productlinename, testplanname):
        """ getTestPlanByName :
        Gets info about target test project   
        """
        argsAPI = {'devKey' : self.devKey,
                'testprojectname' : productlinename,
                'testplanname' : testplanname}    
        return self._callServer('getTestPlanByName', argsAPI)
		
    def getTestPlanDevices(self, tplanid):
        """ getTestPlanDevices :
        Returns the list of device associated to a given test plan    
        """
        argsAPI = {'devKey' : self.devKey,
                'testplanid' : str(tplanid)}    
        return self._callServer('getTestPlanPlatforms', argsAPI)

    def getTestCaseByName(self, testProjectName, testSuiteName, testCaseName):
        """ 
        Find a test case by its name
        testSuiteName and testProjectName are optionals arguments
        This function return a list of tests cases
        """
		
        testCaseName = testCaseName.decode('utf8')
        argsAPI = {'devKey' : self.devKey,'testcasename':testCaseName}

        if testSuiteName is not None:
            testSuiteName = testSuiteName.decode('utf8')
            argsAPI.update({'testsuitename':testSuiteName})
    
        if testProjectName is not None:
            testProjectName = testProjectName.decode('utf8')
            argsAPI.update({'testprojectname':testProjectName})

        ret_srv = self._callServer('getTestCaseIDByName', argsAPI)
        if type(ret_srv) == dict:
            retval = []
            for value in ret_srv.values():
                retval.append(value)
            return retval
        else:
            return ret_srv

    def getTestPlanDevicesByName(self, productlinename, testplanname):
        """ getTestPlanDevices :
        Returns the list of device associated to a given test plan    
        """
        import code
        name = testplanname.decode('utf8')
        testplanid = self.getTestPlanByName(productlinename,name)[0].get('id')
        argsAPI = {'devKey' : self.devKey,'testplanid' : str(testplanid)}    
        return self._callServer('getTestPlanPlatforms', argsAPI)  