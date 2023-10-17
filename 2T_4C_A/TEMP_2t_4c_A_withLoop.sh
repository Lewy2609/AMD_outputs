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



# Run phase
# 4 process access 2 table

EOF

# 4 prallel processes -threads 2
# 3 RUNS
error=0
count=1
#for (( ; count <= 3 ; )); do
while [ $count -le 1 ]
do
        echo "RUN $count -threads 2"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_2.txt 2>> logs.txt &
        pid1=$!
	#strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_21_threads.txt
        echo "PID1 = $pid1"

        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_2.txt 2>> logs.txt &
        pid2=$!
	#strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_22_threads.txt
        echo "PID2 = $pid2"

        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable1 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_2.txt 2>> logs.txt &
        pid3=$!
	#strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_23_threads.txt
        echo "PID3 = $pid3"

        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000 -p table=usertable2 -threads 2 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_2.txt 2>> logs.txt &
        pid4=$!
	#strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_24_threads.txt
        echo "PID4 = $pid4"

	strace -c -f -S name -p $pid1 -p $pid2 -p $pid3 -p $pid4 -o >(cat >> strace_output_combined_innerloop_2_threads.txt)

        # Search for the word "ERROR" in the logs
        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            
	    error=$((error+1))
	    
	    pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            
	    #strace -c -f -S name -p $pid1 -p $pid2 -p $pid3 -p $pid4 -o >(cat >> strace_output_combined_loop_2_threads.txt)
	    echo "$error" >> errors.txt
	    error=0

            #((count++))
            count=$((count+1))
            #echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
        fi
        rm logs.txt
done

echo "tranfering all data to .txt file"
egrep '\[OVERALL\], RunTime\(ms\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[READ\], AverageLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p1_2.txt | awk '{print $3}' >> p1_2.txt

egrep '\[OVERALL\], RunTime\(ms\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
egrep '\[READ\], AverageLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[READ\], AverageLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p2_2.txt | awk '{print $3}' >> p2_2.txt

egrep '\[OVERALL\], RunTime\(ms\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[READ\], AverageLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p3_2.txt | awk '{print $3}' >> p3_2.txt

egrep '\[OVERALL\], RunTime\(ms\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
egrep '\[OVERALL\], Throughput\(ops/sec\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
egrep '\[READ\], AverageLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
egrep '\[READ\], 95thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
egrep '\[READ\], 99thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
egrep '\[UPDATE\], AverageLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
egrep '\[UPDATE\], 95thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt
egrep '\[UPDATE\], 99thPercentileLatency\(us\)' p4_2.txt | awk '{print $3}' >> p4_2.txt


# 4 prallel processes -threads 4
# 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 4"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_4.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable2 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_4.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable1 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_4.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable2 -threads 4 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_4.txt 2>> logs.txt &
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




# # 4 prallel processes -threads 32
# # 3 RUNS

# count=1
# #for (( ; count <= 3 ; )); do
# while [ $count -le 3 ]
# do
#         echo "RUN $count -threads 32"

#         numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_32.txt 2>> logs.txt &
#         pid1=$!
#         echo "PID1 = $pid1"

#         numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable2 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_32.txt 2>> logs.txt &
#         pid2=$!
#         echo "PID2 = $pid2"

#         numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable1 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_32.txt 2>> logs.txt &
#         pid3=$!
#         echo "PID3 = $pid3"

#         numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=100 -p table=usertable2 -threads 32 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_32.txt 2>> logs.txt &
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
