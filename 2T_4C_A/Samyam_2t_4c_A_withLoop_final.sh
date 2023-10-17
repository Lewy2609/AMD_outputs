#!/usr/local/bin/bash

# WORKLOAD A...... 1t_4c

#[node0(0,1,2,3,16,17,18,19), node1(4,5,6,7,20,21,22,23), node2(8,9,10,11,24,25,26,27), node3(12,13,14,15,28,29,30,31)]

# node0(0,1,2,3,16,17,18,19) -> server
# 4,5,6,7,8,9 -> client1
# 10,11,12,13,14,15 -> client2
# 20,21,22,23,24,25 -> client3
# 26,27,28,29,30,31 -> client4

:<<'EOF'

# MongoDB Server Run -> in node0
sudo systemctl stop mongod
sudo systemctl status mongod
numactl --physcpubind=0,1,2,3,16,17,18,19 sudo systemctl start mongod
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
# Loads 2 tables into DB
numactl --physcpubind=4,5,6,7,20,21,22,23 ./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=10000000 -p table=usertable1 -threads 32 -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 &

numactl --physcpubind=12,13,14,15,28,29,30,31 ./bin/ycsb load mongodb -s -P workloads/workloada -p recordcount=10000000 -p table=usertable2 -threads 32 -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 &


# Check DB
mongosh
        show dbs
        use ycsb
        show collections
        db.usertable1.find().count()
        db.usertable2.find().count()
        exit


# Remove files if any
rm p1_*.txt
rm p2_*.txt
rm p3_*.txt
rm p4_*.txt


 Run these ||ly

# Terminal 1 : (RUN ON SERVER NODES)
sudo perf stat -d -d -d -C 0,1,2,3,16,17,18,19


# Terminal 2: (RUN ON SERVER NODES)
sudo perf stat -d -d -d -C 0,1,2,3,16,17,18,19 -e task-clock,major-faults,minor-faults,cache-references,cache-misses


# Terminal 3: (RUN ON SERVER NODES)
sudo perf record -g -C 0,1,2,3,16,17,18,19
mv perf.data perf.data.1T_1C_.....

sudo perf report -g -i perf.data
sudo perf diff perf.data.1T_ perf.data.2T_


# Terminal 4: (RUN ON SERVER NODES)
rm mp.txt
mpstat -N 0 2 | tee mp.txt           #CHECK    # Node 0 details →  avg %iowait, avg %idle time


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

EOF

# Run phase
# 4 process access 2 table


# # 4 prallel processes -threads 2
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 2"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_2.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_2.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_2.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_2.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt




# # 4 prallel processes -threads 4
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 4"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_4.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_4.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_4.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_4.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_4.txt | awk '{print $3}' >> p1_4.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_4.txt | awk '{print $3}' >> p2_4.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_4.txt | awk '{print $3}' >> p2_4.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_4.txt | awk '{print $3}' >> p2_4.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_4.txt | awk '{print $3}' >> p2_4.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_4.txt | awk '{print $3}' >> p2_4.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_4.txt | awk '{print $3}' >> p2_4.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_4.txt | awk '{print $3}' >> p2_4.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_4.txt | awk '{print $3}' >> p2_4.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_4.txt | awk '{print $3}' >> p3_4.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_4.txt | awk '{print $3}' >> p3_4.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_4.txt | awk '{print $3}' >> p3_4.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_4.txt | awk '{print $3}' >> p3_4.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_4.txt | awk '{print $3}' >> p3_4.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_4.txt | awk '{print $3}' >> p3_4.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_4.txt | awk '{print $3}' >> p3_4.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_4.txt | awk '{print $3}' >> p3_4.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_4.txt | awk '{print $3}' >> p4_4.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_4.txt | awk '{print $3}' >> p4_4.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_4.txt | awk '{print $3}' >> p4_4.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_4.txt | awk '{print $3}' >> p4_4.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_4.txt | awk '{print $3}' >> p4_4.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_4.txt | awk '{print $3}' >> p4_4.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_4.txt | awk '{print $3}' >> p4_4.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_4.txt | awk '{print $3}' >> p4_4.txt


# # 4 prallel processes -threads 8
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 8"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_8.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_8.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_8.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 8 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_8.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_8.txt | awk '{print $3}' >> p1_8.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_8.txt | awk '{print $3}' >> p2_8.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_8.txt | awk '{print $3}' >> p2_8.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_8.txt | awk '{print $3}' >> p2_8.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_8.txt | awk '{print $3}' >> p2_8.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_8.txt | awk '{print $3}' >> p2_8.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_8.txt | awk '{print $3}' >> p2_8.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_8.txt | awk '{print $3}' >> p2_8.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_8.txt | awk '{print $3}' >> p2_8.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_8.txt | awk '{print $3}' >> p3_8.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_8.txt | awk '{print $3}' >> p3_8.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_8.txt | awk '{print $3}' >> p3_8.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_8.txt | awk '{print $3}' >> p3_8.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_8.txt | awk '{print $3}' >> p3_8.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_8.txt | awk '{print $3}' >> p3_8.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_8.txt | awk '{print $3}' >> p3_8.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_8.txt | awk '{print $3}' >> p3_8.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_8.txt | awk '{print $3}' >> p4_8.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_8.txt | awk '{print $3}' >> p4_8.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_8.txt | awk '{print $3}' >> p4_8.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_8.txt | awk '{print $3}' >> p4_8.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_8.txt | awk '{print $3}' >> p4_8.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_8.txt | awk '{print $3}' >> p4_8.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_8.txt | awk '{print $3}' >> p4_8.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_8.txt | awk '{print $3}' >> p4_8.txt


