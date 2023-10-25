#!/usr/local/bin/bash


#WORKLOAD A...... 1t_1c
  

# node0(0,1,2,3,16,17,18,19)->server
# node1(4,5,6,7,20,21,22,23)->server
# node2(8,9,10,11,24,25,26,27)->client1
# node3(12,13,14,15,28,29,30,31)->client1

:<<'EOF'

# MongoDB Server Run - based on allocated nodes ^
sudo systemctl stop mongod
sudo systemctl status mongod
numactl --physcpubind=0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23 sudo systemctl start mongod
sudo systemctl status mongod


# Disable C-state in BIOS


# To set CPU core frequency to MAX (DO THIS AFTER EVERY REBOOT)
sudo cpupower frequency-set -f 2200000
#lscpu | grep "MHz"


# Delete existing data if running new workloads (A,B,C,D,E,F)
# Clear DB
mongosh
        show dbs
        use ycsb
        db.dropDatabase()
        exit


# Load phase
# Loads 1 table (10 million records) into DB

numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=10000000 -p table=usertable1 -threads 32 -p mongodb.url=mongodb://localhost:27017/ycsb?w=0



# Check DB
mongosh
        show dbs
        use ycsb
        show collections
        db.usertable1.find().count()
        exit


# Remove files if any
rm p1_*.txt
rm p2_*.txt
rm p3_*.txt
rm p4_*.txt



# Run these ||ly

# Terminal 1 : (RUN ON SERVER NODES)
sudo perf stat -d -d -d -C 0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23


# Terminal 2: (RUN ON SERVER NODES)
sudo perf stat -d -d -d -C 0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23 -e task-clock,major-faults,minor-faults,cache-references,cache-misses


# Terminal 3: (RUN ON SERVER NODES)
sudo perf record -g -C 0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23
mv perf.data perf.data.1T_1C_.....


sudo perf report -g -i perf.data
sudo perf diff perf.data.1T_ perf.data.2T_


# Terminal 4: (RUN ON SERVER NODES)
rm mp.txt
mpstat -N 0,1 2 | tee mp.txt           #CHECK    # Node 0 and 1 details →  avg %iowait, avg %idle time


sed -i -e 1,2d mp.txt               # to remove top 2 unnecessary lines
sed -i '/^$/d' mp.txt               # to remove all empty lines
sed -i '1d; n; d' mp.txt            # to remove all header lines / odd lines
awk '{print $7}' mp.txt | awk 'BEGIN{sum=0; line=0}{sum=sum+$1; line=line+1} END{print "%iowait_Total=",sum, "%iowait_Avg=", sum/line}'
awk '{print $13}' mp.txt | awk 'BEGIN{sum=0; line=0}{sum=sum+$1; line=line+1} END{print "%NodeIdle_Total=",sum, "%NodeIdle_Avg=", sum/line}'



# Terminal 5:                   # Run ALL 1/2/3/4 Clients with YCSB
# Commmands are given down in this file
#refer .sh files in my server
#run all commands to put in .txt file
#calculate avg using .xls file
#Put all final data in drive .xls file


# Terminal 6:
sudo htop                       # OR
sudo perf top


#sudo turbostat



# Run phase
# 1 process access 1 table
# 3 RUNS

EOF



output_memory(){
	local id=$1
	local count=$2
	local buffer_value=$(awk '/Buffers/ {print $2}' /proc/meminfo)
	local cache_value=$(awk '/^Cached:/ {print $2}' /proc/meminfo)
	echo "$id,$count,$buffer_value,$cache_value"
}


# 2 threads
# RUN 1 (EXTRA)
#numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
# RUN 2 (EXTRA)
# RUN 1 (EXTRA)
#numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
# RUN 2 (EXTRA)
#numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0



# # 44 threads

rm mpstat_44_output.txt
mpstat -N 0,1 2 | tee mpstat_44_output.txt &           #CHECK    # Node 0 and 1 details →  avg %iowait, avg %idle time
mpstat_pid=$!
echo "mpstatpid=$mpstat_pid"

id=44
count=1

output_memory $id $count >> mpstat_out.csv

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0


count=$((count+1))
output_memory $id $count >> mpstat_out.csv

 numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

count=$((count+1))
output_memory $id $count >> mpstat_out.csv

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt

count=$((count+1))
output_memory $id $count >> mpstat_out.csv

#numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt

#count=$((count+1))
#output_memory $id $count >> mpstat_out.csv

#numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt

#count=$((count+1))
#output_memory $id $count >> mpstat_out.csv

kill $mpstat_pid
count=$((count+1))
output_memory $id $count >> mpstat_out.csv

count=0

sed -i -e 1,2d mpstat_44_output.txt               # to remove top 2 unnecessary lines
sed -i '/^$/d' mpstat_44_output.txt               # to remove all empty lines
sed -i '1d; n; d' mpstat_44_output.txt            # to remove all header lines / odd lines

