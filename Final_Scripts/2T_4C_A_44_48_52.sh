#!/usr/local/bin/bash

# WORKLOAD A...... 2t_4c

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


output_buffercache_2t_4c(){

    while true; do
        local id=$1
        local buffer_value=$(awk '/Buffers/ {print $2}' /proc/meminfo)
        local cache_value=$(awk '/^Cached:/ {print $2}' /proc/meminfo)
        echo "$id,$buffer_value,$cache_value" >> mpstat_2t_4c_out.csv
        sleep 3
    done
}

rm mpstat_2t_4c_44_output.txt
mpstat -N 0 2 | tee mpstat_2t_4c_44_output.txt &           #CHECK    # Node 0 and 1 details →  avg %iowait, avg %idle time
mpstat_pid=$!
echo "mpstatpid=$mpstat_pid"

id=44
(output_buffercache_2t_4c $id) &
subshell_pid=$!

<<comment 
strace is attached to each of the commands:
paramaeters definition:
[-c] To generate a summary report of system calls that are traced by strace.
[-f] Trace child processes as they are created by currently traced processes.
[-S 'filter'] Is to sort by a specific criteria, here it is by the 'name' of the system calls.
[-p pid] Attach strace to the process with the process ID pid and begin tracing.
[-o] Write the trace output(here, the summary report) to the file filename rather than to stderr.
comment

count=1
while [ $count -le 2 ]
do
       echo "RUN $count -threads 44"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_44.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_441_threads.txt
        echo "PID1 = $pid1"


        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable2 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_44.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_442_threads.txt
        echo "PID2 = $pid2"


        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_44.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_443_threads.txt
        echo "PID3 = $pid3"


        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable2 -threads 44 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_44.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_444_threads.txt
        echo "PID4 = $pid4"

        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_4* # remove all temporary files storing output of an error logged strace (could be omitted)
            kill $mpstat_pid
            rm mpstat_2t_4c_44_output.txt
            rm mpstat_2t_4c_out.csv
            mpstat -N 0 2 | tee mpstat_2t_4c_44_output.txt &
            mpstat_pid=$!
            echo "mpstatpid=$mpstat_pid"
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            ((count++))
            echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_4* >> strace_output_combined_2T_4C_44_threads.txt # store strace output of error free logs to a final output file
	        rm strace_output_combined_innerloop_4* # remove all temporary files once the loop for that run is executed
            cat mpstat_2t_4c_44_output.txt >> mpstat_2t_4c_44_output_final.txt
            cat mpstat_2t_4c_out.csv >> mpstat_2t_4c_out_final.csv
            rm mpstat_2t_4c_44_output.txt
            rm mpstat_2t_4c_out.csv

       fi
       rm logs.txt
done
kill $mpstat_pid

kill "$subshell_pid"

sed -i -e 1,2d mpstat_2t_4c_44_output_final.txt               # to remove top 2 unnecessary lines
sed -i '/^$/d' mpstat_2t_4c_44_output_final.txt               # to remove all empty lines
sed -i '1d; n; d' mpstat_2t_4c_44_output_final.txt            # to remove all header lines / odd lines
iowait_Total=$(awk '{sum+=$7} END{print sum}' mpstat_2t_4c_44_output_final.txt)
iowait_Average=$(awk '{sum+=$7} END{print sum/NR}' mpstat_2t_4c_44_output_final.txt)

echo "$id,$iowait_Total,$iowait_Average" >> mpstat_ioavg_output.txt

#48 Start
rm mpstat_2t_4c_48_output.txt
mpstat -N 0 2 | tee mpstat_2t_4c_48_output.txt &           #CHECK    # Node 0 and 1 details →  avg %iowait, avg %idle time
mpstat_pid=$!
echo "mpstatpid=$mpstat_pid"

id=48
(output_buffercache_2t_4c $id) &
subshell_pid=$!

count=1
while [ $count -le 2 ]
do
       echo "RUN $count -threads 48"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_48.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_481_threads.txt
        echo "PID1 = $pid1"


        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable2 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_48.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_482_threads.txt
        echo "PID2 = $pid2"


        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_48.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_483_threads.txt
        echo "PID3 = $pid3"


        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable2 -threads 48 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_48.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_484_threads.txt
        echo "PID4 = $pid4"

        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_4* # remove all temporary files storing output of an error logged strace (could be omitted)
            kill $mpstat_pid
            rm mpstat_2t_4c_48_output.txt
            rm mpstat_2t_4c_out.csv
            mpstat -N 0 2 | tee mpstat_2t_4c_48_output.txt &
            mpstat_pid=$!
            echo "mpstatpid=$mpstat_pid"
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            ((count++))
            echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_4* >> strace_output_combined_2T_4C_48_threads.txt # store strace output of error free logs to a final output file
	        rm strace_output_combined_innerloop_4* # remove all temporary files once the loop for that run is executed
            cat mpstat_2t_4c_48_output.txt >> mpstat_2t_4c_48_output_final.txt
            cat mpstat_2t_4c_out.csv >> mpstat_2t_4c_out_final.csv
            rm mpstat_2t_4c_48_output.txt
            rm mpstat_2t_4c_out.csv

       fi
       rm logs.txt