# # 4 prallel processes -threads 12
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 12"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_12.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_12.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_12.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 12 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_12.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_12.txt | awk '{print $3}' >> p1_12.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_12.txt | awk '{print $3}' >> p2_12.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_12.txt | awk '{print $3}' >> p2_12.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_12.txt | awk '{print $3}' >> p2_12.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_12.txt | awk '{print $3}' >> p2_12.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_12.txt | awk '{print $3}' >> p2_12.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_12.txt | awk '{print $3}' >> p2_12.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_12.txt | awk '{print $3}' >> p2_12.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_12.txt | awk '{print $3}' >> p2_12.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_12.txt | awk '{print $3}' >> p3_12.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_12.txt | awk '{print $3}' >> p3_12.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_12.txt | awk '{print $3}' >> p3_12.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_12.txt | awk '{print $3}' >> p3_12.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_12.txt | awk '{print $3}' >> p3_12.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_12.txt | awk '{print $3}' >> p3_12.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_12.txt | awk '{print $3}' >> p3_12.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_12.txt | awk '{print $3}' >> p3_12.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_12.txt | awk '{print $3}' >> p4_12.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_12.txt | awk '{print $3}' >> p4_12.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_12.txt | awk '{print $3}' >> p4_12.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_12.txt | awk '{print $3}' >> p4_12.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_12.txt | awk '{print $3}' >> p4_12.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_12.txt | awk '{print $3}' >> p4_12.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_12.txt | awk '{print $3}' >> p4_12.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_12.txt | awk '{print $3}' >> p4_12.txt


# # 4 prallel processes -threads 16
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 16"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_16.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_16.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_16.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 16 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_16.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_16.txt | awk '{print $3}' >> p1_16.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_16.txt | awk '{print $3}' >> p2_16.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_16.txt | awk '{print $3}' >> p2_16.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_16.txt | awk '{print $3}' >> p2_16.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_16.txt | awk '{print $3}' >> p2_16.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_16.txt | awk '{print $3}' >> p2_16.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_16.txt | awk '{print $3}' >> p2_16.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_16.txt | awk '{print $3}' >> p2_16.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_16.txt | awk '{print $3}' >> p2_16.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_16.txt | awk '{print $3}' >> p3_16.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_16.txt | awk '{print $3}' >> p3_16.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_16.txt | awk '{print $3}' >> p3_16.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_16.txt | awk '{print $3}' >> p3_16.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_16.txt | awk '{print $3}' >> p3_16.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_16.txt | awk '{print $3}' >> p3_16.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_16.txt | awk '{print $3}' >> p3_16.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_16.txt | awk '{print $3}' >> p3_16.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_16.txt | awk '{print $3}' >> p4_16.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_16.txt | awk '{print $3}' >> p4_16.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_16.txt | awk '{print $3}' >> p4_16.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_16.txt | awk '{print $3}' >> p4_16.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_16.txt | awk '{print $3}' >> p4_16.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_16.txt | awk '{print $3}' >> p4_16.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_16.txt | awk '{print $3}' >> p4_16.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_16.txt | awk '{print $3}' >> p4_16.txt


# # 4 prallel processes -threads 20
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 20"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_20.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_20.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_20.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 20 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_20.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_20.txt | awk '{print $3}' >> p1_20.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_20.txt | awk '{print $3}' >> p2_20.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_20.txt | awk '{print $3}' >> p2_20.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_20.txt | awk '{print $3}' >> p2_20.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_20.txt | awk '{print $3}' >> p2_20.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_20.txt | awk '{print $3}' >> p2_20.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_20.txt | awk '{print $3}' >> p2_20.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_20.txt | awk '{print $3}' >> p2_20.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_20.txt | awk '{print $3}' >> p2_20.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_20.txt | awk '{print $3}' >> p3_20.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_20.txt | awk '{print $3}' >> p3_20.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_20.txt | awk '{print $3}' >> p3_20.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_20.txt | awk '{print $3}' >> p3_20.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_20.txt | awk '{print $3}' >> p3_20.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_20.txt | awk '{print $3}' >> p3_20.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_20.txt | awk '{print $3}' >> p3_20.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_20.txt | awk '{print $3}' >> p3_20.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_20.txt | awk '{print $3}' >> p4_20.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_20.txt | awk '{print $3}' >> p4_20.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_20.txt | awk '{print $3}' >> p4_20.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_20.txt | awk '{print $3}' >> p4_20.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_20.txt | awk '{print $3}' >> p4_20.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_20.txt | awk '{print $3}' >> p4_20.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_20.txt | awk '{print $3}' >> p4_20.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_20.txt | awk '{print $3}' >> p4_20.txt


# # 4 prallel processes -threads 24
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 24"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_24.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_24.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_24.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 24 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_24.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_24.txt | awk '{print $3}' >> p1_24.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_24.txt | awk '{print $3}' >> p2_24.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_24.txt | awk '{print $3}' >> p2_24.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_24.txt | awk '{print $3}' >> p2_24.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_24.txt | awk '{print $3}' >> p2_24.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_24.txt | awk '{print $3}' >> p2_24.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_24.txt | awk '{print $3}' >> p2_24.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_24.txt | awk '{print $3}' >> p2_24.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_24.txt | awk '{print $3}' >> p2_24.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_24.txt | awk '{print $3}' >> p3_24.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_24.txt | awk '{print $3}' >> p3_24.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_24.txt | awk '{print $3}' >> p3_24.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_24.txt | awk '{print $3}' >> p3_24.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_24.txt | awk '{print $3}' >> p3_24.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_24.txt | awk '{print $3}' >> p3_24.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_24.txt | awk '{print $3}' >> p3_24.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_24.txt | awk '{print $3}' >> p3_24.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_24.txt | awk '{print $3}' >> p4_24.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_24.txt | awk '{print $3}' >> p4_24.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_24.txt | awk '{print $3}' >> p4_24.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_24.txt | awk '{print $3}' >> p4_24.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_24.txt | awk '{print $3}' >> p4_24.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_24.txt | awk '{print $3}' >> p4_24.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_24.txt | awk '{print $3}' >> p4_24.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_24.txt | awk '{print $3}' >> p4_24.txt


