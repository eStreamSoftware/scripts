#!/bin/bash

function hex_to_dec() { tr 'a-f' 'A-F' | cat <<< "ibase=16; $(</dev/stdin)" | BC_LINE_LENGTH=0 bc; }

function get_transit_backup()
{
  cat << EOF
{
   "policy":{
      "keys":{
         "1":{
            "ec_x":$1,
            "ec_y":$2,
            "ec_d":$3,
            "public_key": "$4"
         }
      },
      "min_decryption_version":1,
      "min_encryption_version":0,
      "latest_version":1,
      "type": 1,
      "deletion_allowed": true
   }
}
EOF
}

private_key=$(</dev/stdin)
public_key=`echo "$private_key" | openssl pkey -pubout -in - | sed -z  's/\n/\\\n/g'`
private_key_der=`echo "$private_key" | openssl pkey -outform der -in - | xxd -p | tr -d '\n'`

ec_d=`hex_to_dec <<< ${private_key_der:14:64}`
ec_x=`hex_to_dec <<< ${private_key_der:114:64}`
ec_y=`hex_to_dec <<< ${private_key_der:178:64}`

get_transit_backup $ec_x $ec_y $ec_d "$public_key" | base64