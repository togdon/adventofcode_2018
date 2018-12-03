#!/usr/local/bin/bash

twos=0
threes=0

while read -r line; do
  letters=$(sed -e $'s/\(.\)/\\1\\\n/g' <<< "$line" | sort | uniq -ic | grep -E '2|3')
  if grep -q 2 <<< "$letters"; then
    twos=$((twos + 1))  
  fi
  if grep -q 3 <<< "$letters"; then
    threes=$((threes + 1))  
  fi
done < "$1"

echo "Twos: $twos, Threes: $threes"
echo "Checksum: $((twos * threes))"