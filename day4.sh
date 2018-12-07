#!/usr/local/bin/bash

declare -A sleep_durations
declare -A sleep_minutes

while read -r line; do
  date=$(echo "$line"| sed -e 's/\[[0-9]\{2\}\([0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}\)\ \([0-9]\{2\}\):\([0-9]\{2\}\)\]\ \(.*\)/\1/')

  time=$(echo "$line"| sed -e 's/\[\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)\ \([0-9]\{2\}:[0-9]\{2\}\)\]\ \(.*\)/\2/')
  minute=$(echo "$line"| sed -e 's/\[\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)\ \([0-9]\{2\}\):\([0-9]\{2\}\)\]\ \(.*\)/\3/' -e 's/^0//')
  epoch_time=$(date -j -f "%y-%m-%d %H:%M" "$date $time" "+%s")

  message=$(echo "$line"| sed -e 's/\[\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)\ \([0-9]\{2\}\):\([0-9]\{2\}\)\]\ \(.*\)/\4/')

  if [[ "$message" =~ "begins" ]]; then
    guard=$(echo "$message" | sed -e 's/.*\#\([0-9]*\)\ .*/\1/')
    if [[ -z ${sleep_durations[$guard]} ]]; then
      sleep_durations[$guard]=0
    fi
  elif [[ "$message" =~ "falls" ]]; then
    start_sleep="$epoch_time"
    start_minute="$minute"
  else
    stop_sleep="$epoch_time"
    stop_minute="$minute"
    duration=$(((stop_sleep - start_sleep)/60))

    sleep_durations[$guard]=$(((${sleep_durations[$guard]} + duration)))
    for (( i = start_minute; i < stop_minute; i++ )); do
      if [[ -z "${sleep_minutes[$guard-$i]}" ]]; then
        sleep_minutes[$guard-$i]=1
      else
        sleep_minutes[$guard-$i]=$((${sleep_minutes[$guard-$i]} + 1))
      fi
    done
  fi
done <  <(sort "$1")

for guard in "${!sleep_durations[@]}"; do
  if [[ -z $longest_guard ]]; then
    echo "Guard $guard slept the longest so far at ${sleep_durations[$guard]} minutes"
    longest_guard=$guard
  else
    if [[ ${sleep_durations[$guard]} > ${sleep_durations[$longest_guard]} ]]; then
      longest_guard=$guard
      echo "Guard $guard slept the longest so far at ${sleep_durations[$guard]} minutes"
    fi
  fi
done

for gm in "${!sleep_minutes[@]}"; do
  gmg=${gm%-*}
  gmm=${gm#*-}
  if [[ "$gmg" == "$longest_guard" ]]; then
    if [[ -z $frequent_minute ]]; then
      frequent_minute=$gmm
      echo "$gmm is the most frequent minute so far for Guard $gmg at ${sleep_minutes[$gm]} times"
    else
      check="$gmg-$frequent_minute"
      if [[ "${sleep_minutes[$gm]}" -gt "${sleep_minutes[$check]}" ]]; then
        frequent_minute="$gmm"
        echo "$gmm is the most frequent minute so far for Guard $gmg at ${sleep_minutes[$gm]} times"
      fi
    fi
  fi
  if [[ -z $frequent_minute_all ]]; then
    frequent_minute_all=$gm
    echo "$gmm is the most frequent minute so far for $gmg at ${sleep_minutes[$gm]} times"
  else
    if [[ "${sleep_minutes[$gm]}" -gt "${sleep_minutes[$frequent_minute_all]}" ]]; then
      frequent_minute_all=$gm
      echo "$gmm is the most frequent minute so far for $gmg at ${sleep_minutes[$gm]} times"
    fi
  fi
done


echo ""
echo "Guard $longest_guard slept for ${sleep_durations[$longest_guard]} minutes, which was the longest amount. $frequent_minute was the most frequent minute"
echo "The most frequent minute for all was $frequent_minute_all"
