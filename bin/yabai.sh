#!/bin/bash

function max_index() {
  yabai -m query --spaces --display \
    | jq 'map(select(."is-native-fullscreen" == false))[-1].index'
}

function index() {
  if [ "$1" = "last" ]; then
    yabai -m query --spaces --display | \
      jq "map(select(.\"is-native-fullscreen\" == false))[-1].index"
  elif [ "$1" = "current" ]; then
    yabai -m query --spaces --display \
      | jq 'map(select(."has-focus" == true))[-1].index'
  elif [ "$1" = "recent" ]; then
    yabai -m query --spaces --space recent | jq '.index'
  else  # right & left
    let ix=$(yabai -m query --spaces --display | \
      jq "map(.\"is-native-fullscreen\" == false and .index == $(index current)) | index(true)")
    if [ "$1" = "right" ]; then
      let ix++
    elif [ "$1" = "left" ]; then
      let ix--
    fi
    yabai -m query --spaces --display | \
      jq "map(select(.\"is-native-fullscreen\" == false))[$ix].index"
  fi
}

function move_to_space() {
  if [ -z "$1" ]; then
    echo "move_window_to_space did not receive any arguments"
    return
  fi
  if [ "$1" = "left" ]; then
    if [ $(index current) -eq 1 ]; then
      yabai -m space --create
      yabai -m space $(index last) --move 1
    fi
    let target_space=$(index left)
  elif [ "$1" = "right" ]; then
    if [ $(index current) -eq $(index last) ]; then
      yabai -m space --create
    fi
    let target_space=$(index right)
  elif [ "$1" = "new" ]; then
    yabai -m space --create
    let target_space=$(index last)
  elif [ "$1" = "recent" ]; then
    let target_space=$(index recent)
  fi
  if [ "$2" = "with_window" ]; then
    yabai -m window --space "$target_space"
  fi
  yabai -m space --focus "$target_space"
}

function destroy_empty_spaces() {
  # echo
  yabai -m query --spaces --display | \
       jq -re 'map(select(."is-native-fullscreen" == false)) | length > 1' \
       && yabai -m query --spaces | \
            jq -re 'map(select(."windows" == [] and ."has-focus" == false).index) | reverse | .[] '
  # destroy
  yabai -m query --spaces --display | \
       jq -re 'map(select(."is-native-fullscreen" == false)) | length > 1' \
       && yabai -m query --spaces | \
            jq -re 'map(select(."windows" == [] and ."has-focus" == false).index) | reverse | .[] ' | \
            xargs -I % sh -c 'yabai -m space % --destroy'
}

if [ -n "$1" ]; then
  echo $1 $2 $3
  $1 $2 $3
fi
