import unittest
import os
import sys

class TestMarkets(unittest.TestCase):

    def test_load_exchanges(self):
        root = os.getcwd()
        # os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        # os.chdir(root)
        self.assertEqual(root.split("\\")[-1], "Arbitron")
        #sys.path.append(root + "\\database")
        # self.assertEqual(sys.path[-1].split("\\")[-1], "database")
        #sys.path.append(root + "\\markets")
        # self.assertEqual(sys.path[-1].split("\\")[-1], "markets")

        from database import Database
        from markets import Markets

        exchanges_list = [
                'binance',
                'bittrex',
                'cryptopia',
                'exmo',
                'hitbtc2',
                'kraken',
                'okex',
                'poloniex',
                'yobit',
        ]

        markets = Markets(Database())

        self.assertIsInstance(markets, Markets)


if __name__ == '__main__':
    unittest.main()