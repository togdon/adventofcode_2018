#!/usr/local/bin/bash

file=$1
lines_checked=0

while read -r line; do
  declare -a boxid=()

  letters=$(sed -e $'s/\(.\)/\\1\\\n/g' <<< "$line" | perl -pe 'chomp if eof')
  for letter in $letters; do
    # all the letters for the line we're focused on in an array
    boxid+=("$letter")
  done

  grep -v "$line" "$file" | while read -r sub_line; do
    # all the lines that *aren't* the line we're focused on
    position=0
    count=0
    sub_letters=$(sed -e $'s/\(.\)/\\1\\\n/g' <<< "$sub_line" | perl -pe 'chomp if eof')
    for sub_letter in $sub_letters; do
      if [[ ${boxid[$position]} == "$sub_letter" ]]; then
        count=$((count + 1))
      fi
      position=$((position + 1))
    done
    if [[ "$count" == 25 ]]; then
      echo "Line 1: $line, Line 2: $sub_line"
      # I'm being lazy, you have to visually remove the extra letter
    fi
  done

  lines_checked=$((lines_checked + 1))
  echo "Lines checked: $lines_checked"
done < "$file"
