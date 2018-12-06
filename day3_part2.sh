#!/usr/local/bin/bash

declare -A fabric
declare -A suggestions

while read -r line; do
	id=$(echo "$line" | sed -e 's/\#\([0-9]*\)\ .*/\1/')

  if (( id % 100 == 0 )); then
    echo "Parsing row: $id "
  fi

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
  # echo "ID: $id; Left: $left_pos; Right: $right_pos; Top: $top_pos; Bottom: $bottom_pos;"
  suggestions[$id]="$top_pos.$bottom_pos,$left_pos.$right_pos"
done < "$1"

for id in "${!suggestions[@]}"; do
  suggestion=${suggestions[$id]}

  vert_position=${suggestion%,*}
  horiz_position=${suggestion#*,}

  top_pos=${vert_position%.*}
  bottom_pos=${vert_position#*.}

  left_pos=${horiz_position%.*}
  right_pos=${horiz_position#*.}
  # echo "ID: $id; Left: $left_pos; Right: $right_pos; Top: $top_pos; Bottom: $bottom_pos;"


  for (( r = top_pos; r < bottom_pos; r++)); do
    for (( c = left_pos; c < right_pos; c++ )); do
      if [[ ${fabric[$r,$c]} == "X" ]]; then
        id="X"
      fi
    done
  done
  if [[ "$id" != "X" ]]; then
    echo "The non-overlaping suggestion is: $id"
    exit 0
  fi
done