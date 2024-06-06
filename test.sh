#!/bin/bash

# Function to convert RGB to ANSI escape code
rgb_to_ansi() {
  printf "\033[38;2;%d;%d;%dm" "$1" "$2" "$3"
}

# Function to interpolate between two values
interpolate() {
  local start=$1
  local end=$2
  local factor=$3
  echo "$(( start + (end - start) * factor / 100 ))"
}

# Function to apply gradient coloring to ASCII art
apply_gradient() {
  local lines=()
  while IFS= read -r line; do
    lines+=("$line")
  done

  local total_lines=${#lines[@]}
  local start_colors=(255 0 0)    # Red
  local mid_colors=(0 0 255)      # Blue
  local end_colors=(128 0 128)    # Purple

  for i in "${!lines[@]}"; do
    local factor=$(( i * 200 / (total_lines - 1) ))  # factor range: 0 to 200
    local r g b

    if (( factor <= 100 )); then
      r=$(interpolate "${start_colors[0]}" "${mid_colors[0]}" "$factor")
      g=$(interpolate "${start_colors[1]}" "${mid_colors[1]}" "$factor")
      b=$(interpolate "${start_colors[2]}" "${mid_colors[2]}" "$factor")
    else
      factor=$(( factor - 100 ))
      r=$(interpolate "${mid_colors[0]}" "${end_colors[0]}" "$factor")
      g=$(interpolate "${mid_colors[1]}" "${end_colors[1]}" "$factor")
      b=$(interpolate "${mid_colors[2]}" "${end_colors[2]}" "$factor")
    fi

    local color
    color=$(rgb_to_ansi "$r" "$g" "$b")
    echo -e "${color}${lines[i]}\033[0m"
  done
}

# ASCII Art
ascii_art="

                        _____  _                 _                  _     
                       /  ___|| |               | |                | |    
                       \  --. | |_   __ _  _ __ | |_  _ __     ___ | |__  
                        \`--. \| __| / _\` || '__|| __|| '__|   / __|| '_ \ 
                       /\__/ /| |_ | (_| || |   | |_ | |    _ \__ \| | | |
                       \____/  \__| \__,_||_|    \__||_|   (_)|___/|_| |_|



   _____ _             _   _                               _           _              _       _     _   
  / ____| |           | | (_)                             (_)         | |            (_)     | |   | |  
 | (___ | |_ __ _ _ __| |_ _ _ __   __ _   _ __  _ __ ___  _  ___  ___| |_ ___   _ __ _  __ _| |__ | |_ 
  \___ \| __/ _\` | '__| __| | '_ \ / _\` | | '_ \| '__/ _ \| |/ _ \/ __| __/ __| | '__| |/ _\` | '_ \| __|
  ____) | || (_| | |  | |_| | | | | (_| | | |_) | | | (_) | |  __/ (__| |_\__ \ | |  | | (_| | | | | |_ 
 |_____/ \__\__,_|_|   \__|_|_| |_|\__, | | .__/|_|  \___/| |\___|\___|\__|___/ |_|  |_|\__, |_| |_|\__|
                                    __/ | | |            _/ |                            __/ |          
                                   |___/  |_|           |__/                            |___/           


"

about_startr="

Startr is a command line tool that streamlines your project setup, 
ensuring everything is in place so you can focus on development.


- Project Folder Check
    Verifies your project folder is correctly set up.

- Dockerfile Check and Creation
    Ensures a Dockerfile exists in your project folder. 
    If not, we creates one automatically.

  "

# Apply gradient to the ASCII art and display it
echo "$ascii_art" | apply_gradient

# Print the about message
echo -e "$about_startr"


# Set PROJECTPATH to the path of the current directory
PROJECTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set PROJECT to the lowercase version of the name of this directory
PROJECT=$(echo ${PROJECTPATH##*/} | awk '{print tolower($0)}')
# Set FULL_BRANCH to the name of the current Git branch
FULL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
# Set BRANCH to the lowercase version of this name, with everything after the last forward slash removed
BRANCH=${FULL_BRANCH##*/}
# Set TAG to the output of the git describe --always --tag command, which returns a "unique identifier" for the current commit
TAG=$(git describe --always --tag)

# Print the values of the variables
echo -e "${BLUE}PROJECTPATH=${NC}$PROJECTPATH"
echo -e "${BLUE}PROJECT=${NC}$PROJECT"
echo -e "${BLUE}FULL_BRANCH=${NC}$FULL_BRANCH"
echo -e "${BLUE}BRANCH=${NC}$BRANCH"
