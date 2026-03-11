-- Average memory usage per host in the last 60 minutes
SELECT h.hostname,
       AVG(hu.memory_free) AS avg_memory_free
FROM host_usage hu
JOIN host_info h ON hu.host_id = h.id
WHERE hu.timestamp >= NOW() - INTERVAL '1 hour'
GROUP BY h.hostname
ORDER BY avg_memory_free ASC;