done
kill $mpstat_pid

kill "$subshell_pid"

sed -i -e 1,2d mpstat_2t_4c_48_output_final.txt               # to remove top 2 unnecessary lines
sed -i '/^$/d' mpstat_2t_4c_48_output_final.txt               # to remove all empty lines
sed -i '1d; n; d' mpstat_2t_4c_48_output_final.txt            # to remove all header lines / odd lines
iowait_Total=$(awk '{sum+=$7} END{print sum}' mpstat_2t_4c_48_output_final.txt)
iowait_Average=$(awk '{sum+=$7} END{print sum/NR}' mpstat_2t_4c_48_output_final.txt)

echo "$id,$iowait_Total,$iowait_Average" >> mpstat_ioavg_output.txt

#52 Start
rm mpstat_2t_4c_52_output.txt
mpstat -N 0 2 | tee mpstat_2t_4c_52_output.txt &           #CHECK    # Node 0 and 1 details →  avg %iowait, avg %idle time
mpstat_pid=$!
echo "mpstatpid=$mpstat_pid"

id=48
(output_buffercache_2t_4c $id) &
subshell_pid=$!

count=1
while [ $count -le 2 ]
do
       echo "RUN $count -threads 52"

        numactl --physcpubind=4,5,6,7,8,9 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p1_52.txt 2>> logs.txt &
        pid1=$!
        strace -c -f -S name -p $pid1 -o strace_output_combined_innerloop_521_threads.txt
        echo "PID1 = $pid1"


        numactl --physcpubind=10,11,12,13,14,15 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable2 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p2_52.txt 2>> logs.txt &
        pid2=$!
        strace -c -f -S name -p $pid2 -o strace_output_combined_innerloop_522_threads.txt
        echo "PID2 = $pid2"


        numactl --physcpubind=20,21,22,23,24,25 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable1 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p3_52.txt 2>> logs.txt &
        pid3=$!
        strace -c -f -S name -p $pid3 -o strace_output_combined_innerloop_523_threads.txt
        echo "PID3 = $pid3"


        numactl --physcpubind=26,27,28,29,30,31 ./bin/ycsb run mongodb -s -P workloads/workloada -p recordcount=10000000 -p operationcount=1000000 -p table=usertable2 -threads 52 -p requestdistribution=zipfian -p mongodb.url=mongodb://localhost:27017/ycsb?w=0 >> p4_52.txt 2>> logs.txt &
        pid4=$!
        strace -c -f -S name -p $pid4 -o strace_output_combined_innerloop_524_threads.txt
        echo "PID4 = $pid4"

        sleep 100
        if grep -q "ERROR" logs.txt; then
            echo "Found ERROR in the logs! KILLING the program...... $pid1 $pid2 $pid3 $pid4"
            pkill -P "$pid1"
            pkill -P "$pid2"
            pkill -P "$pid3"
            pkill -P "$pid4"
            echo "Killed $pid1 $pid2 $pid3 $pid4"
            kill "$pid1" "$pid2" "$pid3" "$pid4"
            rm strace_output_combined_innerloop_5* # remove all temporary files storing output of an error logged strace (could be omitted)
            kill $mpstat_pid
            rm mpstat_2t_4c_52_output.txt
            rm mpstat_2t_4c_out.csv
            mpstat -N 0 2 | tee mpstat_2t_4c_52_output.txt &
            mpstat_pid=$!
            echo "mpstatpid=$mpstat_pid"
        else
            echo "Error NOT found in the logs... RUNNING $pid1 $pid2 $pid3 $pid4"
            ((count++))
            echo "count = $count"
            wait "$pid1" "$pid2" "$pid3" "$pid4"
            cat strace_output_combined_innerloop_5* >> strace_output_combined_2T_4C_52_threads.txt # store strace output of error free logs to a final output file
            rm strace_output_combined_innerloop_5* # remove all temporary files once the loop for that run is executed
            cat mpstat_2t_4c_52_output.txt >> mpstat_2t_4c_52_output_final.txt
            cat mpstat_2t_4c_out.csv >> mpstat_2t_4c_out_final.csv
            rm mpstat_2t_4c_52_output.txt
            rm mpstat_2t_4c_out.csv

       fi
       rm logs.txt
done
kill $mpstat_pid

kill "$subshell_pid"

sed -i -e 1,2d mpstat_2t_4c_52_output_final.txt               # to remove top 2 unnecessary lines
sed -i '/^$/d' mpstat_2t_4c_52_output_final.txt               # to remove all empty lines
sed -i '1d; n; d' mpstat_2t_4c_52_output_final.txt            # to remove all header lines / odd lines
iowait_Total=$(awk '{sum+=$7} END{print sum}' mpstat_2t_4c_52_output_final.txt)
iowait_Average=$(awk '{sum+=$7} END{print sum/NR}' mpstat_2t_4c_52_output_final.txt)

echo "$id,$iowait_Total,$iowait_Average" >> mpstat_ioavg_output.txt

#################################################################################################################

python strace_output_to_csv_loop.py