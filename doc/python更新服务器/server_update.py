# -*- coding: utf-8 -*-


import os,filecmp,zipfile,paramiko,datetime,getpass,sys
local_newfiles_dir="E:\\wowo_workspace\\wxserver\\" # local workspace dir
local_oldfiles_dir="E:\\update_space\\"             #local backup work dir
special='schema.DAT'                                 #mnesia update is not used
remotepath ='./' 									  #distance host default dir
start_dir="E:\\wowo_workspace\\wxserver\\start.sh"   #first upload need upload it
stop_dir="E:\\wowo_workspace\\wxserver\\stop_all.py"  #first upload need upload it
path_file_name=["ebin","dbfile","option","option1"]

# get all files of dir
def find_all_files(path):
	newfiles={}
	if os.path.exists(path):
		for f in os.listdir(path):
			if os.path.isfile(os.path.join(path,f)):
				newfiles[os.path.join(path,f)]=f
		return newfiles
	else:
		return newfiles

# compare tow files,for example f1,f2,rf is zipfile`s class
def compare_file(f1,f2,rf):                   #f1,f2 is the file fullname
	thedifferentfile={}
	differentcounts=0
	flag=0
	for x in f1.keys():
		flag=0
		for y in f2.keys():
			f=filecmp.cmp(x,y)
			if f:
				flag=1
		if flag==0:
			if not(special==os.path.basename(x)):
				differentcounts+=1
				print "change file is %s" %(x)
				rf.write(x)	
	value=name=x.split('\\')
	thedifferentfilestr=value[1]
	return (differentcounts,thedifferentfile,rf)	
	
	
# it can not compare files when old dir is not exist	
def get_files(f1,rf):                   #f1,f2 is the file fullname
	thedifferentfile={}
	differentcounts=0
	flag=0
	for x in f1.keys():
		differentcounts=differentcounts+1
		rf.write(x)
	value=name=x.split('\\')
	path=os.path.dirname(x)[3:]
	thedifferentfilestr=[value[1],path]
	return (differentcounts,thedifferentfilestr,rf)
	
# update server info	
def update_server(host,port,username,password):
	new_files={}
	old_files={}
	upload_file={}
	flag=0  # flag=1,first update,flag=0,update server
	t = paramiko.Transport((host,port))       
	t.connect(username=username,password=password) 
	sftp=paramiko.SFTPClient.from_transport(t)
	ssh = paramiko.SSHClient()   
	ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	ssh.connect(host,port,username, password)
	stdin, stdout, stderr = ssh.exec_command("cd /..;cd opt/wxserver;ptyhon ./stop_all.py")
	if os.path.exists(local_newfiles_dir):
		if os.path.exists(local_oldfiles_dir):
			flag=1
			print "compare file upload ..."
		for k1 in path_file_name:
			path_new=local_newfiles_dir+k1
			new_files=find_all_files(path_new)   # get all files of path 
			path_old=local_oldfiles_dir+k1
			old_files=find_all_files(path_old)	# get all files of path 
			file_dir="E:\\"+k1+".zip"
			upload_file[file_dir]=file_dir
			rf=zipfile.ZipFile(file_dir,'w',zipfile.ZIP_DEFLATED)
			if new_files=={}:
				print "file %s is null " %(k1)
			else:
				if old_files=={}:
					print "old files %s is null " %(k1)
					print "first upload please wait ..."
					flag=1
					back_value=get_files(new_files,rf)
				else:
					print "new file is %s " %(path_new)
					print "old file is %s " %(path_old)
					back_value=compare_file(new_files,old_files,rf)
				count=back_value[0]
				rf=back_value[2]
				dir_values=back_value[1]
				name=dir_values[0]
				dir_name=dir_values[1]
				rf.close()
				if count!=0:
					print rf.filename
					if zipfile.is_zipfile(rf.filename):
						remotepath_update=remotepath+k1+".zip"
						print 'upload %s ,please wait ' %(rf.filename)
						sftp.put(rf.filename,remotepath_update)
						command_str="unzip ./"+k1+".zip"
						stdin, stdout, stderr = ssh.exec_command(command_str)
						print 'update ok...' 
					else:
						print "zip file %s is not exit " %(rf.filename)
				else:
					print "no file will update"
	else:
		print "path %s is not exit " %(local_newfiles_dir)
	if flag==1:
		stdin, stdout, stderr = ssh.exec_command('mv /opt/wxserver /opt/wxserver_old;mv wowo_workspace/wxserver /opt/;rm -rf wowo_workspace/')
		remotepath_update=remotepath+"start.sh"
		sftp.put(start_dir,remotepath_update)
		remotepath_update=remotepath+"stop_all.py"
		sftp.put(stop_dir,remotepath_update)
		command='mv ./start.sh /opt/wxserver/start.sh;mv ./stop_all.py /opt/wxserver/stop_all.py'
		stdin, stdout, stderr = ssh.exec_command(command)
		stdin, stdout, stderr = ssh.exec_command('chomod 777 /opt/wxserver/strat_sh;/opt/wxserver/start.sh')
		
	else:
		for name in upload_file.keys():
			command_update='mv wowo_workspace/wxserver/'+name+'/* /opt/wxserver/'+name
			stdin, stdout, stderr = ssh.exec_command(command_update)
			stdin, stdout, stderr = ssh.exec_command('/opt/wxserver/start.sh')
	t.close()
	ssh.close()

if __name__=='__main__':
	os.system("cls")
	if len(sys.argv)==1:
		print "please choice ..."
		print "1-------update 251"
		print "2-------update 250"
		print "3-------update outsit net"
	else:
		server_id=sys.argv[1]
		if server_id[0]=='1':
			update_server("192.168.1.251",22,"open","147258")
		if server_id[0]=='2':
			update_server("192.168.1.250",22,"root","147258")
		if server_id[0]=='3':
			update_server('119.254.95.162',12478,'hoolai','hoolai!^@')
		else:
			print "input server value error,value is %s " %(server_id[0])


		
		
