#! /bin/sh

# Check, if a program with name $1 exists
programExists()
{
    PRG_NAME=$1
    command -v $PRG_NAME >/dev/null 2>&1
}
