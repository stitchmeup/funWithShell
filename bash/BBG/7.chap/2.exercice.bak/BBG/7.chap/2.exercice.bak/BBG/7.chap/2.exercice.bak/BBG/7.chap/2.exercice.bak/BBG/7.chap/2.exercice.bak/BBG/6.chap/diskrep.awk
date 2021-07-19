BEGIN {print "*** WARNING WARNING WARNING ***"}
/\<[8|9][0-9]%/ {print "Partition " $6 "\t: " $5 " full!"}
/\<[6|7][0-9]%/ {print "Partition " $6 "\t: " $5 " almost full!"}
/\<[0-5][0-9]?%/ {print "Partition " $6 "\t: " $5 " OK, nice disk usage management!"}
END {print "*** Take action according to your situation ***"}
