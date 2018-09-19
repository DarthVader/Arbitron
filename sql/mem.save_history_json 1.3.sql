USE [Arbitron]
GO
/****** Object:  StoredProcedure [mem].[save_history_json]    Script Date: 18.09.2018 00:11:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- mem.save_history_json 1.3
/*
-- exec mem.save_history_json '{"exchange": "binance", "pair": "ETH/USDT", "histories": [{"timestamp": 1534552123538, "datetime": "2018-08-18T00:28:43.538Z", "symbol": "ETH/USDT", "id": "31861087", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 316.71, "cost": 250.7868135, "amount": 0.79185, "fee": null}, {"timestamp": 1534552123794, "datetime": "2018-08-18T00:28:43.794Z", "symbol": "ETH/USDT", "id": "31861088", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 316.71, "cost": 1174.4050194, "amount": 3.70814, "fee": null}]}'

*/
-- 1.3 save to new optimized structure
DROP PROCEDURE IF EXISTS [mem].[save_history_json]
GO

CREATE OR ALTER procedure [mem].[save_history_json](@json as nvarchar(max))
--with native_compilation, schemabinding   
as 
begin 
	-- atomic with (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')  
	
	-- INSERT to dbo.history using in-memory table type dbo.histories_type
	-- see https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/faster-temp-table-and-table-variable-by-using-memory-optimization?view=sql-server-2017

	-- print 'Insert to target table mem.history'
	INSERT INTO mem.history (insert_date, dt, id_ex_pair, price, amount, id_type, is_buy, [id])

	-- declare @json as nvarchar(max) = '{"exchange": "binance", "pair": "ETH/USDT", "histories": [{"timestamp": 1537295872765, "datetime": "2018-09-18T18:37:52.765Z", "symbol": "ETH/USDT", "id": "36258296", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.1, "cost": 210.1, "amount": 1.0, "fee": null}, {"timestamp": 1537295873224, "datetime": "2018-09-18T18:37:53.224Z", "symbol": "ETH/USDT", "id": "36258297", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.07, "cost": 61.35094349999999, "amount": 0.29205, "fee": null}, {"timestamp": 1537295875015, "datetime": "2018-09-18T18:37:55.015Z", "symbol": "ETH/USDT", "id": "36258298", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.07, "cost": 210.07, "amount": 1.0, "fee": null}, {"timestamp": 1537295876270, "datetime": "2018-09-18T18:37:56.270Z", "symbol": "ETH/USDT", "id": "36258299", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.2, "cost": 699.9996319999999, "amount": 3.33016, "fee": null}, {"timestamp": 1537295876274, "datetime": "2018-09-18T18:37:56.274Z", "symbol": "ETH/USDT", "id": "36258300", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.27, "cost": 279.6591, "amount": 1.33, "fee": null}, {"timestamp": 1537295876274, "datetime": "2018-09-18T18:37:56.274Z", "symbol": "ETH/USDT", "id": "36258301", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.39, "cost": 2244.8613, "amount": 10.67, "fee": null}, {"timestamp": 1537295876294, "datetime": "2018-09-18T18:37:56.294Z", "symbol": "ETH/USDT", "id": "36258302", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.39, "cost": 1962.9387, "amount": 9.33, "fee": null}, {"timestamp": 1537295876475, "datetime": "2018-09-18T18:37:56.475Z", "symbol": "ETH/USDT", "id": "36258303", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.1, "cost": 69.78471499999999, "amount": 0.33215, "fee": null}, {"timestamp": 1537295876509, "datetime": "2018-09-18T18:37:56.509Z", "symbol": "ETH/USDT", "id": "36258304", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.38, "cost": 912.3612574, "amount": 4.33673, "fee": null}, {"timestamp": 1537295877315, "datetime": "2018-09-18T18:37:57.315Z", "symbol": "ETH/USDT", "id": "36258305", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.1, "cost": 84.04, "amount": 0.4, "fee": null}, {"timestamp": 1537295877935, "datetime": "2018-09-18T18:37:57.935Z", "symbol": "ETH/USDT", "id": "36258306", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.1, "cost": 39.919, "amount": 0.19, "fee": null}, {"timestamp": 1537295878636, "datetime": "2018-09-18T18:37:58.636Z", "symbol": "ETH/USDT", "id": "36258307", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.38, "cost": 4838.74, "amount": 23.0, "fee": null}, {"timestamp": 1537295878652, "datetime": "2018-09-18T18:37:58.652Z", "symbol": "ETH/USDT", "id": "36258308", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.38, "cost": 1114.624797, "amount": 5.29815, "fee": null}, {"timestamp": 1537295878673, "datetime": "2018-09-18T18:37:58.673Z", "symbol": "ETH/USDT", "id": "36258309", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.4, "cost": 4208.0, "amount": 20.0, "fee": null}, {"timestamp": 1537295878683, "datetime": "2018-09-18T18:37:58.683Z", "symbol": "ETH/USDT", "id": "36258310", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.37, "cost": 124.11829999999999, "amount": 0.59, "fee": null}, {"timestamp": 1537295879392, "datetime": "2018-09-18T18:37:59.392Z", "symbol": "ETH/USDT", "id": "36258311", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.1, "cost": 165.964293, "amount": 0.78993, "fee": null}, {"timestamp": 1537295879508, "datetime": "2018-09-18T18:37:59.508Z", "symbol": "ETH/USDT", "id": "36258312", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.36, "cost": 166.16967480000002, "amount": 0.78993, "fee": null}, {"timestamp": 1537295879508, "datetime": "2018-09-18T18:37:59.508Z", "symbol": "ETH/USDT", "id": "36258313", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.37, "cost": 4207.4, "amount": 20.0, "fee": null}, {"timestamp": 1537295879892, "datetime": "2018-09-18T18:37:59.892Z", "symbol": "ETH/USDT", "id": "36258314", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.38, "cost": 336.608, "amount": 1.6, "fee": null}, {"timestamp": 1537295879919, "datetime": "2018-09-18T18:37:59.919Z", "symbol": "ETH/USDT", "id": "36258315", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.38, "cost": 20.4531436, "amount": 0.09722, "fee": null}, {"timestamp": 1537295879934, "datetime": "2018-09-18T18:37:59.934Z", "symbol": "ETH/USDT", "id": "36258316", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.38, "cost": 707.29756, "amount": 3.362, "fee": null}, {"timestamp": 1537295880425, "datetime": "2018-09-18T18:38:00.425Z", "symbol": "ETH/USDT", "id": "36258317", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.39, "cost": 4126.5158235, "amount": 19.61365, "fee": null}, {"timestamp": 1537295880425, "datetime": "2018-09-18T18:38:00.425Z", "symbol": "ETH/USDT", "id": "36258318", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.4, "cost": 712.4880400000001, "amount": 3.38635, "fee": null}, {"timestamp": 1537295881860, "datetime": "2018-09-18T18:38:01.860Z", "symbol": "ETH/USDT", "id": "36258319", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.1, "cost": 219.3444, "amount": 1.044, "fee": null}, {"timestamp": 1537295881922, "datetime": "2018-09-18T18:38:01.922Z", "symbol": "ETH/USDT", "id": "36258320", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.1, "cost": 6443.193426999999, "amount": 30.66727, "fee": null}, {"timestamp": 1537295881986, "datetime": "2018-09-18T18:38:01.986Z", "symbol": "ETH/USDT", "id": "36258321", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.06, "cost": 4303.0286856, "amount": 20.48476, "fee": null}, {"timestamp": 1537295881986, "datetime": "2018-09-18T18:38:01.986Z", "symbol": "ETH/USDT", "id": "36258322", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.33, "cost": 219.58452000000003, "amount": 1.044, "fee": null}, {"timestamp": 1537295881986, "datetime": "2018-09-18T18:38:01.986Z", "symbol": "ETH/USDT", "id": "36258323", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.34, "cost": 210.34, "amount": 1.0, "fee": null}, {"timestamp": 1537295881986, "datetime": "2018-09-18T18:38:01.986Z", "symbol": "ETH/USDT", "id": "36258324", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.38, "cost": 253.04506400000002, "amount": 1.2028, "fee": null}, {"timestamp": 1537295881986, "datetime": "2018-09-18T18:38:01.986Z", "symbol": "ETH/USDT", "id": "36258325", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.4, "cost": 2160.479776, "amount": 10.26844, "fee": null}, {"timestamp": 1537295883227, "datetime": "2018-09-18T18:38:03.227Z", "symbol": "ETH/USDT", "id": "36258326", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.05, "cost": 39.9095, "amount": 0.19, "fee": null}, {"timestamp": 1537295883348, "datetime": "2018-09-18T18:38:03.348Z", "symbol": "ETH/USDT", "id": "36258327", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.1, "cost": 105.05, "amount": 0.5, "fee": null}, {"timestamp": 1537295883348, "datetime": "2018-09-18T18:38:03.348Z", "symbol": "ETH/USDT", "id": "36258328", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.39, "cost": 4733.775, "amount": 22.5, "fee": null}, {"timestamp": 1537295885017, "datetime": "2018-09-18T18:38:05.017Z", "symbol": "ETH/USDT", "id": "36258329", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.38, "cost": 5414.160857, "amount": 25.73515, "fee": null}, {"timestamp": 1537295885113, "datetime": "2018-09-18T18:38:05.113Z", "symbol": "ETH/USDT", "id": "36258330", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.4, "cost": 1335.032184, "amount": 6.34521, "fee": null}, {"timestamp": 1537295885113, "datetime": "2018-09-18T18:38:05.113Z", "symbol": "ETH/USDT", "id": "36258331", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.41, "cost": 210.41, "amount": 1.0, "fee": null}, {"timestamp": 1537295885113, "datetime": "2018-09-18T18:38:05.113Z", "symbol": "ETH/USDT", "id": "36258332", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.42, "cost": 21.382880399999998, "amount": 0.10162, "fee": null}, {"timestamp": 1537295885113, "datetime": "2018-09-18T18:38:05.113Z", "symbol": "ETH/USDT", "id": "36258333", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.43, "cost": 14.5470259, "amount": 0.06913, "fee": null}, {"timestamp": 1537295885113, "datetime": "2018-09-18T18:38:05.113Z", "symbol": "ETH/USDT", "id": "36258334", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.48, "cost": 845.5634088, "amount": 4.01731, "fee": null}, {"timestamp": 1537295885113, "datetime": "2018-09-18T18:38:05.113Z", "symbol": "ETH/USDT", "id": "36258335", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.49, "cost": 4729.0219977, "amount": 22.46673, "fee": null}, {"timestamp": 1537295885384, "datetime": "2018-09-18T18:38:05.384Z", "symbol": "ETH/USDT", "id": "36258336", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.07, "cost": 1.1112703000000002, "amount": 0.00529, "fee": null}, {"timestamp": 1537295886248, "datetime": "2018-09-18T18:38:06.248Z", "symbol": "ETH/USDT", "id": "36258337", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.4, "cost": 10.101303999999999, "amount": 0.04801, "fee": null}, {"timestamp": 1537295886935, "datetime": "2018-09-18T18:38:06.935Z", "symbol": "ETH/USDT", "id": "36258338", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.13, "cost": 105.065, "amount": 0.5, "fee": null}, {"timestamp": 1537295887495, "datetime": "2018-09-18T18:38:07.495Z", "symbol": "ETH/USDT", "id": "36258339", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.45, "cost": 106.3382805, "amount": 0.50529, "fee": null}, {"timestamp": 1537295887495, "datetime": "2018-09-18T18:38:07.495Z", "symbol": "ETH/USDT", "id": "36258340", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.46, "cost": 4734.236666600001, "amount": 22.49471, "fee": null}, {"timestamp": 1537295890085, "datetime": "2018-09-18T18:38:10.085Z", "symbol": "ETH/USDT", "id": "36258341", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.42, "cost": 210.42, "amount": 1.0, "fee": null}, {"timestamp": 1537295890085, "datetime": "2018-09-18T18:38:10.085Z", "symbol": "ETH/USDT", "id": "36258342", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.46, "cost": 316.80333340000004, "amount": 1.50529, "fee": null}, {"timestamp": 1537295890085, "datetime": "2018-09-18T18:38:10.085Z", "symbol": "ETH/USDT", "id": "36258343", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.48, "cost": 4209.599999999999, "amount": 20.0, "fee": null}, {"timestamp": 1537295890085, "datetime": "2018-09-18T18:38:10.085Z", "symbol": "ETH/USDT", "id": "36258344", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.49, "cost": 2419.5215079, "amount": 11.49471, "fee": null}, {"timestamp": 1537295891211, "datetime": "2018-09-18T18:38:11.211Z", "symbol": "ETH/USDT", "id": "36258345", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.13, "cost": 105.065, "amount": 0.5, "fee": null}, {"timestamp": 1537295891349, "datetime": "2018-09-18T18:38:11.349Z", "symbol": "ETH/USDT", "id": "36258346", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.13, "cost": 1.1956396999999999, "amount": 0.00569, "fee": null}, {"timestamp": 1537295891659, "datetime": "2018-09-18T18:38:11.659Z", "symbol": "ETH/USDT", "id": "36258347", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.44, "cost": 105.22, "amount": 0.5, "fee": null}, {"timestamp": 1537295891659, "datetime": "2018-09-18T18:38:11.659Z", "symbol": "ETH/USDT", "id": "36258348", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.45, "cost": 4209.0, "amount": 20.0, "fee": null}, {"timestamp": 1537295891659, "datetime": "2018-09-18T18:38:11.659Z", "symbol": "ETH/USDT", "id": "36258349", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.49, "cost": 2841.6150000000002, "amount": 13.5, "fee": null}, {"timestamp": 1537295893266, "datetime": "2018-09-18T18:38:13.266Z", "symbol": "ETH/USDT", "id": "36258350", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.44, "cost": 210.44, "amount": 1.0, "fee": null}, {"timestamp": 1537295893266, "datetime": "2018-09-18T18:38:13.266Z", "symbol": "ETH/USDT", "id": "36258351", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.49, "cost": 3827.3291455000003, "amount": 18.18295, "fee": null}, {"timestamp": 1537295893266, "datetime": "2018-09-18T18:38:13.266Z", "symbol": "ETH/USDT", "id": "36258352", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.5, "cost": 803.489025, "amount": 3.81705, "fee": null}, {"timestamp": 1537295893266, "datetime": "2018-09-18T18:38:13.266Z", "symbol": "ETH/USDT", "id": "36258353", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.5, "cost": 6901.18356, "amount": 32.78472, "fee": null}, {"timestamp": 1537295893266, "datetime": "2018-09-18T18:38:13.266Z", "symbol": "ETH/USDT", "id": "36258354", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.54, "cost": 210.54, "amount": 1.0, "fee": null}, {"timestamp": 1537295893288, "datetime": "2018-09-18T18:38:13.288Z", "symbol": "ETH/USDT", "id": "36258355", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.55, "cost": 1763.5668, "amount": 8.376, "fee": null}, {"timestamp": 1537295893294, "datetime": "2018-09-18T18:38:13.294Z", "symbol": "ETH/USDT", "id": "36258356", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.55, "cost": 213.80510300000003, "amount": 1.01546, "fee": null}, {"timestamp": 1537295893319, "datetime": "2018-09-18T18:38:13.319Z", "symbol": "ETH/USDT", "id": "36258357", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.13, "cost": 1973.4274898, "amount": 9.39146, "fee": null}, {"timestamp": 1537295894469, "datetime": "2018-09-18T18:38:14.469Z", "symbol": "ETH/USDT", "id": "36258358", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.33, "cost": 229.35224520000003, "amount": 1.09044, "fee": null}, {"timestamp": 1537295894469, "datetime": "2018-09-18T18:38:14.469Z", "symbol": "ETH/USDT", "id": "36258359", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.34, "cost": 49.9157854, "amount": 0.23731, "fee": null}, {"timestamp": 1537295894469, "datetime": "2018-09-18T18:38:14.469Z", "symbol": "ETH/USDT", "id": "36258360", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.53, "cost": 1052.65, "amount": 5.0, "fee": null}, {"timestamp": 1537295894469, "datetime": "2018-09-18T18:38:14.469Z", "symbol": "ETH/USDT", "id": "36258361", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.54, "cost": 1982.2530485999998, "amount": 9.41509, "fee": null}, {"timestamp": 1537295894469, "datetime": "2018-09-18T18:38:14.469Z", "symbol": "ETH/USDT", "id": "36258362", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.55, "cost": 500.751065, "amount": 2.3783, "fee": null}, {"timestamp": 1537295894469, "datetime": "2018-09-18T18:38:14.469Z", "symbol": "ETH/USDT", "id": "36258363", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.56, "cost": 3343.4527616, "amount": 15.87886, "fee": null}, {"timestamp": 1537295895526, "datetime": "2018-09-18T18:38:15.526Z", "symbol": "ETH/USDT", "id": "36258364", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.17, "cost": 11.2504001, "amount": 0.05353, "fee": null}, {"timestamp": 1537295896117, "datetime": "2018-09-18T18:38:16.117Z", "symbol": "ETH/USDT", "id": "36258365", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.39, "cost": 11.2621767, "amount": 0.05353, "fee": null}, {"timestamp": 1537295896117, "datetime": "2018-09-18T18:38:16.117Z", "symbol": "ETH/USDT", "id": "36258366", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.4, "cost": 39.976, "amount": 0.19, "fee": null}, {"timestamp": 1537295896117, "datetime": "2018-09-18T18:38:16.117Z", "symbol": "ETH/USDT", "id": "36258367", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.5, "cost": 210.5, "amount": 1.0, "fee": null}, {"timestamp": 1537295896117, "datetime": "2018-09-18T18:38:16.117Z", "symbol": "ETH/USDT", "id": "36258368", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.56, "cost": 9213.3623232, "amount": 43.75647, "fee": null}, {"timestamp": 1537295896844, "datetime": "2018-09-18T18:38:16.844Z", "symbol": "ETH/USDT", "id": "36258369", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.2, "cost": 105.1, "amount": 0.5, "fee": null}, {"timestamp": 1537295897232, "datetime": "2018-09-18T18:38:17.232Z", "symbol": "ETH/USDT", "id": "36258370", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.2, "cost": 334.50176999999996, "amount": 1.59135, "fee": null}, {"timestamp": 1537295897333, "datetime": "2018-09-18T18:38:17.333Z", "symbol": "ETH/USDT", "id": "36258371", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.19, "cost": 210.19, "amount": 1.0, "fee": null}, {"timestamp": 1537295897713, "datetime": "2018-09-18T18:38:17.713Z", "symbol": "ETH/USDT", "id": "36258372", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.46, "cost": 440.14762559999997, "amount": 2.09136, "fee": null}, {"timestamp": 1537295897713, "datetime": "2018-09-18T18:38:17.713Z", "symbol": "ETH/USDT", "id": "36258373", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.47, "cost": 6715.8114608, "amount": 31.90864, "fee": null}, {"timestamp": 1537295898115, "datetime": "2018-09-18T18:38:18.115Z", "symbol": "ETH/USDT", "id": "36258374", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.2, "cost": 19.355216, "amount": 0.09208, "fee": null}, {"timestamp": 1537295898173, "datetime": "2018-09-18T18:38:18.173Z", "symbol": "ETH/USDT", "id": "36258375", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.21, "cost": 439.4545155, "amount": 2.09055, "fee": null}, {"timestamp": 1537295898398, "datetime": "2018-09-18T18:38:18.398Z", "symbol": "ETH/USDT", "id": "36258376", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.14, "cost": 439.30817699999994, "amount": 2.09055, "fee": null}, {"timestamp": 1537295898417, "datetime": "2018-09-18T18:38:18.417Z", "symbol": "ETH/USDT", "id": "36258377", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.13, "cost": 233.2443, "amount": 1.11, "fee": null}, {"timestamp": 1537295898470, "datetime": "2018-09-18T18:38:18.470Z", "symbol": "ETH/USDT", "id": "36258378", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.14, "cost": 439.329191, "amount": 2.09065, "fee": null}, {"timestamp": 1537295898531, "datetime": "2018-09-18T18:38:18.531Z", "symbol": "ETH/USDT", "id": "36258379", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.13, "cost": 439.3082845, "amount": 2.09065, "fee": null}, {"timestamp": 1537295898968, "datetime": "2018-09-18T18:38:18.968Z", "symbol": "ETH/USDT", "id": "36258380", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.46, "cost": 1492.2771530000002, "amount": 7.09055, "fee": null}, {"timestamp": 1537295898968, "datetime": "2018-09-18T18:38:18.968Z", "symbol": "ETH/USDT", "id": "36258381", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.47, "cost": 5242.6919415, "amount": 24.90945, "fee": null}, {"timestamp": 1537295899958, "datetime": "2018-09-18T18:38:19.958Z", "symbol": "ETH/USDT", "id": "36258382", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.17, "cost": 836.8822281, "amount": 3.98193, "fee": null}, {"timestamp": 1537295900011, "datetime": "2018-09-18T18:38:20.011Z", "symbol": "ETH/USDT", "id": "36258383", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.34, "cost": 1319.220929, "amount": 6.27185, "fee": null}, {"timestamp": 1537295900090, "datetime": "2018-09-18T18:38:20.090Z", "symbol": "ETH/USDT", "id": "36258384", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.18, "cost": 519.6027924, "amount": 2.47218, "fee": null}, {"timestamp": 1537295900506, "datetime": "2018-09-18T18:38:20.506Z", "symbol": "ETH/USDT", "id": "36258385", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.35, "cost": 3365.6, "amount": 16.0, "fee": null}, {"timestamp": 1537295900566, "datetime": "2018-09-18T18:38:20.566Z", "symbol": "ETH/USDT", "id": "36258386", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.19, "cost": 105.095, "amount": 0.5, "fee": null}, {"timestamp": 1537295900620, "datetime": "2018-09-18T18:38:20.620Z", "symbol": "ETH/USDT", "id": "36258387", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.19, "cost": 5507.0452608000005, "amount": 26.20032, "fee": null}, {"timestamp": 1537295901008, "datetime": "2018-09-18T18:38:21.008Z", "symbol": "ETH/USDT", "id": "36258388", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.47, "cost": 37.1732114, "amount": 0.17662, "fee": null}, {"timestamp": 1537295901008, "datetime": "2018-09-18T18:38:21.008Z", "symbol": "ETH/USDT", "id": "36258389", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.48, "cost": 1457.3929872, "amount": 6.92414, "fee": null}, {"timestamp": 1537295901008, "datetime": "2018-09-18T18:38:21.008Z", "symbol": "ETH/USDT", "id": "36258390", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.49, "cost": 1069.0302973, "amount": 5.07877, "fee": null}, {"timestamp": 1537295901008, "datetime": "2018-09-18T18:38:21.008Z", "symbol": "ETH/USDT", "id": "36258391", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.52, "cost": 315.78000000000003, "amount": 1.5, "fee": null}, {"timestamp": 1537295901008, "datetime": "2018-09-18T18:38:21.008Z", "symbol": "ETH/USDT", "id": "36258392", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.53, "cost": 3139.6065211, "amount": 14.91287, "fee": null}, {"timestamp": 1537295901008, "datetime": "2018-09-18T18:38:21.008Z", "symbol": "ETH/USDT", "id": "36258393", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.55, "cost": 1349.1201800000001, "amount": 6.4076, "fee": null}, {"timestamp": 1537295901515, "datetime": "2018-09-18T18:38:21.515Z", "symbol": "ETH/USDT", "id": "36258394", "order": null, "type": null, "takerOrMaker": null, "side": "buy", "price": 210.34, "cost": 519.9983412, "amount": 2.47218, "fee": null}, {"timestamp": 1537295901569, "datetime": "2018-09-18T18:38:21.569Z", "symbol": "ETH/USDT", "id": "36258395", "order": null, "type": null, "takerOrMaker": null, "side": "sell", "price": 210.13, "cost": 1483.1164517, "amount": 7.05809, "fee": null}]}'
	select GETUTCDATE() insert_date, dt, ep.id_ex_pair, 
			conv.price, 
			conv.amount, 
			x.id_type,
			x.is_buy,
			cast(coalesce(id1, id2, id3) as decimal(38,0)) [id]

	from  OPENJSON(@json) 
		with (
			exchange varchar(50) '$.exchange',
			pair varchar(10) '$.pair'
		) e
	cross apply OPENJSON(@json,'$.histories')
		with (
			[timestamp] numeric(38, 0) '$.timestamp',
			-- [timestamp] numeric(38, 0) '$.date',
			[type] varchar(24) '$.type',
			--quantity decimal(38, 12) '$.quantity',
			price varchar(32) '$.price',
			amount varchar(32) '$.amount',
			side varchar(5) '$.side',
			[id1] bigint '$.trade_id',
			[id2] bigint '$.id',
			[id3] bigint '$.tid'
		) j
	cross apply (
		select 
			cast((case [type]
					when 'limit' then 1
					when 'market' then 2 else NULL end) as smallint) id_type,
			cast((case [side]
					when 'sell' then 0
					when 'buy' then 1 else NULL end) as bit) is_buy
	) x
	cross apply (SELECT DATEADD(second, [timestamp]/1000, CAST('1970-01-01 00:00:00' AS datetime)) dt) d
	inner join mem.exchanges_pairs ep on e.exchange=ep.exchange and e.pair=ep.pair
	cross apply (
		select
			cast(cast(j.price as real) as decimal(38,10)) price, 
			cast(cast(j.amount as real) as decimal(38,10)) amount
	) conv
	
	where not exists (select 1 from mem.history h where h.id_ex_pair = ep.id_ex_pair --and h.id=coalesce(id1,id2,id3)
			and h.dt = d.dt and h.price=conv.price and h.amount=conv.amount --and h.is_buy=x.is_buy
		)
	--and	  not exists (select 1 from dbo.history h where h.exchange=t.exchange and h.pair=t.pair and h.id=t.id)

	--return @@ROWCOUNT
end
go


grant select on mem.exchanges_pairs to [Workers]
grant execute on mem.save_history_json to [Workers]
go