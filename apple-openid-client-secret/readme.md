# Introduction

This script generate `client_secret` for apple application based on [Generate and Validate Tokens](https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens).

All information to generate `client_secret` shall retrieved from a vault stored in this format:

```json
{
  "aud": "https://appleid.apple.com",
  "iss": "put your 10-character Team ID",
  "kid": "A 10-character key identifier generated for the Sign in with Apple private key associated with your developer account",
  "private_key": "-----BEGIN PRIVATE KEY-----\n.....\n-----END PRIVATE KEY-----",
  "public_key": "-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----",
  "sub": "put your app's client_id"
}
```

# Example

**Run script offline**

```bash
# one liner
$ VAULT_ADDR="http://127.0.0.1:8200" ./apple-openid-client-secret/run.sh -p kv/secret

# using environment variable
$ export VAULT_ADDR="http://127.0.0.1:8200"
$ ./apple-openid-client-secret/run.sh -p kv/secret
```

**Run script online**

```bash
# one liner
$ curl -s https://raw.githubusercontent.com/eStreamSoftware/scripts/dev/apple-openid-client-secret/run.sh | VAULT_ADDR="http://127.0.0.1:8200" bash -s -- -p kv/secret

# using environment variable
$ export VAULT_ADDR="http://127.0.0.1:8200"
$ curl -s https://raw.githubusercontent.com/eStreamSoftware/scripts/dev/apple-openid-client-secret/run.sh | bash -s -- -p kv/secret
```
