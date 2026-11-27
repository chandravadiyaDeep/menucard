#!/usr/bin/env python3
"""Generate individual MenuCard owner access-code files and a private issuer ledger."""
import csv
import json
import secrets
import string
import zipfile
from pathlib import Path

# 75 bits of randomness per code; ambiguous characters are excluded.
ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
COUNT = 100
OUTPUT = Path("menucard-issued-codes")
ZIP_NAME = Path("menucard-personal-code-files.zip")
LEDGER = Path("menucard-issuer-ledger.csv")


def make_code():
    """Return a readable code whose separators are ignored by the app."""
    return "-".join(
        "".join(secrets.choice(ALPHABET) for _ in range(5))
        for _ in range(3)
    )


def main():
    OUTPUT.mkdir(exist_ok=True)
    records = []
    for serial in range(1, COUNT + 1):
        code = make_code()
        filename = f"menucard-code-{serial:03d}.json"
        payload = {"schema_version": 1, "code": code}
        (OUTPUT / filename).write_text(
            json.dumps(payload, indent=2), encoding="utf-8"
        )
        records.append((serial, code, "unissued", ""))

    # Package only the individual files; do not create a customer-facing batch
    # JSON containing every code.
    with zipfile.ZipFile(ZIP_NAME, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(OUTPUT.glob("*.json")):
            archive.write(path, arcname=path.name)

    # This CSV is the issuer's private cross-device assignment ledger.
    with LEDGER.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["serial", "access_code", "status", "assigned_mobile"])
        writer.writerows(records)

    print(f"Generated {COUNT} personal code files in {OUTPUT}/")
    print(f"Distribute one JSON file per shop owner from {ZIP_NAME}.")
    print(f"Keep {LEDGER} private; update it before each code is distributed.")


if __name__ == "__main__":
    main()
