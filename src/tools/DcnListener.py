#-*- coding:UTF-8 -*-
import re
import os
import time
import sys
import testlink #DcnListener and Testlink 要在同一目录下；一般在..\src\tools目录中
FTP_SERVER_WUHAN = '192.168.60.60'
FTP_SERVER_WUHAN_PRE = '192.168.6'
FTP_SERVER_BEIJING = '192.168.50.193'
FTP_SERVER_BEIJING_PRE = '192.168.5'
FTP_USER = 'testlink'
FTP_PASSWORD = 'testlink'
LOG_FILE = 'DcnListener.log'

class DcnListener:
    ROBOT_LISTENER_API_VERSION = 2   
   
    def __init__(self):
        self.tl = self.initTestlinkConnect()
        self.args = self.tl.__args__
        self.logfile_path = os.path.join(self.args['robot_path'],'log',self.args['job_id'])
        self.createLogfile(self.logfile_path)
        self.wlog(self.timenow()+' :Listener Init finished! \n')
        self.wlog(self.timenow()+' :The args is: \n')
        temp = ''
        for item in self.args:
            temp = temp + item.ljust(20) + ' = ' + self.args[item] + '\n'
        self.wlog(temp)
    
    #Called @ keyword开始
    def start_keyword(self, name, attrs):
        if 'Pause Execution' in name:
            self.tl.updateJobInfo(self.args['job_id'],0) #报告testlink暂停运行 
    
    #Called @ keyword结束
    def end_keyword(self, name, attrs):
        if 'Pause Execution' in name:
            self.tl.updateJobInfo(self.args['job_id'],1) #报告testlink继续运行 
    
    #Called @ 测试例开始
    def start_test(self, name, attrs):
        self.updateCaseInfo(name,attrs)
    
        
    #Called @ 测试例结束
    def end_test(self, name, attrs):
        sefl.reportTestResult(name, attrs)
        
    #Called @ 测试集(测试套)开始
    def start_suite(self, name, attrs):
        self.args['testSuite'] = name
        self.wlog('%s :Update TestSuite "%s" \n' % (self.timenow(),self.args['testSuite']) )
    
    #Called @ 测试集(测试套)结束
    def end_suite(self,name,attrs):
        pass
    
    #Called @ logger的调用，包括测试用例使用log*关键字以及library本身调用robot.api.logger记录信息时
    def log_message(self,message):
        #查找以"DUT_IMG_VERSION: "开始的version信息。
        if re.match('DUT_IMG_VERSION: ',message['message']):
            self.createBuild(message['message'])
        
    #Called @ 所有测试及结果输出结束后(注：在robot输出ouput.xml，report.html，log.html等动作之后被调用)
    def close(self):
        self.closeJob()
        
    def initTestlinkConnect(self):
        return testlink.TestLinkHelper().connect(testlink.TestlinkAPIClient)
        
    def createLogfile(self,path):
        if not os.path.exists(path):
            os.makedirs(path)
        if not os.path.isfile(os.path.join(path,LOG_FILE))
            self.wlog(self.timenow() + ' :Create DcnListener Log File Successful! \n')
    
    def timenow(self):
        return time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))            
    
    def wlog(self,text,file=os.path.join(self.logfile_path,LOG_FILE)):
        logfile = open(file,'a+')
        logfile.write(text)
        logfile.close()
        
    def createBuild(self,version):
        args = self.args
        tl = self.tl
        testBuildGroup = re.search('Version ([^\n ]+)',version)
        if testBuildGroup is not None:
            testBuild = testBuildGroup.group(1)
            #如果测试版本不存在，新增测试版本
            if args['testBuild'] != testBuild:
                if args['testBuild'] != 'Dynamic Create':
                    self.wlog('%s :Warnning! job_testBuild "%s" is not equal to DUT testBuild "%s", DUT testBuild will be used! \n' % (self.timenow(), args['testBuild'], testBuild))
                args['testBuild'] = testBuild
                args['notes'] = version
                buildid=tl.createBuild(args['productLine'],args['testPlan'],args['testBuild'],args['notes'].split('||||')[0])
                if type(buildid) == list:
                    if buildid[0].has_key('id'):
                        tl.updateJobBuild(args['job_id'],buildid[0].get('id'))
            #如果版本存在，检查版本是否连接到测试计划
            elif tl.isBuildLinkedToTestplan(args['productLine'],args['testPlan'],args['testBuild']) != 0:
                tl.createBuild(args['productLine'],args['testPlan'],args['testBuild'],args['notes'].split('||||')[0])
            self.wlog('%s :Update job_testBuild to "%s" and buildid is "%s" \n' % (self.timenow(),testBuild,buildid[0]['id']))
        else:
            self.wlog('%s :Get Version fail from string "%s" \n' % (self.timenow(),version))
        
    def reportTestResult(self,name,attrs):
        # 回传测试例执行结果到testlink，result取值范围 p|f|b|w|x|s|c （对应pass、fail、block、warn、N/A、skip、accept）,robot目前仅支持PASS/FAIL
        self.args['testCase'] = name
        self.args['result'] = 'p' if attrs['status'] == 'PASS' else 'f'
        myreport = self.tl.reportTestResultByKey(**self.args)
        self.wlog('%s :Report testCase "%s" results and server rc is "%s" \n' % (self.timenow(),name,str(myreport)))
    
    def updateCaseInfo(self,name,attrs):
        #测试例开始时，更新testCase Name并清空result,通知testlink更新当前运行的testCase信息
        self.args['testCase'] = name
        self.args['result'] = ''
        self.tl.updateJobInfo(self.args['job_id'],1,self.args['testCase'])
        self.wlog('%s :Update TestCase "%s" \n' % (self.timenow(),self.args['testCase']) )
    
    def closeJob(self):
        self.wlog('%s :Robot Test for job_id "%s" finished! \n' % (self.timenow(),self.args['job_id']) )
        self.uploadLogFile()
        self.tl.updateJobInfo(self.args['job_id'],2)    
        
    def uploadLogFile(self):
        import socket
        from ftplib import FTP
        ftp = FTP()
        ip = socket.gethostbyname(socket.gethostname()) or None
        if FTP_SERVER_WUHAN_PRE in ip:
                ftp = FTP_SERVER_WUHAN
        elif FTP_SERVER_BEIJING_PRE in ip:
                ftp = FTP_SERVER_BEIJING
        try:
             ftp.connect(fip, '21')
        except Exception, e:
            self.wlog('%s :Connect to ftp server "%s" error! error code: %s \n' % (self.timenow(), fip, str(e)) )
            return False
        ftp.login(FTP_USER, FTP_PASSWORD)
        temp = ftp.nlst()
        # 判断job_id对应的文件夹是否已经存在，不存在则创建文件夹
        if self.args['job_id'] not in temp:
            ftp.mkd(self.args['job_id'])
        ftp.cwd(self.args['job_id'])
        #获取log文件夹中所有以.log .txt .py .res .svg .xml .html结尾的测试结果文件完整路径，然后上传至testlink服务器
        extension_list = ['.log', '.txt', '.py', '.res', '.svg', '.html', '.xml']
        log_file_list = self.getFilesFromDir(self.logfile_path,extension_list)
        # log文件通过ftp上传到testlink服务器
        self.wlog('%s :Start upload files to server! \n' % self.timenow())
        for file in log_file_list:
            file_handle = open(file,'rb')
            ftp.storbinary('STOR %s' % os.path.basename(file),file_handle,1024)
            file_handle.close()
        ftp.quit()
    
    
    def getFilesFromDir(dir,extension_list=[]):
        filelist = []
        for path,subdirs,files in os.walk(dir):
            for f in files:
                if extension_list:
                    for ext in extension_list:
                        if f.endswith(ext):
                            filelist.append(os.path.join(path,f))
                            break
                else:
                    filelist.append(os.path.join(path,f))
        return filelist