# Introduction

This script generate a base64 encoded vault transit backup json object from PEM file.

# Example

**Run script offline**

```bash
# one liner
$ cat key.pem | ./ecdsa-key-to-vault-transit-backup/run.sh

# one liner, restore key to vault
$ cat key.pem | ./ecdsa-key-to-vault-transit-backup/run.sh | vault write -f transit/restore/newkey backup=-
```

**Run script online**

```bash
# one liner
$ cat key.pem | curl -sL https://github.com/eStreamSoftware/scripts/raw/main/ecdsa-key-to-vault-transit-backup/run.sh

# one liner, restore key to vault
$ cat key.pem | curl -s https://github.com/eStreamSoftware/scripts/raw/main/ecdsa-key-to-vault-transit-backup/run.sh | vault write -f transit/restore/newkey backup=-
```