# # 4 prallel processes -threads 28
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 28"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_28.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_28.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_28.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 28 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_28.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_28.txt | awk '{print $3}' >> p1_28.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_28.txt | awk '{print $3}' >> p2_28.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_28.txt | awk '{print $3}' >> p2_28.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_28.txt | awk '{print $3}' >> p2_28.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_28.txt | awk '{print $3}' >> p2_28.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_28.txt | awk '{print $3}' >> p2_28.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_28.txt | awk '{print $3}' >> p2_28.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_28.txt | awk '{print $3}' >> p2_28.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_28.txt | awk '{print $3}' >> p2_28.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_28.txt | awk '{print $3}' >> p3_28.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_28.txt | awk '{print $3}' >> p3_28.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_28.txt | awk '{print $3}' >> p3_28.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_28.txt | awk '{print $3}' >> p3_28.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_28.txt | awk '{print $3}' >> p3_28.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_28.txt | awk '{print $3}' >> p3_28.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_28.txt | awk '{print $3}' >> p3_28.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_28.txt | awk '{print $3}' >> p3_28.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_28.txt | awk '{print $3}' >> p4_28.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_28.txt | awk '{print $3}' >> p4_28.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_28.txt | awk '{print $3}' >> p4_28.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_28.txt | awk '{print $3}' >> p4_28.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_28.txt | awk '{print $3}' >> p4_28.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_28.txt | awk '{print $3}' >> p4_28.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_28.txt | awk '{print $3}' >> p4_28.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_28.txt | awk '{print $3}' >> p4_28.txt


# # 4 prallel processes -threads 32
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 32"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_32.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_32.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_32.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_32.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_32.txt | awk '{print $3}' >> p1_32.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_32.txt | awk '{print $3}' >> p2_32.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_32.txt | awk '{print $3}' >> p2_32.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_32.txt | awk '{print $3}' >> p2_32.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_32.txt | awk '{print $3}' >> p2_32.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_32.txt | awk '{print $3}' >> p2_32.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_32.txt | awk '{print $3}' >> p2_32.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_32.txt | awk '{print $3}' >> p2_32.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_32.txt | awk '{print $3}' >> p2_32.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_32.txt | awk '{print $3}' >> p3_32.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_32.txt | awk '{print $3}' >> p3_32.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_32.txt | awk '{print $3}' >> p3_32.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_32.txt | awk '{print $3}' >> p3_32.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_32.txt | awk '{print $3}' >> p3_32.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_32.txt | awk '{print $3}' >> p3_32.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_32.txt | awk '{print $3}' >> p3_32.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_32.txt | awk '{print $3}' >> p3_32.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_32.txt | awk '{print $3}' >> p4_32.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_32.txt | awk '{print $3}' >> p4_32.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_32.txt | awk '{print $3}' >> p4_32.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_32.txt | awk '{print $3}' >> p4_32.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_32.txt | awk '{print $3}' >> p4_32.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_32.txt | awk '{print $3}' >> p4_32.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_32.txt | awk '{print $3}' >> p4_32.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_32.txt | awk '{print $3}' >> p4_32.txt


# # 4 prallel processes -threads 36
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 36"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_36.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_36.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_36.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 36 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_36.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_36.txt | awk '{print $3}' >> p1_36.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_36.txt | awk '{print $3}' >> p2_36.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_36.txt | awk '{print $3}' >> p2_36.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_36.txt | awk '{print $3}' >> p2_36.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_36.txt | awk '{print $3}' >> p2_36.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_36.txt | awk '{print $3}' >> p2_36.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_36.txt | awk '{print $3}' >> p2_36.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_36.txt | awk '{print $3}' >> p2_36.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_36.txt | awk '{print $3}' >> p2_36.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_36.txt | awk '{print $3}' >> p3_36.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_36.txt | awk '{print $3}' >> p3_36.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_36.txt | awk '{print $3}' >> p3_36.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_36.txt | awk '{print $3}' >> p3_36.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_36.txt | awk '{print $3}' >> p3_36.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_36.txt | awk '{print $3}' >> p3_36.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_36.txt | awk '{print $3}' >> p3_36.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_36.txt | awk '{print $3}' >> p3_36.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_36.txt | awk '{print $3}' >> p4_36.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_36.txt | awk '{print $3}' >> p4_36.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_36.txt | awk '{print $3}' >> p4_36.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_36.txt | awk '{print $3}' >> p4_36.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_36.txt | awk '{print $3}' >> p4_36.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_36.txt | awk '{print $3}' >> p4_36.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_36.txt | awk '{print $3}' >> p4_36.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_36.txt | awk '{print $3}' >> p4_36.txt


# # 4 prallel processes -threads 40
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 40"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_40.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_40.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_40.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 40 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_40.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_40.txt | awk '{print $3}' >> p1_40.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_40.txt | awk '{print $3}' >> p2_40.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_40.txt | awk '{print $3}' >> p2_40.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_40.txt | awk '{print $3}' >> p2_40.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_40.txt | awk '{print $3}' >> p2_40.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_40.txt | awk '{print $3}' >> p2_40.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_40.txt | awk '{print $3}' >> p2_40.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_40.txt | awk '{print $3}' >> p2_40.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_40.txt | awk '{print $3}' >> p2_40.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_40.txt | awk '{print $3}' >> p3_40.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_40.txt | awk '{print $3}' >> p3_40.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_40.txt | awk '{print $3}' >> p3_40.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_40.txt | awk '{print $3}' >> p3_40.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_40.txt | awk '{print $3}' >> p3_40.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_40.txt | awk '{print $3}' >> p3_40.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_40.txt | awk '{print $3}' >> p3_40.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_40.txt | awk '{print $3}' >> p3_40.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_40.txt | awk '{print $3}' >> p4_40.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_40.txt | awk '{print $3}' >> p4_40.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_40.txt | awk '{print $3}' >> p4_40.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_40.txt | awk '{print $3}' >> p4_40.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_40.txt | awk '{print $3}' >> p4_40.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_40.txt | awk '{print $3}' >> p4_40.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_40.txt | awk '{print $3}' >> p4_40.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_40.txt | awk '{print $3}' >> p4_40.txt


