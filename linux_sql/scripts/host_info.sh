#!/bin/bash

# Script to collect hardware specification data and insert into PostgreSQL
# Usage: ./host_info.sh psql_host psql_port db_name psql_user psql_password

# Assign CLI arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check number of arguments
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

# Hardware Specifications
hostname=$(hostname -f)
lscpu_out=$(lscpu)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk '{$1=$2=""; print $0}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | egrep "^Model name:" | grep -oP '\d+\.\d+(?=GHz)' | awk '{print $1 * 1000}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | sed 's/K//g' | xargs)
total_mem=$(cat /proc/meminfo | egrep "^MemTotal:" | awk '{print $2}' | xargs)
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# Construct INSERT statement
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp) 
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp');"

# Set PGPASSWORD environment variable
export PGPASSWORD=$psql_password

# Execute INSERT statement through psql CLI
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?
