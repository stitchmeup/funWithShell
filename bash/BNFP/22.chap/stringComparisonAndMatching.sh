#!/usr/bin/env bash

# String comparison uses the == operator between quoted strings.
# The != operator negates the comparison.
if [[ "$string1" == "$string2" ]]; then
  echo "\$string1 and \$string2 are identical"
fi
if [[ "$string1" != "$string2" ]]; then
  echo "\$string1 and \$string2 are not identical"
fi

# If the right-hand side is not quoted then it is a wildcard pattern that $string1 is matched against.
string='abc'
pattern1='a*'
pattern2='x*'
if [[ "$string" == $pattern1 ]]; then
  # the test is true
  echo "The string $string matches the pattern $pattern"
fi
if [[ "$string" != $pattern2 ]]; then
  # the test is false
  echo "The string $string does not match the pattern $pattern"
fi
# The < and > operators compare the strings in lexicographic order
# (there are no less-or-equal or greater-or-equal operators for strings).

# There are unary tests for the empty string.
if [[ -n "$string" ]]; then
  echo "$string is non-empty"
fi
if [[ -z "${string// }" ]]; then
  echo "$string is empty or contains only spaces"
fi
if [[ -z "$string" ]]; then
  echo "$string is empty"
fi

# Above, the -z check may mean $string is unset, or it is set to an empty string.
# To distinguish between empty and unset, use:
if [[ -n "${string+x}" ]]; then
  echo "$string is set, possibly to the empty string"
fi
if [[ -n "${string-x}" ]]; then
  echo "$string is either unset or set to a non-empty string"
fi
if [[ -z "${string+x}" ]]; then
  echo "$string is unset"
fi
if [[ -z "${string-x}" ]]; then
  echo "$string is set to an empty string"
fi
# where x is arbitrary. Or in table form:
# +-------+-------+-----------+
#  $string is:          | unset | empty | non-empty |
# +-----------------------+-------+-------+-----------+
# | [[ -z ${string} ]]   | true  | true  | false
# |
# | [[ -z ${string+x} ]] | true  | false | false
# |
# | [[ -z ${string-x} ]] | false | true  | false
# |
# | [[ -n ${string} ]]   | false | false | true
# |
# | [[ -n ${string+x} ]] | false | true  | true
# |
# | [[ -n ${string-x} ]] | true  | false | true
# |
# +-----------------------+-------+-------+-----------+

# Alternatively, the state can be checked in a case statement:

case ${var+x$var} in
  (x) echo empty;;
  ("") echo unset;;
  (x*[![:blank:]]*) echo non-blank;;
  (*) echo blank
esac