# # 4 prallel processes -threads 44
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 44"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_44.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_44.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_44.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_44.txt | awk '{print $3}' >> p1_44.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_44.txt | awk '{print $3}' >> p2_44.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_44.txt | awk '{print $3}' >> p2_44.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_44.txt | awk '{print $3}' >> p2_44.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_44.txt | awk '{print $3}' >> p2_44.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_44.txt | awk '{print $3}' >> p2_44.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_44.txt | awk '{print $3}' >> p2_44.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_44.txt | awk '{print $3}' >> p2_44.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_44.txt | awk '{print $3}' >> p2_44.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_44.txt | awk '{print $3}' >> p3_44.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_44.txt | awk '{print $3}' >> p3_44.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_44.txt | awk '{print $3}' >> p3_44.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_44.txt | awk '{print $3}' >> p3_44.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_44.txt | awk '{print $3}' >> p3_44.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_44.txt | awk '{print $3}' >> p3_44.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_44.txt | awk '{print $3}' >> p3_44.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_44.txt | awk '{print $3}' >> p3_44.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_44.txt | awk '{print $3}' >> p4_44.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_44.txt | awk '{print $3}' >> p4_44.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_44.txt | awk '{print $3}' >> p4_44.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_44.txt | awk '{print $3}' >> p4_44.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_44.txt | awk '{print $3}' >> p4_44.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_44.txt | awk '{print $3}' >> p4_44.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_44.txt | awk '{print $3}' >> p4_44.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_44.txt | awk '{print $3}' >> p4_44.txt


# 4 prallel processes -threads 48
# 3 RUNS

count=1
#for (( ; count <= 3 ; )); do
while [ $count -le 3 ]
do
        echo "RUN $count -threads 48"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_481_threads.txt
        echo "PID1 = $pid1"

        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_48.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_482_threads.txt
        echo "PID2 = $pid2"

        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_48.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_483_threads.txt
        echo "PID3 = $pid3"

        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_48.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_484_threads.txt
        echo "PID4 = $pid4"

        # Search for the word "ERROR" in the logs
        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_4*
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            #((count++))
            count=$((count+1))
            #echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_4* >> strace_output_combined_finalloop_48_threads.txt 
        fi
        rm logs.txt
done

echo "tranfering all data to .txt file"
egrep '\[OVERALL\], RunTime\(ms\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[READ\], AverageLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_48.txt | awk '{print $3}' >> p1_48.txt

egrep '\[OVERALL\], RunTime\(ms\)' p2_48.txt | awk '{print $3}' >> p2_48.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_48.txt | awk '{print $3}' >> p2_48.txt
egrep '\[READ\], AverageLatency\(us\)' p2_48.txt | awk '{print $3}' >> p2_48.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p2_48.txt | awk '{print $3}' >> p2_48.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p2_48.txt | awk '{print $3}' >> p2_48.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p2_48.txt | awk '{print $3}' >> p2_48.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_48.txt | awk '{print $3}' >> p2_48.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_48.txt | awk '{print $3}' >> p2_48.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_48.txt | awk '{print $3}' >> p3_48.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_48.txt | awk '{print $3}' >> p3_48.txt
egrep '\[READ\], AverageLatency\(us\)' p3_48.txt | awk '{print $3}' >> p3_48.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p3_48.txt | awk '{print $3}' >> p3_48.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p3_48.txt | awk '{print $3}' >> p3_48.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p3_48.txt | awk '{print $3}' >> p3_48.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_48.txt | awk '{print $3}' >> p3_48.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_48.txt | awk '{print $3}' >> p3_48.txt

egrep '\[OVERALL\], RunTime\(ms\)' p4_48.txt | awk '{print $3}' >> p4_48.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_48.txt | awk '{print $3}' >> p4_48.txt
egrep '\[READ\], AverageLatency\(us\)' p4_48.txt | awk '{print $3}' >> p4_48.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p4_48.txt | awk '{print $3}' >> p4_48.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p4_48.txt | awk '{print $3}' >> p4_48.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p4_48.txt | awk '{print $3}' >> p4_48.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_48.txt | awk '{print $3}' >> p4_48.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_48.txt | awk '{print $3}' >> p4_48.txt


# 4 prallel processes -threads 52
# 3 RUNS

count=1
#for (( ; count <= 3 ; )); do
while [ $count -le 3 ]
do
        echo "RUN $count -threads 52"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_521_threads.txt
        echo "PID1 = $pid1"

        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_52.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_522_threads.txt
        echo "PID2 = $pid2"

        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_52.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_523_threads.txt
        echo "PID3 = $pid3"

        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_52.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_524_threads.txt
        echo "PID4 = $pid4"

        # Search for the word "ERROR" in the logs
        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_5*
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            #((count++))
            count=$((count+1))
            #echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_5* >> strace_output_combined_finalloop_52_threads.txt
            rm strace_output_combined_innerloop_5*
        fi
        rm logs.txt
done

echo "tranfering all data to .txt file"
egrep '\[OVERALL\], RunTime\(ms\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[READ\], AverageLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_52.txt | awk '{print $3}' >> p1_52.txt

egrep '\[OVERALL\], RunTime\(ms\)' p2_52.txt | awk '{print $3}' >> p2_52.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_52.txt | awk '{print $3}' >> p2_52.txt
egrep '\[READ\], AverageLatency\(us\)' p2_52.txt | awk '{print $3}' >> p2_52.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p2_52.txt | awk '{print $3}' >> p2_52.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p2_52.txt | awk '{print $3}' >> p2_52.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p2_52.txt | awk '{print $3}' >> p2_52.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_52.txt | awk '{print $3}' >> p2_52.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_52.txt | awk '{print $3}' >> p2_52.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_52.txt | awk '{print $3}' >> p3_52.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_52.txt | awk '{print $3}' >> p3_52.txt
egrep '\[READ\], AverageLatency\(us\)' p3_52.txt | awk '{print $3}' >> p3_52.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p3_52.txt | awk '{print $3}' >> p3_52.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p3_52.txt | awk '{print $3}' >> p3_52.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p3_52.txt | awk '{print $3}' >> p3_52.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_52.txt | awk '{print $3}' >> p3_52.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_52.txt | awk '{print $3}' >> p3_52.txt

egrep '\[OVERALL\], RunTime\(ms\)' p4_52.txt | awk '{print $3}' >> p4_52.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_52.txt | awk '{print $3}' >> p4_52.txt
egrep '\[READ\], AverageLatency\(us\)' p4_52.txt | awk '{print $3}' >> p4_52.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p4_52.txt | awk '{print $3}' >> p4_52.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p4_52.txt | awk '{print $3}' >> p4_52.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p4_52.txt | awk '{print $3}' >> p4_52.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_52.txt | awk '{print $3}' >> p4_52.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_52.txt | awk '{print $3}' >> p4_52.txt


