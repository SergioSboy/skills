import os
import random
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor


BASE_URL = os.environ["BASE_URL"]

DURATION = int(os.getenv("DURATION", "600"))
BASE_RPS = int(os.getenv("BASE_RPS", "5"))
BURST_RPS = int(os.getenv("BURST_RPS", "10"))

BURST_DURATION = int(os.getenv("BURST_DURATION", "10"))
BURST_INTERVAL = int(os.getenv("BURST_INTERVAL", "60"))

TIMEOUT = float(os.getenv("TIMEOUT", "5"))

URLS = [
    {
        "path": item.split("|")[0],
        "weight": int(item.split("|")[1]),
    }
    for item in os.environ["URLS"].split(",")
]


def choose_url():
    paths = [item["path"] for item in URLS]
    weights = [item["weight"] for item in URLS]

    return random.choices(paths, weights=weights, k=1)[0]


def request():
    path = choose_url()
    url = BASE_URL.rstrip("/") + path

    started = time.monotonic()

    try:
        request = urllib.request.Request(
            url,
            method="GET",
            headers={
                "User-Agent": "rails-load-test/1.0",
            },
        )

        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            status = response.status

    except Exception as error:
        status = "ERROR"
        error = str(error)

    duration = time.monotonic() - started

    print(
        f"{time.strftime('%H:%M:%S')} "
        f"{status} "
        f"{duration:.3f}s "
        f"{path}",
        flush=True,
    )


def run_rps(rps, seconds):
    end = time.monotonic() + seconds

    while time.monotonic() < end:
        started = time.monotonic()

        with ThreadPoolExecutor(max_workers=rps) as executor:
            futures = [
                executor.submit(request)
                for _ in range(rps)
            ]

            for future in futures:
                future.result()

        elapsed = time.monotonic() - started
        sleep_time = max(0, 1 - elapsed)

        time.sleep(sleep_time)


def main():
    print("================================")
    print("Rails load test")
    print("================================")
    print(f"Base URL: {BASE_URL}")
    print(f"Duration: {DURATION}s")
    print(f"Base RPS: {BASE_RPS}")
    print(f"Burst RPS: {BURST_RPS}")
    print(f"Burst duration: {BURST_DURATION}s")
    print(f"Burst interval: {BURST_INTERVAL}s")
    print()
    print("URLs:")

    for item in URLS:
        print(f"  {item['path']} (weight={item['weight']})")

    print("================================")
    print()

    started = time.monotonic()
    next_burst = started + BURST_INTERVAL

    while time.monotonic() - started < DURATION:
        now = time.monotonic()

        if now >= next_burst:
            print(
                f"\n🔥 BURST: {BURST_RPS} RPS "
                f"for {BURST_DURATION}s\n",
                flush=True,
            )

            run_rps(BURST_RPS, BURST_DURATION)

            next_burst = time.monotonic() + BURST_INTERVAL

        else:
            run_rps(BASE_RPS, 1)


if __name__ == "__main__":
    main()