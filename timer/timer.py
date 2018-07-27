import time

class Timer:
    def __init__(self):
        self.start = time.time()

    def tic(self):
        return "%2.2f" % (time.time() - self.start)