# 4 prallel processes -threads 56
# 3 RUNS

count=1
#for (( ; count <= 3 ; )); do
while [ $count -le 3 ]
do
        echo "RUN $count -threads 56"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_56.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_561_threads.txt
        echo "PID1 = $pid1"

        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_56.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_562_threads.txt
        echo "PID2 = $pid2"

        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_56.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_563_threads.txt
        echo "PID3 = $pid3"

        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 56 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_56.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_564_threads.txt
        echo "PID4 = $pid4"

        # Search for the word "ERROR" in the logs
        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_5*
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            #((count++))
            count=$((count+1))
            #echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_5* >> strace_output_combined_finalloop_56_threads.txt
            rm strace_output_combined_innerloop_5*
        fi
        rm logs.txt
done

echo "tranfering all data to .txt file"
egrep '\[OVERALL\], RunTime\(ms\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[READ\], AverageLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_56.txt | awk '{print $3}' >> p1_56.txt

egrep '\[OVERALL\], RunTime\(ms\)' p2_56.txt | awk '{print $3}' >> p2_56.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_56.txt | awk '{print $3}' >> p2_56.txt
egrep '\[READ\], AverageLatency\(us\)' p2_56.txt | awk '{print $3}' >> p2_56.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p2_56.txt | awk '{print $3}' >> p2_56.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p2_56.txt | awk '{print $3}' >> p2_56.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p2_56.txt | awk '{print $3}' >> p2_56.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_56.txt | awk '{print $3}' >> p2_56.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_56.txt | awk '{print $3}' >> p2_56.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_56.txt | awk '{print $3}' >> p3_56.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_56.txt | awk '{print $3}' >> p3_56.txt
egrep '\[READ\], AverageLatency\(us\)' p3_56.txt | awk '{print $3}' >> p3_56.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p3_56.txt | awk '{print $3}' >> p3_56.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p3_56.txt | awk '{print $3}' >> p3_56.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p3_56.txt | awk '{print $3}' >> p3_56.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_56.txt | awk '{print $3}' >> p3_56.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_56.txt | awk '{print $3}' >> p3_56.txt

egrep '\[OVERALL\], RunTime\(ms\)' p4_56.txt | awk '{print $3}' >> p4_56.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_56.txt | awk '{print $3}' >> p4_56.txt
egrep '\[READ\], AverageLatency\(us\)' p4_56.txt | awk '{print $3}' >> p4_56.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p4_56.txt | awk '{print $3}' >> p4_56.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p4_56.txt | awk '{print $3}' >> p4_56.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p4_56.txt | awk '{print $3}' >> p4_56.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_56.txt | awk '{print $3}' >> p4_56.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_56.txt | awk '{print $3}' >> p4_56.txt


# 4 prallel processes -threads 60
# 3 RUNS

count=1
#for (( ; count <= 3 ; )); do
while [ $count -le 3 ]
do
        echo "RUN $count -threads 60"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_60.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_601_threads.txt
        echo "PID1 = $pid1"

        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_60.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_602_threads.txt
        echo "PID2 = $pid2"

        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_60.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_603_threads.txt
        echo "PID3 = $pid3"

        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 60 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_60.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_604_threads.txt
        echo "PID4 = $pid4"

        # Search for the word "ERROR" in the logs
        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_6*
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            #((count++))
            count=$((count+1))
            #echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_6* >> strace_output_combined_finalloop_60_threads.txt
            rm strace_output_combined_innerloop_6*
        fi
        rm logs.txt
done

echo "tranfering all data to .txt file"
egrep '\[OVERALL\], RunTime\(ms\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[READ\], AverageLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_60.txt | awk '{print $3}' >> p1_60.txt

egrep '\[OVERALL\], RunTime\(ms\)' p2_60.txt | awk '{print $3}' >> p2_60.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_60.txt | awk '{print $3}' >> p2_60.txt
egrep '\[READ\], AverageLatency\(us\)' p2_60.txt | awk '{print $3}' >> p2_60.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p2_60.txt | awk '{print $3}' >> p2_60.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p2_60.txt | awk '{print $3}' >> p2_60.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p2_60.txt | awk '{print $3}' >> p2_60.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_60.txt | awk '{print $3}' >> p2_60.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_60.txt | awk '{print $3}' >> p2_60.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_60.txt | awk '{print $3}' >> p3_60.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_60.txt | awk '{print $3}' >> p3_60.txt
egrep '\[READ\], AverageLatency\(us\)' p3_60.txt | awk '{print $3}' >> p3_60.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p3_60.txt | awk '{print $3}' >> p3_60.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p3_60.txt | awk '{print $3}' >> p3_60.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p3_60.txt | awk '{print $3}' >> p3_60.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_60.txt | awk '{print $3}' >> p3_60.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_60.txt | awk '{print $3}' >> p3_60.txt

egrep '\[OVERALL\], RunTime\(ms\)' p4_60.txt | awk '{print $3}' >> p4_60.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_60.txt | awk '{print $3}' >> p4_60.txt
egrep '\[READ\], AverageLatency\(us\)' p4_60.txt | awk '{print $3}' >> p4_60.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p4_60.txt | awk '{print $3}' >> p4_60.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p4_60.txt | awk '{print $3}' >> p4_60.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p4_60.txt | awk '{print $3}' >> p4_60.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_60.txt | awk '{print $3}' >> p4_60.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_60.txt | awk '{print $3}' >> p4_60.txt






# 4 processes -threads 64
# 3 RUNS

count=1
#for (( ; count <= 3 ; )); do
while [ $count -le 3 ]
do
        echo "RUN $count -threads 64"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_64.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_641_threads.txt
        echo "PID1 = $pid1"

        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_64.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_642_threads.txt
        echo "PID2 = $pid2"

        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_64.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_643_threads.txt
        echo "PID3 = $pid3"

        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 64 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_64.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_644_threads.txt
        echo "PID4 = $pid4"

        # Search for the word "ERROR" in the logs
        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_6*
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            #((count++))
            count=$((count+1))
            #echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_6* >> strace_output_combined_finalloop_64_threads.txt
            rm strace_output_combined_innerloop_6*
        fi
        rm logs.txt
