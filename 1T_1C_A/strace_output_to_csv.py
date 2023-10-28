import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)

# Fundamentals
import matplotlib.pyplot as plt
import seaborn as sns

# List of all system calls in Linux

column_names=['Run Number','Number of Threads','accept4','access','alarm','arch_prctl','bind','brk','capget','capset','chdir','chmod','chown',
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

# Creating a dataframe including all the system calls as columns

df = pd.DataFrame(columns = column_names)

## FOR ALL THREADS # Uncomment the following lines to convert output files for all threads

# threads=[2]
# threads2=[i for i in range(4,104,4)]
# threads+=threads2

## FOR SPECIFIC THREADS

#threads=[2,4,8,12,32,36,48,52,56,60,64,68,92,96,100]
threads=[44,48,52]

for i in threads:
  output_file='strace_output_combined_1T_1C_'+ str(i) +'_threads.txt'
  run_no=1
  skip=0 # skipping lines which contain '---'/ lines which aren't system call and their count in the strace summary output
  values=[run_no,i,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  with open(output_file,'r') as file:
    for line in file: # read each line
      if skip<2:
        skip+=1 # skipping lines which contain '---'/ lines which aren't system call and their count
        continue
      arr=line.split()
      values[column_names.index(arr[-1])]+=int(arr[3]) # use the system call to find index position in the array and add the system calls
      if "write" in line: # at every encounter of the write call (since summary output is sorted), push output of each run as a row in the dataframe
        run_no+=1
        df.loc[len(df.index)]=values
        values=[run_no,i,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        skip=-2

#len(values)
#print(values)

#print(df)
#print(df['read'])
nan_value = float("NaN") 
df.replace(0, nan_value, inplace=True) 
  
df.dropna(how='all', axis=1, inplace=True) # remove all those system calls (columns) which contain ALL row values as NaNs
df.replace(nan_value, 0, inplace=True)

df.to_csv('System_calls_1T_1C.csv') # save it to a csv file