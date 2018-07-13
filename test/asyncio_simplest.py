import asyncio
from decimal import Decimal


def compute_pi(digits):
    # implementation
    print(f"digits={digits}")
    return 3.141592


async def main(loop):
    digits = await loop.run_in_executor(None, compute_pi, 6)
    print("pi: %s" % digits)


loop = asyncio.get_event_loop()
loop.run_until_complete(main(loop))
loop.close()