done

echo "tranfering all data to .txt file"
egrep '\[OVERALL\], RunTime\(ms\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[READ\], AverageLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_64.txt | awk '{print $3}' >> p1_64.txt

egrep '\[OVERALL\], RunTime\(ms\)' p2_64.txt | awk '{print $3}' >> p2_64.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_64.txt | awk '{print $3}' >> p2_64.txt
egrep '\[READ\], AverageLatency\(us\)' p2_64.txt | awk '{print $3}' >> p2_64.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p2_64.txt | awk '{print $3}' >> p2_64.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p2_64.txt | awk '{print $3}' >> p2_64.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p2_64.txt | awk '{print $3}' >> p2_64.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_64.txt | awk '{print $3}' >> p2_64.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_64.txt | awk '{print $3}' >> p2_64.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_64.txt | awk '{print $3}' >> p3_64.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_64.txt | awk '{print $3}' >> p3_64.txt
egrep '\[READ\], AverageLatency\(us\)' p3_64.txt | awk '{print $3}' >> p3_64.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p3_64.txt | awk '{print $3}' >> p3_64.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p3_64.txt | awk '{print $3}' >> p3_64.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p3_64.txt | awk '{print $3}' >> p3_64.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_64.txt | awk '{print $3}' >> p3_64.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_64.txt | awk '{print $3}' >> p3_64.txt

egrep '\[OVERALL\], RunTime\(ms\)' p4_64.txt | awk '{print $3}' >> p4_64.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_64.txt | awk '{print $3}' >> p4_64.txt
egrep '\[READ\], AverageLatency\(us\)' p4_64.txt | awk '{print $3}' >> p4_64.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p4_64.txt | awk '{print $3}' >> p4_64.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p4_64.txt | awk '{print $3}' >> p4_64.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p4_64.txt | awk '{print $3}' >> p4_64.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_64.txt | awk '{print $3}' >> p4_64.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_64.txt | awk '{print $3}' >> p4_64.txt




# 4 processes -threads 68
# 3 RUNS

count=1
#for (( ; count <= 3 ; )); do
while [ $count -le 3 ]
do
        echo "RUN $count -threads 68"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_68.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_681_threads.txt
        echo "PID1 = $pid1"

        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_68.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_682_threads.txt
        echo "PID2 = $pid2"

        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_68.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_683_threads.txt
        echo "PID3 = $pid3"

        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 68 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_68.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_684_threads.txt
        echo "PID4 = $pid4"

        # Search for the word "ERROR" in the logs
        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_6*
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            #((count++))
            count=$((count+1))
            #echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_6* >> strace_output_combined_finalloop_68_threads.txt
            rm strace_output_combined_innerloop_6*
        fi
        rm logs.txt
done

echo "tranfering all data to .txt file"
egrep '\[OVERALL\], RunTime\(ms\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[READ\], AverageLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_68.txt | awk '{print $3}' >> p1_68.txt

egrep '\[OVERALL\], RunTime\(ms\)' p2_68.txt | awk '{print $3}' >> p2_68.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_68.txt | awk '{print $3}' >> p2_68.txt
egrep '\[READ\], AverageLatency\(us\)' p2_68.txt | awk '{print $3}' >> p2_68.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p2_68.txt | awk '{print $3}' >> p2_68.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p2_68.txt | awk '{print $3}' >> p2_68.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p2_68.txt | awk '{print $3}' >> p2_68.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_68.txt | awk '{print $3}' >> p2_68.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_68.txt | awk '{print $3}' >> p2_68.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_68.txt | awk '{print $3}' >> p3_68.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_68.txt | awk '{print $3}' >> p3_68.txt
egrep '\[READ\], AverageLatency\(us\)' p3_68.txt | awk '{print $3}' >> p3_68.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p3_68.txt | awk '{print $3}' >> p3_68.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p3_68.txt | awk '{print $3}' >> p3_68.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p3_68.txt | awk '{print $3}' >> p3_68.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_68.txt | awk '{print $3}' >> p3_68.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_68.txt | awk '{print $3}' >> p3_68.txt

egrep '\[OVERALL\], RunTime\(ms\)' p4_68.txt | awk '{print $3}' >> p4_68.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_68.txt | awk '{print $3}' >> p4_68.txt
egrep '\[READ\], AverageLatency\(us\)' p4_68.txt | awk '{print $3}' >> p4_68.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p4_68.txt | awk '{print $3}' >> p4_68.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p4_68.txt | awk '{print $3}' >> p4_68.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p4_68.txt | awk '{print $3}' >> p4_68.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_68.txt | awk '{print $3}' >> p4_68.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_68.txt | awk '{print $3}' >> p4_68.txt




# # 4 processes -threads 72
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 72"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_72.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_72.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_72.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 72 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_72.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_72.txt | awk '{print $3}' >> p1_72.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_72.txt | awk '{print $3}' >> p2_72.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_72.txt | awk '{print $3}' >> p2_72.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_72.txt | awk '{print $3}' >> p2_72.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_72.txt | awk '{print $3}' >> p2_72.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_72.txt | awk '{print $3}' >> p2_72.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_72.txt | awk '{print $3}' >> p2_72.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_72.txt | awk '{print $3}' >> p2_72.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_72.txt | awk '{print $3}' >> p2_72.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_72.txt | awk '{print $3}' >> p3_72.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_72.txt | awk '{print $3}' >> p3_72.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_72.txt | awk '{print $3}' >> p3_72.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_72.txt | awk '{print $3}' >> p3_72.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_72.txt | awk '{print $3}' >> p3_72.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_72.txt | awk '{print $3}' >> p3_72.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_72.txt | awk '{print $3}' >> p3_72.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_72.txt | awk '{print $3}' >> p3_72.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_72.txt | awk '{print $3}' >> p4_72.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_72.txt | awk '{print $3}' >> p4_72.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_72.txt | awk '{print $3}' >> p4_72.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_72.txt | awk '{print $3}' >> p4_72.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_72.txt | awk '{print $3}' >> p4_72.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_72.txt | awk '{print $3}' >> p4_72.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_72.txt | awk '{print $3}' >> p4_72.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_72.txt | awk '{print $3}' >> p4_72.txt




