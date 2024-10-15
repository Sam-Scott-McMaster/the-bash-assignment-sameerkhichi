#!/bin/bash

# Name: Sameer Khichi
# MacID: khichis
# Student Number: 400518172

#Displays the usage of the program
usage() {
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>" >&2
    exit 1
}

#Displays information when the help flag is used
help() {
    echo "bn Utility - Baby Names Rank Finder"
    echo "Version 0.1.3"
    echo
    echo "This utility finds the rank of baby names for a given year and gender."
    echo
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>"
    echo
    echo "Arguments:"
    echo "  <year>          Four-digit year."
    echo "  <assigned gender> Assigned gender (f|F|m|M|b|B)."
    exit 0
}

#Essentially gets the rank of the name provided
rank() {
    local name=$1
    local year=$2
    local gender=$3
    local file="us_baby_names/yob$year.txt"

    local gender_pattern=""
    if [[ "$gender" =~ [fF] ]]; then
        gender_pattern="^[fF]$"
    elif [[ "$gender" =~ [mM] ]]; then
        gender_pattern="^[mM]$"
    elif [[ "$gender" =~ [bB] ]]; then
        gender_pattern="^[fFmM]$"
    fi

    #checks to see if the name was found
    local namefound=false

    # Read the file line by line
    while read line; do
        # take out rank, name, and gender from the line
        rank=$(echo "$line" | cut -d',' -f1)
        name_in_file=$(echo "$line" | cut -d',' -f2)
        gender_in_file=$(echo "$line" | cut -d',' -f3)

        #Check to see if the gender and the name match the pattern
        if [[ "$name" == "$name_in_file" && "$gender_in_file" =~ $gender_pattern ]]; then
            echo "$year: $name ranked $rank out of $(wc -l < $file) ${gender_in_file,,} names."
            namefound=true
        fi
    done < "$file"

    #Handles if the name was not found 
    if ! $namefound; then
        if [[ "$gender" =~ [bB] ]]; then
            echo "$year: $name not found among male or female names."
        else
            echo "$year: $name not found among ${gender,,} names."
        fi
    fi
}

if [[ $# == 0 ]]; 
then

    help

elif [[ $1 == "--help" ]]; 
then

    help

elif [[ $# != 2 ]]; 
then

    usage

fi

year=$1
gender=$2

#Checking the years format
if ! [[ "$year" =~ ^[0-9]{4}$ ]]; 
then

    echo "Error: Year must be a four-digit integer." >&2
    usage

fi

#Checking the genders format
if ! [[ "$gender" =~ ^[fFmMbB]$ ]]; 
then

    echo "Error: Assigned gender must be f|F|m|M|b|B." >&2
    usage

fi

#Check if the file for the year specified exists
if [[ ! -f "us_baby_names/yob$year.txt" ]]; 
then

    echo "Error: No data file exists for the selected year $year." >&2
    exit 4

fi

#reading the names from stdin until EOF
while read name; 
do

    #Checking if the name entered in valid (Only alphabetical characters)
    if ! [[ "$name" =~ ^[a-zA-Z]+$ ]]; then
        echo "Error: Name '$name' is invalid. Only alphabetical characters are allowed." >&2
        exit 3
    fi
    rank "$name" "$year" "$gender"

done