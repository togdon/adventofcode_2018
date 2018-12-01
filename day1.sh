#!/usr/local/bin/bash

declare -A frequencies
frequency=0
frequencies[$frequency]=$frequency
passes=0

while [[ -z "$repeat" ]]; do
  passes=$((passes+1))
  while read -r line; do
      frequency=$(($frequency$line))
      if [[ ${frequencies[$frequency]} ]]; then
        repeat="$frequency"
        break
      fi
      frequencies[$frequency]=$frequency
  done < "$1"
  echo "Completed $passes passes; ${#frequencies[@]} frequencies seen, current frequency: $frequency"
done

echo ""
echo "First repeat: $repeat"