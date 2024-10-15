#!/bin/bash

#Displays the usage of the program
usage() {
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>" >&2
    exit 1
}

#Displays information when the help flag is used
help() {
    echo "bn Utility - Baby Names Rank Finder"
    echo "Version 1.0"
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

    # Logic to find and return the rank for the given name, year, and gender
    #need to implement the logic to read from the database of names 
    #need to implement the logic that returns the ranking
    echo "Rank for $name in $year for gender $gender: "
}

if [[ $# == 0 ]]; 
then

    help

elif [[ $# != 2 ]]; 
then

    usage

fi

year=$1
gender=$2

#need to implement the checks for valid input

#reading the names from stdin until EOF
while read name; 
do
    #need to implement if the name is still valid
    rank "$name" "$year" "$gender"
done