iowait_Total=$(awk '{sum+=$7} END{print sum}' mpstat_44_output.txt)
iowait_Average=$(awk '{sum+=$7} END{print sum/NR}' mpstat_44_output.txt)

echo "$id,$iowait_Total,$iowait_Average" >> mpstat_ioavg_output.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_44.txt | awk '{print $3}' >> p1_44.txt

# egrep '\[READ\], AverageLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt

# egrep '\[UPDATE\], AverageLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt


# 48 threads

#numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
#numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

rm mpstat_48_output.txt
mpstat -N 0,1 2 | tee mpstat_48_output.txt &           #CHECK    # Node 0 and 1 details →  avg %iowait, avg %idle time
mpstat_pid=$!
echo "mpstatpid=$mpstat_pid"

id=48
count=1

output_memory $id $count >> mpstat_out.csv

strace -c -S name -f -o >(cat >> dummy_strace_output_combined48_threads.txt) numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt

count=$((count+1))
output_memory $id $count >> mpstat_out.csv

strace -c -S name -f -o >(cat >> dummy_strace_output_combined48_threads.txt) numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt

count=$((count+1))
output_memory $id $count >> mpstat_out.csv

strace -c -S name -f -o >(cat >> dummy_strace_output_combined48_threads.txt) numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt

kill $mpstat_pid
count=$((count+1))
output_memory $id $count >> mpstat_out.csv

count=0

egrep '\[OVERALL\], RunTime\(ms\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_48.txt | awk '{print $3}' >> p1_48.txt

egrep '\[READ\], AverageLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt



sed -i -e 1,2d mpstat_48_output.txt               # to remove top 2 unnecessary lines
sed -i '/^$/d' mpstat_48_output.txt               # to remove all empty lines
sed -i '1d; n; d' mpstat_48_output.txt            # to remove all header lines / odd lines
#awk '{print $7}' mpstat_48_output.txt | awk 'BEGIN{sum=0; line=0}{sum=sum+$1; line=line+1} END{print "%iowait_Total=",sum, "%iowait_Avg=", sum/line}'
#awk '{print $13}' mpstat_48_output.txt | awk 'BEGIN{sum=0; line=0}{sum=sum+$1; line=line+1} END{print "%NodeIdle_Total=",sum, "%NodeIdle_Avg=", sum/line}'


iowait_Total=$(awk '{sum+=$7} END{print sum}' mpstat_48_output.txt)
iowait_Average=$(awk '{sum+=$7} END{print sum/NR}' mpstat_48_output.txt)

echo "$id,$iowait_Total,$iowait_Average" >> mpstat_ioavg_output.txt

# 52 threads

#numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
#numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

rm mpstat_52_output.txt
mpstat -N 0,1 2 | tee mpstat_52_output.txt &           #CHECK    # Node 0 and 1 details →  avg %iowait, avg %idle time
mpstat_pid=$!
echo "mpstatpid=$mpstat_pid"

id=52
count=1

output_memory $id $count >> mpstat_out.csv

strace -c -S name -f -o >(cat >> dummy_strace_output_combined52_threads.txt) numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt

count=$((count+1))
output_memory $id $count >> mpstat_out.csv

strace -c -S name -f -o >(cat >> dummy_strace_output_combined52_threads.txt) numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt

count=$((count+1))
output_memory $id $count >> mpstat_out.csv

strace -c -S name -f -o >(cat >> dummy_strace_output_combined52_threads.txt) numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt

kill $mpstat_pid
count=$((count+1))
output_memory $id $count >> mpstat_out.csv

count=0
egrep '\[OVERALL\], RunTime\(ms\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_52.txt | awk '{print $3}' >> p1_52.txt

egrep '\[READ\], AverageLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt



sed -i -e 1,2d mpstat_52_output.txt               # to remove top 2 unnecessary lines
sed -i '/^$/d' mpstat_52_output.txt               # to remove all empty lines
sed -i '1d; n; d' mpstat_52_output.txt            # to remove all header lines / odd lines
#awk '{print $7}' mpstat_52_output.txt | awk 'BEGIN{sum=0; line=0}{sum=sum+$1; line=line+1} END{print "%iowait_Total=",sum, "%iowait_Avg=", sum/line}'
#awk '{print $13}' mpstat_52_output.txt | awk 'BEGIN{sum=0; line=0}{sum=sum+$1; line=line+1} END{print "%NodeIdle_Total=",sum, "%NodeIdle_Avg=", sum/line}'

iowait_Total=$(awk '{sum+=$7} END{print sum}' mpstat_52_output.txt)
iowait_Average=$(awk '{sum+=$7} END{print sum/NR}' mpstat_52_output.txt)

echo "$id,$iowait_Total,$iowait_Average" >> mpstat_ioavg_output.txt

#################################################################################################################

