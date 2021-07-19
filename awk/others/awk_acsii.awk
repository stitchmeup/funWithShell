#!/bin/awk -f

# Print all printable ASCII chars
BEGIN {
    for (i = 32; i < 127; i++)
        printf "%3d 0x%02x %c\n", i, i, i
}
# pipe to 'pr -t6 -w78' to format output
