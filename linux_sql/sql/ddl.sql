-- ddl.sql

-- Step 1: Switch to host_agent database 
-- Ensure we're connected to the correct database
\c host_agent;

-- Step 2: Create host_info table if not exists
-- This table stores hardware specifications for each host
CREATE TABLE IF NOT EXISTS PUBLIC.host_info 
(
    id               SERIAL NOT NULL,
    hostname         VARCHAR NOT NULL,
    cpu_number       INT2 NOT NULL,
    cpu_architecture VARCHAR NOT NULL,
    cpu_model        VARCHAR NOT NULL,
    cpu_mhz          FLOAT8 NOT NULL,
    l2_cache         INT4 NOT NULL,
    "timestamp"      TIMESTAMP NOT NULL,
    total_mem        INT4 NOT NULL,
    CONSTRAINT host_info_pk PRIMARY KEY (id),
    CONSTRAINT host_info_un UNIQUE (hostname)
);

-- Step 3: Create host_usage table if not exists
-- This table stores resource usage data with a foreign key reference to host_info
CREATE TABLE IF NOT EXISTS PUBLIC.host_usage 
(
    "timestamp"    TIMESTAMP NOT NULL,
    host_id        SERIAL NOT NULL,
    memory_free    INT4 NOT NULL,
    cpu_idle       INT2 NOT NULL,
    cpu_kernel     INT2 NOT NULL,
    disk_io        INT4 NOT NULL,
    disk_available INT4 NOT NULL,
    CONSTRAINT host_usage_host_info_fk FOREIGN KEY (host_id) 
        REFERENCES host_info(id)
);
