# Offline owner-issued account architecture

## Product contract
MenuCard account activation works without internet, cloud services, a backend, database server, or phone-number OTP. The issuer creates access codes on a trusted computer and distributes one personal code file to each shop owner.

## Issuer workflow
1. Run `python tools/generate_owner_codes.py` on the trusted issuer computer.
2. The script creates 100 individual JSON files in `menucard-issued-codes/`, a ZIP containing those personal files, and a private CSV master ledger.
3. Keep the CSV private. Before distribution, mark one serial as assigned and record the recipient's mobile number.
4. Send only that recipient's personal JSON file. Do not send the full ZIP or ledger to a shop owner.
5. The shop imports their personal JSON file in MenuCard, enters their mobile number and shop name, and activates the account offline.

## Hard offline boundary
The app prevents a code from being claimed twice on the same installation. It cannot discover a claim on another phone. The issuer's private CSV ledger is the cross-device source of truth; mark codes assigned before distribution. Never describe this as globally enforced by the app.

## Local storage and recovery
- Account registry: app-private `accounts.json`, separate from public menu exports.
- Only salted SHA-256 digests of issued codes are stored by the app; raw codes are not persisted in the registry.
- The account activation screen can restore a private account recovery JSON backup on a replacement phone.
- The owner workspace provides a separate account recovery export action. It is distinct from the menu backup.
- Phone number alone is not proof of ownership and cannot retrieve an access code offline.
- Existing installations that already contained a MenuCard menu are grandfathered during the first account migration so their local data is not unexpectedly locked.
- A restored backup duplicates the local registry. Retire the old installation after a successful move.

## Security and privacy
- Generate codes using Python's cryptographically secure `secrets` module; each code contains 75 bits of randomness.
- The issuer CSV contains raw codes and mobile assignments; store it offline and access-control it.
- Do not commit issued-code files, CSV ledgers, customer mobile numbers, backups, or signing credentials.
- Mobile numbers are identifiers only. Without SMS or another trusted verification channel, the app cannot prove control of a number.
- If a code is lost, the issuer must manually verify the owner outside the app and issue a replacement from the private ledger. The app cannot perform remote "Get My Code" recovery without a trusted communication channel.
