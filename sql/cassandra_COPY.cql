COPY history.hitbtc(load_date,tstamp,transaction_date,exchange,symbol,price,amount,type,side,id) FROM 'out.csv' WITH DELIMITER=',' AND HEADER=FALSE AND DATETIMEFORMAT='%Y-%m-%d %H:%M:%S.%f%z';
COPY arbitron.exchanges_pairs(exchange,pair,enabled,fsym,fsym_withdraw_fee,tsym,tsym_withdraw_fee,volume24h) FROM 'exchanges_pairs.csv' WITH DELIMITER=',' AND HEADER=TRUE;

CREATE TABLE IF NOT EXISTS arbitron.exchanges (
    id text,
    api_url text,
    api_version text,
    countries set<text>,
    enabled boolean,
    has_history_id boolean,
    name text,
    ratelimit int,
    ratelimitmaxtokens int,
    PRIMARY KEY (id)
);
COPY arbitron.exchanges(id, api_url, api_version, countries, enabled, has_history_id, name, ratelimit, ratelimitmaxtokens) FROM 'exchanges.csv' WITH DELIMITER=',' AND HEADER=TRUE;

CREATE TABLE IF NOT EXISTS arbitron.tokens (
    symbol text,
    allowed_conversions set<text>,
    alt text,
    enabled boolean,
    fiat boolean,
    high_volume boolean,
    low_fee boolean,
    PRIMARY KEY (symbol)
);
COPY arbitron.tokens(symbol, allowed_conversions, alt, enabled, fiat, high_volume, low_fee) FROM 'tokens.csv' WITH DELIMITER=',' AND HEADER=TRUE;

select toTimestamp(id), ip, job, pacemaker, worker from arbitron.log limit 10;

SELECT * FROM arbitron.history WHERE exchange='binance' and pair='ETH/USDT' LIMIT 1000;

