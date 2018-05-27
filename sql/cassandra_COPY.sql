CREATE TABLE history.hitbtc (
	id uuid,
	load_date text,
	tstamp timestamp,
	transaction_date text,
	exchange text,
	symbol text,
	price float,
	amount float,
	type text,
	side text,
	PRIMARY KEY (id)
) WITH bloom_filter_fp_chance = 0.01
AND comment = ''
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
	'class' : 'SizeTieredCompactionStrategy',
	'max_threshold' : 32,
	'min_threshold' : 4
};


COPY history.hitbtc(load_date,tstamp,transaction_date,exchange,symbol,price,amount,type,side,id) FROM 'out.csv' WITH DELIMITER=',' AND HEADER=FALSE AND DATETIMEFORMAT='%Y-%m-%d %H:%M:%S.%f%z';
