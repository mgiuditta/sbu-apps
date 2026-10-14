#!/usr/bin/env python3
"""Refresh Sbu Subscriptions' bundled exchange rates from the ECB euro reference rates.

Run before each Subscriptions release; the app itself never goes online.
Source: https://www.ecb.europa.eu/stats/eurofxref/ (free to reuse, citing the ECB).
Rates are kept as strings so the app reads them as exact Decimals.
"""
import json
import pathlib
import urllib.request
import xml.etree.ElementTree as ET

URL = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
OUT = pathlib.Path(__file__).resolve().parent.parent / "Apps/SbuSubscriptions/SbuSubscriptions/Currency/ExchangeRates.json"
NS = {"e": "http://www.ecb.int/vocabulary/2002-08-01/eurofxref"}


def main() -> None:
    with urllib.request.urlopen(URL, timeout=30) as response:
        root = ET.fromstring(response.read())
    day = root.find("e:Cube/e:Cube", NS)
    if day is None:
        raise SystemExit("ECB feed has no rates")
    rates = {"EUR": "1"} | {cube.get("currency"): cube.get("rate") for cube in day.findall("e:Cube", NS)}
    if len(rates) < 20:
        raise SystemExit(f"ECB feed has only {len(rates)} rates")
    OUT.write_text(json.dumps({"day": day.get("time"), "perEuro": dict(sorted(rates.items()))}, indent=2) + "\n")
    print(f"{OUT.name}: {len(rates)} currencies, {day.get('time')}")


if __name__ == "__main__":
    main()
