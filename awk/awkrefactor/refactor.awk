#!/bin/awk -f

# Refactor lines of the second file given as arg from the associative array created by the first file
BEGIN {
  regex[0] = "^(nord[0-9]+):$"
  regex[1] = "^.*:.*(nord[0-9]+)"
}
{
  if ( NR == FNR ){
    match($1, regex[0], found);
    if (found[1]){
      matchz[found[1]] = $2;
    }
  } else {
    match($0, regex[1], found)
    if (found[0]){
      gsub(/nord[0-9]+/, matchz[found[1]]);
      print $0;
    } else {
      print $0;
    }
  }
}
