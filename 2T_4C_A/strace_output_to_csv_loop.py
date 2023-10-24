import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)

# Fundamentals
import matplotlib.pyplot as plt
import seaborn as sns

#getting columns from text file
column_names=['Loop Number','Number of Threads','accept4','access','alarm','arch_prctl','bind','brk','capget','capset','chdir','chmod','chown',
'chroot','clock_getres','clock_gettime','clock_nanosleep','clone','close','close_range','connect','copy_file_range','creat','dup','dup2','dup3',
'epoll_ctl','epoll_create','epoll_create1','epoll_pwait','epoll_wait','execve','execveat','exit','exit_group','faccessat','fadvise64',
'fallocate','fchdir','fchown','fchownat','fcntl','fdatasync','fgetxattr','flistxattr','flock','fork','fremovexattr','fsetxattr',
'fstat','fstat64','fstatat64','fsync','ftruncate','ftruncate64','futex','futex_waitv','futex_wake','futex_wait','getcwd','getdents',
'getdents64','getegid','geteuid','getgid','getgroups','gethostname','get_robust_list','get_thread_area','get_unwind','getpgid',
'getpid','getppid','getpriority','getrandom','getresgid','getresuid','getrlimit','getrusage','getsockname','getsockopt','gettid','getumask','getuid','getwd','gettimeofday',
'getxattr','inotify_add_watch','inotify_init','inotify_init1','inotify_rm_watch','io_cancel','io_getevents','io_pgetevents',
'io_pgetevents_time','io_pgetevents_time64','io_submit','ioctl','ioperm','iopl','issetugid','kexec_load','kill','lchown','lchownat',
'lgetxattr','link','listxattr','llistxattr','lremovexattr','lseek','lsetxattr','lstat','lstat64','madvise','mbind','membarrier',
'mincore','mkdir','mknod','mknodat','mlock','mlockall','mmap','mmap2','mprotect','mremap','msgctl','msgget','msgsnd','msgrcv','munlock',
'munlockall','munmap','nanosleep','newfstatat','nfsservctl','nice','openat','pause','perf_event_open','personality','pipe','pipe2','pivot_root',
'pkey_alloc','pkey_free','pkey_mprotect','poll','ppoll','pselect64','prctl','pread64','preadv','prlimit64','pwrite64','pwritev','quotactl',
'read','readahead','readlink','readlinkat','readv','recv','recvfrom','recvfromto','recvmsg','remap_file_pages','removexattr',
'rename','renameat','request_key','rmdir','rt_sigaction','rt_sigpending','rt_sigprocmask','rt_sigqueueinfo','rt_sigreturn',
'rt_sigsuspend','rt_sigtimedwait','rt_tgsigqueueinfo','sched_getaffinity','sched_getparam','sched_getscheduler',
'sched_setaffinity','sched_setparam','sched_setscheduler','sched_yield','select','semctl','semget','semop','semtimedop','send',
'sendmsg','sendmmsg','sendto','sendtomem','set_robust_list','set_thread_area','set_tid_address','set_unwind','setdomainname','setfsgid',
'setfsuid','setgid','setgroups','sethostname','setitimer','setpgid','setpriority','setregid','setresgid','setresuid','setrlimit',
'setrlimit64','setrtx','setsid','setsockopt','settimeofday','setuid','setxattr','shmat','shmctl','shmdt','shmget','shutdown','sigaltstack',
'signalfd','sigpending','sigprocmask','sigreturn','sigsuspend','sigtimedwait','socket','socketpair','splice','stat','stat64',
'statfs64','stime','stpcpy','stpcpyb','strchrnul','strcspn','strdup','strerror','strlen','strncmp','strncpy','strrchr',
'strspn','strtol','strtoul','symlink','symlinkat','sync','sysinfo','syscall','sync_file_range','sys_epoll_wait','sysinfo',
'tee','tgkill','time','uname','unlink','utimes','wait4','write']

df = pd.DataFrame(columns = column_names)

#print(df)
#print(len(column_names))

# ## FOR SPECIFIC THREADS

# selected_threads=[2,4,8,12,32,36,48,52,56,60,64,68,92,96,100]
selected_threads=[48,52,56,60,64,68]


for i in selected_threads:
  output_file='2t_4c_A\strace_output_combined_finalloop_'+ str(i)+'_threads.txt'
  loop_no=1
  skip=0
  write_count=0
  values=[loop_no,i,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  with open(output_file,'r') as file:
    #read each line
    for line in file:
      if skip<2:
        skip+=1 #skipping lines which contain '---'/ lines which aren't system call and their count
        continue
      arr=line.split()
      values[column_names.index(arr[-1])]+=int(arr[3])
      if "write" in line:
        write_count+=1
        if write_count == 4:
          loop_no+=1
          df.loc[len(df.index)]=values
          values=[loop_no,i,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          write_count=0
        skip=-2



#len(values)
#print(values)

#print(df)
#print(df['read'])

nan_value = float("NaN") 
df.replace(0, nan_value, inplace=True) 
  
df.dropna(how='all', axis=1, inplace=True) 
df.replace(nan_value, 0, inplace=True)
df.to_csv('2t_4c_A\System_calls_finalloop.csv')
