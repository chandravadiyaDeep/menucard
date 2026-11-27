# Offline owner-issued account architecture

## Product contract
MenuCard account registration works without internet, cloud services, a backend, a database server, or phone-number OTP. The owner generates access codes on a trusted computer and distributes one code to each shop owner.

## Issuance workflow
1. Run `python tools/generate_owner_codes.py` on the owner's trusted computer.
2. Keep the generated CSV as the issuer's master ledger. It contains the code, status and assigned mobile.
3. Deliver one code privately to one shop owner and record the mobile assignment in the ledger.
4. Import the corresponding JSON code batch into that owner's MenuCard installation using the owner/admin import flow.
5. The app claims a code once in its local `accounts.json` registry and associates it with the entered mobile and shop name.

## Hard offline boundary
The app can prevent a code from being claimed twice **on the same installation**. It cannot discover a claim on another phone. The issuer's private ledger is the authority for cross-device uniqueness; mark a code assigned before distributing it. Never describe this as globally enforced by the app.

## Storage and recovery
- Account registry: app-private `accounts.json`, separate from public menu exports.
- Only salted SHA-256 digests of issued codes are stored by the app; raw codes remain in the issuer's private ledger.
- Recovery is by exporting the private account backup and restoring it on the replacement phone. Phone number alone is not proof of ownership and must never disclose a code.
- A restored backup duplicates the local registry; retire/wipe the old installation after a successful move.
- Phone numbers are identifiers only. Without SMS or another trusted verification channel, the app cannot prove control of a number.

## Operational security
- Generate codes with a cryptographically secure random generator; keep the issuer CSV offline and access-controlled.
- Do not commit real issued codes, customer mobile numbers, backups, or signing credentials.
- If an owner loses both the phone and recovery backup, the issuer may issue a replacement code after manually verifying the owner outside the app and revoking the old ledger entry.
