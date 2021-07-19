#!/bin/awk -f

### Input : key1 -> value1, key2 -> value2
### Ouput : id  key1    key2
###         1   value1  value2
### Assuming ID is record number

BEGIN {
    FS = "->|,"

    format = "%4s %8s %8s\n"   # to be adapt for longer field length, if you wanna keep heading and field's record align
    printf format, "id", "key1", "key2"
}
{
    printf format, NR, $2, $4
}
