#!/bin/bash

# reference: https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens

function check_command() { command -v $1 > /dev/null && return 0 || echo $1 not found && exit 1; }
function check_var() { [ -v $1 ] && return 0 || echo $1 not exist && exit 1; }
function base64url() { openssl enc -base64 -A | tr '+/' '-_' | tr -d =; }

function convert_ec {
  local INPUT=$(openssl asn1parse -inform der)
  local R=$(echo "$INPUT" | head -2 | tail -1 | cut -d':' -f4)
  local S=$(echo "$INPUT" | head -3 | tail -1 | cut -d':' -f4)

  echo -n $R | xxd -r -p
  echo -n $S | xxd -r -p
}

function es_sign() { 
  check_var private_key
  local private_key_file=`mktemp`
  echo $private_key | sed 's/\\n/\n/g' >$private_key_file

  openssl dgst -binary -sha256 -sign $private_key_file | convert_ec;
  rm $private_key_file
}

function get_jwt() {
  check_command jq
  check_command vault
  check_command openssl

  check_var kid
  check_var iss
  check_var sub
  check_var aud

  iat=`date +%s`
  exp=`date +%s -d "$1"`

  local header=$(cat <<EOF | base64url
{"alg":"ES256","kid":"$kid"}
EOF
)

  local payload=$(cat <<EOF | base64url
{"iss":"$iss","iat":$iat,"exp":$exp,"aud":"$aud","sub":"$sub"}
EOF
)

  local jwt_unsign="$header.$payload"
  local jws=`echo -n "$jwt_unsign" | es_sign | base64url | cat`

  echo -n "$jwt_unsign.$jws"
}

function get_vars {
  check_var VAULT_ADDR

  local secret=$(vault read -format=json $1 | jq ".data | to_entries | .[] | .key + \"='\" + .value + \"'\"" | tr -d \")
  eval "$secret"
}

function parse_args() {
  local usage="$(basename "$0") -p vault-secret-path -d duration

  where:
      -p  vault's path to store secret. e.g.: kv/secret
      -d  duration string for date. e.g.: \"1 day\", \"1 year\"
  "

  unset vault_secret_path
  unset secret_duration
  while getopts 'p:d:' opt; do
    case "$opt" in
      p) vault_secret_path=$OPTARG
         ;;
      d) secret_duration=$OPTARG
         ;;
      :) printf "missing argument for -%s\n" "$OPTARG" >&2
         echo "$usage" >&2 && exit 1
         ;;
     \?) printf "illegal option: -%s\n" "$OPTARG" >&2
         echo "$usage" >&2 && exit 1
         ;;
    esac
  done
  shift "$((OPTIND - 1))"

  [ -z "$vault_secret_path" ] && echo "$usage" >&2 && exit 1

  # default secret expire duration
  [ -z "$secret_duration" ] && secret_duration="15777000 second"
}

parse_args "$@"

get_vars $vault_secret_path
get_jwt "$secret_duration" | cat
