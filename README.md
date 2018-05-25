# Arbitron

TODO:

Loader:

+ Протестировать заливку с OKEX и HitBTC (особенно HitBTC.BTC-USDT)
+ FixNullBytes запускать только при необходимости 
+ Конвертировать всё в UTC
+ Доделать загрузку OrderBook в CSV
. Отрезать лишние пары, по которым меньше 1 сделки в минуту
. Загрузка в HDF5
. Spark/Kafka ?