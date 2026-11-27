#!/usr/bin/env python3
"""Generate owner-issued MenuCard codes offline. Keep the CSV private."""
import csv
import json
import secrets
import string
from pathlib import Path

# 80-bit random codes with an ambiguity-free alphabet.
ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
COUNT = 100

def main():
    codes = ["-".join("".join(secrets.choice(ALPHABET) for _ in range(5)) for _ in range(3))
             for _ in range(COUNT)]
    Path("menucard-issued-codes.json").write_text(
        json.dumps({"schema_version": 1, "codes": codes}, indent=2), encoding="utf-8")
    with Path("menucard-issued-codes.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["serial", "access_code", "status", "assigned_mobile"])
        writer.writerows([[i + 1, code, "unissued", ""] for i, code in enumerate(codes)])
    print(f"Generated {COUNT} codes. Store both files securely; never publish them.")

if __name__ == "__main__":
    main()
