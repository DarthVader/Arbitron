CREATE KEYSPACE temp 
WITH durable_writes = true
AND replication = {
    'class' : 'NetworkTopologyStrategy',
    'datacenter1' : 2,
    'datacenter2' : 1
};

--
CREATE TABLE temp.history (
	exchange text,
	symbol text,
	tdate timestamp,
	id text,
	amount double,
	price double,
	side text,
	PRIMARY KEY (( exchange, symbol ), tdate, id)
) WITH CLUSTERING ORDER BY ( tdate DESC, id ASC )
AND bloom_filter_fp_chance = 0.01
AND comment = 'test history table'
AND crc_check_chance = 1.0
AND dclocal_read_repair_chance = 0.1
AND default_time_to_live = 0
AND gc_grace_seconds = 864000
AND max_index_interval = 2048
AND memtable_flush_period_in_ms = 0
AND min_index_interval = 128
AND read_repair_chance = 0.0
AND speculative_retry = '99.0PERCENTILE'
AND caching = {
	'keys' : 'ALL',
	'rows_per_partition' : 'NONE'
}
AND compression = {
	'chunk_length_in_kb' : 64,
	'class' : 'LZ4Compressor',
	'enabled' : true
}
AND compaction = {
	'class' : 'DateTieredCompactionStrategy',
	'enabled' : true,
	'max_threshold' : 32,
	'min_threshold' : 4,
	'tombstone_compaction_interval' : 86400,
	'tombstone_threshold' : 0.2,
	'unchecked_tombstone_compaction' : false
};

INSERT INTO temp.history("exchange", "symbol", "tdate", "id", "amount", "price", "side") 
	VALUES('Cryptopia', 'BTC/USDT', '2018-06-17 09:28:42', '', 0.001305, 6541.83018, 'sell')
