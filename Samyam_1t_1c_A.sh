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







# 2 threads
# RUN 1 (EXTRA)
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
# RUN 2 (EXTRA)
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0


# RUN 3
numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_2.txt
# RUN 4
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_2.txt
# RUN 5
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_2.txt

echo "Runtime, Throughput" >> p1_2.txt
egrep '\[OVERALL\], RunTime\(ms\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_2.txt | awk '{print $3}' >> p1_2.txt

echo "READ - AvgLatency, 95th Per, 99th Per" >> p1_2.txt
egrep '\[READ\], AverageLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt

echo "UPDATE - AvgLatency, 95th Per, 99th Per" >> p1_2.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt


# 4 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_4.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_4.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_4.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_4.txt | awk '{print $3}' >> p1_4.txt

egrep '\[READ\], AverageLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt


# 8 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_8.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_8.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_8.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_8.txt | awk '{print $3}' >> p1_8.txt

egrep '\[READ\], AverageLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt


# 12 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_12.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_12.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_12.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_12.txt | awk '{print $3}' >> p1_12.txt

egrep '\[READ\], AverageLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt


# 16 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_16.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_16.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_16.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_16.txt | awk '{print $3}' >> p1_16.txt

egrep '\[READ\], AverageLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt


# 20 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0


numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_20.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_20.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_20.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_20.txt | awk '{print $3}' >> p1_20.txt

egrep '\[READ\], AverageLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt


# 24 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_24.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_24.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_24.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_24.txt | awk '{print $3}' >> p1_24.txt

egrep '\[READ\], AverageLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt


# 28 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_28.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_28.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_28.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_28.txt | awk '{print $3}' >> p1_28.txt

egrep '\[READ\], AverageLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt


# 32 threads

numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_32.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_32.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_32.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_32.txt | awk '{print $3}' >> p1_32.txt

egrep '\[READ\], AverageLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt


# 36 threads

numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_36.txt 
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_36.txt 
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_36.txt 

egrep '\[OVERALL\], RunTime\(ms\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_36.txt | awk '{print $3}' >> p1_36.txt

egrep '\[READ\], AverageLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt


# 40 threads

numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 

numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_40.txt 
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_40.txt 
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_40.txt 


egrep '\[OVERALL\], RunTime\(ms\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_40.txt | awk '{print $3}' >> p1_40.txt

egrep '\[READ\], AverageLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt

# 44 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_44.txt | awk '{print $3}' >> p1_44.txt

egrep '\[READ\], AverageLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt


# 48 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_48.txt | awk '{print $3}' >> p1_48.txt

egrep '\[READ\], AverageLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt




# 52 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_52.txt | awk '{print $3}' >> p1_52.txt

egrep '\[READ\], AverageLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt


# 56 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_56.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_56.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_56.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_56.txt | awk '{print $3}' >> p1_56.txt

egrep '\[READ\], AverageLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt


# 60 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_60.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_60.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_60.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_60.txt | awk '{print $3}' >> p1_60.txt

egrep '\[READ\], AverageLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt


# 64 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_64.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_64.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_64.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_64.txt | awk '{print $3}' >> p1_64.txt

egrep '\[READ\], AverageLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt


# 68 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_68.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_68.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_68.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_68.txt | awk '{print $3}' >> p1_68.txt

egrep '\[READ\], AverageLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt


# 72 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_72.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_72.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_72.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_72.txt | awk '{print $3}' >> p1_72.txt

egrep '\[READ\], AverageLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt


# 76 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_76.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_76.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_76.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_76.txt | awk '{print $3}' >> p1_76.txt

egrep '\[READ\], AverageLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt


# 80 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_80.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_80.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_80.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_80.txt | awk '{print $3}' >> p1_80.txt

egrep '\[READ\], AverageLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt


# 84 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_84.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_84.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_84.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_84.txt | awk '{print $3}' >> p1_84.txt

egrep '\[READ\], AverageLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt


# 88 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_88.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_88.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_88.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_88.txt | awk '{print $3}' >> p1_88.txt

egrep '\[READ\], AverageLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt


# 92 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_92.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_92.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_92.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_92.txt | awk '{print $3}' >> p1_92.txt

egrep '\[READ\], AverageLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt


# 96 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_96.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_96.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_96.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_96.txt | awk '{print $3}' >> p1_96.txt

egrep '\[READ\], AverageLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt


# 100 threads

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0

numactl  --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_100.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_100.txt
numactl --physcpubind=8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_100.txt

egrep '\[OVERALL\], RunTime\(ms\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_100.txt | awk '{print $3}' >> p1_100.txt

egrep '\[READ\], AverageLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt

egrep '\[UPDATE\], AverageLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt




