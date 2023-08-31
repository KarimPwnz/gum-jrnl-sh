#!/bin/bash

if [ $# != 1 ]; then
    echo 'pass a jrnl file name!'
    exit 1
fi

jrnl_file="$1"
pass=$(gum input --password --placeholder='journal password')

if [ ! -f "$jrnl_file" ]; then
    touch "$jrnl_file"
    curr_jrnl=''
else
    curr_jrnl=$(openssl aes-256-cbc -d -in "$jrnl_file" -base64 -pbkdf2 -pass "pass:$pass")
    if [ $? -ne 0 ]; then
        echo 'decryption failed!'
        exit 1
    fi
fi

action=$(gum choose "write" "read" "filter")

if [ "$action" == "write" ]; then
    entry=$(gum write --placeholder='Journal entry (Ctrl+D to finish)')
    if [ -z "$entry" ]; then
        echo 'nothing jrnled!'
        exit 0
    fi
    next_jrnl="$(date): ${entry}\n${curr_jrnl}"
    openssl aes-256-cbc -in <(echo -e "$next_jrnl") -out "$jrnl_file" -base64 -pbkdf2 -pass "pass:$pass"
elif [ "$action" ==  "read" ]; then
    echo -e "$curr_jrnl"
elif [ "$action" == "filter" ]; then
    echo -e "$curr_jrnl" | gum filter
fi