# # 4 processes -threads 76
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 76"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_76.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_76.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_76.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 76 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_76.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_76.txt | awk '{print $3}' >> p1_76.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_76.txt | awk '{print $3}' >> p2_76.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_76.txt | awk '{print $3}' >> p2_76.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_76.txt | awk '{print $3}' >> p2_76.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_76.txt | awk '{print $3}' >> p2_76.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_76.txt | awk '{print $3}' >> p2_76.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_76.txt | awk '{print $3}' >> p2_76.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_76.txt | awk '{print $3}' >> p2_76.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_76.txt | awk '{print $3}' >> p2_76.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_76.txt | awk '{print $3}' >> p3_76.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_76.txt | awk '{print $3}' >> p3_76.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_76.txt | awk '{print $3}' >> p3_76.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_76.txt | awk '{print $3}' >> p3_76.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_76.txt | awk '{print $3}' >> p3_76.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_76.txt | awk '{print $3}' >> p3_76.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_76.txt | awk '{print $3}' >> p3_76.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_76.txt | awk '{print $3}' >> p3_76.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_76.txt | awk '{print $3}' >> p4_76.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_76.txt | awk '{print $3}' >> p4_76.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_76.txt | awk '{print $3}' >> p4_76.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_76.txt | awk '{print $3}' >> p4_76.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_76.txt | awk '{print $3}' >> p4_76.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_76.txt | awk '{print $3}' >> p4_76.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_76.txt | awk '{print $3}' >> p4_76.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_76.txt | awk '{print $3}' >> p4_76.txt





# # 4 processes -threads 80
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 80"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_80.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_80.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_80.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 80 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_80.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_80.txt | awk '{print $3}' >> p1_80.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_80.txt | awk '{print $3}' >> p2_80.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_80.txt | awk '{print $3}' >> p2_80.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_80.txt | awk '{print $3}' >> p2_80.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_80.txt | awk '{print $3}' >> p2_80.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_80.txt | awk '{print $3}' >> p2_80.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_80.txt | awk '{print $3}' >> p2_80.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_80.txt | awk '{print $3}' >> p2_80.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_80.txt | awk '{print $3}' >> p2_80.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_80.txt | awk '{print $3}' >> p3_80.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_80.txt | awk '{print $3}' >> p3_80.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_80.txt | awk '{print $3}' >> p3_80.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_80.txt | awk '{print $3}' >> p3_80.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_80.txt | awk '{print $3}' >> p3_80.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_80.txt | awk '{print $3}' >> p3_80.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_80.txt | awk '{print $3}' >> p3_80.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_80.txt | awk '{print $3}' >> p3_80.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_80.txt | awk '{print $3}' >> p4_80.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_80.txt | awk '{print $3}' >> p4_80.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_80.txt | awk '{print $3}' >> p4_80.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_80.txt | awk '{print $3}' >> p4_80.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_80.txt | awk '{print $3}' >> p4_80.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_80.txt | awk '{print $3}' >> p4_80.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_80.txt | awk '{print $3}' >> p4_80.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_80.txt | awk '{print $3}' >> p4_80.txt




# # 4 processes -threads 84
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 84"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_84.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_84.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_84.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 84 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_84.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_84.txt | awk '{print $3}' >> p1_84.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_84.txt | awk '{print $3}' >> p2_84.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_84.txt | awk '{print $3}' >> p2_84.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_84.txt | awk '{print $3}' >> p2_84.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_84.txt | awk '{print $3}' >> p2_84.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_84.txt | awk '{print $3}' >> p2_84.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_84.txt | awk '{print $3}' >> p2_84.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_84.txt | awk '{print $3}' >> p2_84.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_84.txt | awk '{print $3}' >> p2_84.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_84.txt | awk '{print $3}' >> p3_84.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_84.txt | awk '{print $3}' >> p3_84.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_84.txt | awk '{print $3}' >> p3_84.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_84.txt | awk '{print $3}' >> p3_84.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_84.txt | awk '{print $3}' >> p3_84.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_84.txt | awk '{print $3}' >> p3_84.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_84.txt | awk '{print $3}' >> p3_84.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_84.txt | awk '{print $3}' >> p3_84.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_84.txt | awk '{print $3}' >> p4_84.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_84.txt | awk '{print $3}' >> p4_84.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_84.txt | awk '{print $3}' >> p4_84.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_84.txt | awk '{print $3}' >> p4_84.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_84.txt | awk '{print $3}' >> p4_84.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_84.txt | awk '{print $3}' >> p4_84.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_84.txt | awk '{print $3}' >> p4_84.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_84.txt | awk '{print $3}' >> p4_84.txt




# # 4 processes -threads 88
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 88"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_88.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_88.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_88.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 88 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_88.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_88.txt | awk '{print $3}' >> p1_88.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_88.txt | awk '{print $3}' >> p2_88.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_88.txt | awk '{print $3}' >> p2_88.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_88.txt | awk '{print $3}' >> p2_88.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_88.txt | awk '{print $3}' >> p2_88.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_88.txt | awk '{print $3}' >> p2_88.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_88.txt | awk '{print $3}' >> p2_88.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_88.txt | awk '{print $3}' >> p2_88.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_88.txt | awk '{print $3}' >> p2_88.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_88.txt | awk '{print $3}' >> p3_88.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_88.txt | awk '{print $3}' >> p3_88.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_88.txt | awk '{print $3}' >> p3_88.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_88.txt | awk '{print $3}' >> p3_88.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_88.txt | awk '{print $3}' >> p3_88.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_88.txt | awk '{print $3}' >> p3_88.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_88.txt | awk '{print $3}' >> p3_88.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_88.txt | awk '{print $3}' >> p3_88.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_88.txt | awk '{print $3}' >> p4_88.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_88.txt | awk '{print $3}' >> p4_88.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_88.txt | awk '{print $3}' >> p4_88.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_88.txt | awk '{print $3}' >> p4_88.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_88.txt | awk '{print $3}' >> p4_88.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_88.txt | awk '{print $3}' >> p4_88.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_88.txt | awk '{print $3}' >> p4_88.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_88.txt | awk '{print $3}' >> p4_88.txt




