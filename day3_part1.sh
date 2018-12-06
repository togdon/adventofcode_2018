#!/usr/local/bin/bash

declare -A fabric
num_rows=1001
num_cols=1001

while read -r line; do
	id=$(echo "$line" | sed -e 's/\#\([0-9]*\)\ .*/\1/')

  position=$(echo "$line" | sed -e 's/.*@\ \([0-9]*,[0-9]*\):\ .*/\1/')
  left_pos=${position%,*}
  top_pos=${position#*,}

  area=$(echo "$line" | sed -e 's/.*:\ \([0-9]*x[0-9]*\)/\1/')
  right_pos=$((left_pos + ${area%x*}))
  bottom_pos=$((top_pos + ${area#*x}))

  for (( r = top_pos; r < bottom_pos; r++)); do
    for (( c = left_pos; c < right_pos; c++ )); do
      if [[ -z ${fabric[$r,$c]} ]]; then
        fabric[$r,$c]=$id
      else
        fabric[$r,$c]="X"
      fi
    done
  done
  echo "ID: $id; Left: $left_pos; Right: $right_pos; Top: $top_pos; Bottom: $bottom_pos;"
done < "$1"

overlap_count=0
for (( i = 0; i < num_rows; i++ )) do
  if (( i % 100 == 0 )); then       
    echo "Checking row: $i "
  fi
  for ((j = 0; j < num_cols; j++ )) do
    if [[ ${fabric[$i,$j]} == "X" ]]; then
      ((overlap_count++))
    fi
  done
done

echo "Overlap: $overlap_count"

