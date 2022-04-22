#!/bin/bash

SEED_ARG="$1"
SEED=
SEED_NAME="$2"

if [ "$SEED_ARG" != "" ]; then

    SEED_TMP="$(sed 's/(^[[:space:]]|[[:space:]]$)//g' <<< ${SEED_ARG})"
    
    if [[ "$SEED_TMP" =~ ^[0-9]+$ ]]; then
        
        if [ ! "${#SEED_TMP}" -le 10 ]; then
            echo "${indent}Error: $SEED_NAME is too big: $SEED_ARG" 1>&2; exit 1
        fi
        
        if [ ! "$SEED_TMP" -le 2147483648 ]; then
            echo "${indent}Error: $SEED_NAME is too big: $SEED_ARG" 1>&2; exit 1
        fi
        
        SEED="$SEED_TMP"
        
    elif [[ "$SEED_TMP" =~ ^0x[A-Fa-f0-9]+$ ]]; then
        
        if [ ! "${#SEED_TMP}" -le 10 ]; then
            echo "${indent}Error: $SEED_NAME is too big: $SEED_ARG" 1>&2; exit 1
        fi
        
        SEED_TMP="$(printf '%d' $SEED_TMP)"
        
        if [ ! "$SEED_TMP" -le 2147483648 ]; then
            echo "${indent}Error: $SEED_NAME is too big: $SEED_ARG" 1>&2; exit 1
        fi
        
        SEED="$SEED_TMP"
    else
        echo "${indent}Error: Invalid seed: $SEED_ARG" 1>&2; exit 1
    fi
            
    #SEED_NAME="$(echo "$SEED_NAME" | tr '[:upper:]' '[:lower:]')"
    #echo "${indent}[*$SEED_NAME]"
    #echo "${indent}${indent_step}$SEED"
    #echo ""
else
    
    SEED=$(openssl rand -hex 4)
    SEED=$(printf "%d" 0x$SEED)
    SEED=$(($SEED >> 1))
    
    #SEED_NAME="$(echo "$SEED_NAME" | tr '[:upper:]' '[:lower:]')"
    #echo "${indent}[$SEED_NAME]"
    #echo "${indent}${indent_step}$SEED (randomly assigned)"
    #echo ""
fi

echo "$SEED"