# # 4 processes -threads 92
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 92"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_92.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_92.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_92.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 92 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_92.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_92.txt | awk '{print $3}' >> p1_92.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_92.txt | awk '{print $3}' >> p2_92.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_92.txt | awk '{print $3}' >> p2_92.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_92.txt | awk '{print $3}' >> p2_92.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_92.txt | awk '{print $3}' >> p2_92.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_92.txt | awk '{print $3}' >> p2_92.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_92.txt | awk '{print $3}' >> p2_92.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_92.txt | awk '{print $3}' >> p2_92.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_92.txt | awk '{print $3}' >> p2_92.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_92.txt | awk '{print $3}' >> p3_92.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_92.txt | awk '{print $3}' >> p3_92.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_92.txt | awk '{print $3}' >> p3_92.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_92.txt | awk '{print $3}' >> p3_92.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_92.txt | awk '{print $3}' >> p3_92.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_92.txt | awk '{print $3}' >> p3_92.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_92.txt | awk '{print $3}' >> p3_92.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_92.txt | awk '{print $3}' >> p3_92.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_92.txt | awk '{print $3}' >> p4_92.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_92.txt | awk '{print $3}' >> p4_92.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_92.txt | awk '{print $3}' >> p4_92.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_92.txt | awk '{print $3}' >> p4_92.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_92.txt | awk '{print $3}' >> p4_92.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_92.txt | awk '{print $3}' >> p4_92.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_92.txt | awk '{print $3}' >> p4_92.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_92.txt | awk '{print $3}' >> p4_92.txt




# # 4 processes -threads 96
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 96"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_96.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_96.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_96.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 96 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_96.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_96.txt | awk '{print $3}' >> p1_96.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_96.txt | awk '{print $3}' >> p2_96.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_96.txt | awk '{print $3}' >> p2_96.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_96.txt | awk '{print $3}' >> p2_96.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_96.txt | awk '{print $3}' >> p2_96.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_96.txt | awk '{print $3}' >> p2_96.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_96.txt | awk '{print $3}' >> p2_96.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_96.txt | awk '{print $3}' >> p2_96.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_96.txt | awk '{print $3}' >> p2_96.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_96.txt | awk '{print $3}' >> p3_96.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_96.txt | awk '{print $3}' >> p3_96.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_96.txt | awk '{print $3}' >> p3_96.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_96.txt | awk '{print $3}' >> p3_96.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_96.txt | awk '{print $3}' >> p3_96.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_96.txt | awk '{print $3}' >> p3_96.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_96.txt | awk '{print $3}' >> p3_96.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_96.txt | awk '{print $3}' >> p3_96.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_96.txt | awk '{print $3}' >> p4_96.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_96.txt | awk '{print $3}' >> p4_96.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_96.txt | awk '{print $3}' >> p4_96.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_96.txt | awk '{print $3}' >> p4_96.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_96.txt | awk '{print $3}' >> p4_96.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_96.txt | awk '{print $3}' >> p4_96.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_96.txt | awk '{print $3}' >> p4_96.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_96.txt | awk '{print $3}' >> p4_96.txt




# # 4 processes -threads 100
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 100"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_100.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_100.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_100.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 100 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_100.txt 2>> logs.txt &
#         pid4=$!
#         echo "PID4 = $pid4"

#         # Search for the word "ERROR" in the logs
#         sleep 100
#         if grep -q "ERROR" logs.txt; then
#             echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
#             pkill -P "$pid1"
#             pkill -P "$pid2"
#             pkill -P "$pid3"
#             pkill -P "$pid4"
#             echo "Killed $pid1 $pid2 $pid3 $pid4"
#             kill "$pid1" "$pid2" "$pid3" "$pid4"
#         else
#             echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
#             #((count++))
#             count=$((count+1))
#             #echo "count = $count"
#             wait "$pid1" "$pid2" "$pid3" "$pid4"
#         fi
#         rm logs.txt
# done

# echo "tranfering all data to .txt file"
# egrep '\[OVERALL\], RunTime\(ms\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
# egrep '\[READ\], AverageLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_100.txt | awk '{print $3}' >> p1_100.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p2_100.txt | awk '{print $3}' >> p2_100.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_100.txt | awk '{print $3}' >> p2_100.txt
# egrep '\[READ\], AverageLatency\(us\)' p2_100.txt | awk '{print $3}' >> p2_100.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p2_100.txt | awk '{print $3}' >> p2_100.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p2_100.txt | awk '{print $3}' >> p2_100.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p2_100.txt | awk '{print $3}' >> p2_100.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_100.txt | awk '{print $3}' >> p2_100.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_100.txt | awk '{print $3}' >> p2_100.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p3_100.txt | awk '{print $3}' >> p3_100.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_100.txt | awk '{print $3}' >> p3_100.txt
# egrep '\[READ\], AverageLatency\(us\)' p3_100.txt | awk '{print $3}' >> p3_100.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p3_100.txt | awk '{print $3}' >> p3_100.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p3_100.txt | awk '{print $3}' >> p3_100.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p3_100.txt | awk '{print $3}' >> p3_100.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_100.txt | awk '{print $3}' >> p3_100.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_100.txt | awk '{print $3}' >> p3_100.txt

# egrep '\[OVERALL\], RunTime\(ms\)' p4_100.txt | awk '{print $3}' >> p4_100.txt
# egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_100.txt | awk '{print $3}' >> p4_100.txt
# egrep '\[READ\], AverageLatency\(us\)' p4_100.txt | awk '{print $3}' >> p4_100.txt
# egrep '\[READ\], 95thPercentileLatency\(us\)' p4_100.txt | awk '{print $3}' >> p4_100.txt
# egrep '\[READ\], 99thPercentileLatency\(us\)' p4_100.txt | awk '{print $3}' >> p4_100.txt
# egrep '\[UPDATE\], AverageLatency\(us\)' p4_100.txt | awk '{print $3}' >> p4_100.txt
# egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_100.txt | awk '{print $3}' >> p4_100.txt
# egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_100.txt | awk '{print $3}' >> p4_100.txt





































