#!/bin/bash

# Name: Sameer Khichi
# MacID: khichis
# Student Number: 400518172

# Displays the usage of the program
usage() {
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>" >&2
    exit 1
}

# Displays information when the help flag is used
help() {
    echo "bn Utility - Baby Names Rank Finder"
    echo "Version 0.2.0"
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

# Essential function to get the rank of the name provided
rank() {
    local name=$1
    local year=$2
    local gender=$3
    local file="us_baby_names/yob$year.txt"
    local gender_pattern=""

    #Determine the gender pattern and the word for the gender output
    
    if [[ "$gender" =~ [fF] ]]; then
        gender_pattern="^[fF]$"
        gender_word="female"
    elif [[ "$gender" =~ [mM] ]]; then
        gender_pattern="^[mM]$"
        gender_word="male"
    elif [[ "$gender" =~ [bB] ]]; then
        gender_pattern="^[fFmM]$"
        gender_word="both"
    fi

    #Variables to track the names found, how many there are, and their rank
    local namefound_male=false
    local namefound_female=false
    local rank_male=0
    local rank_female=0
    local total_names_male=0
    local total_names_female=0

    #Convert the input name to lowercase for comparison
    local name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    #count the amount of males and female names
    while read -r line; 
    do
        gender_in_file=$(echo "$line" | cut -d',' -f2 | tr -d '[:space:]')
        if [[ "$gender_in_file" =~ ^[mM]$ ]]; then
            #for males
            ((total_names_male++))  
        elif [[ "$gender_in_file" =~ ^[fF]$ ]]; then
            #for females
            ((total_names_female++))  
        fi
    done < "$file"

    #finding the rank by going through each line for the names
    while read -r line; 
    do
        #Splitting the lines to get the name and the gender from the file
        name_in_file=$(echo "$line" | cut -d',' -f1)
        gender_in_file=$(echo "$line" | cut -d',' -f2 | tr -d '[:space:]')

        #check the male names
        if [[ "$gender_in_file" =~ ^[mM]$ ]]; then
            ((rank_male++))

            #if the name entered is the same in the file print it rank
            if [[ "$name_lower" == "$(echo "$name_in_file" | tr '[:upper:]' '[:lower:]')" ]]; then

                #Only print rank if the gender matches the search inquiry
                if [[ "$gender" =~ ^[mM]$ || "$gender" =~ ^[bB]$ ]]; then

                    echo "$year: $name ranked $rank_male out of $total_names_male male names."
                    namefound_male=true

                fi
            fi
        fi

        #check the female names
        if [[ "$gender_in_file" =~ ^[fF]$ ]]; then
            ((rank_female++))

            if [[ "$name_lower" == "$(echo "$name_in_file" | tr '[:upper:]' '[:lower:]')" ]]; then

                if [[ "$gender" =~ ^[fF]$ || "$gender" =~ ^[bB]$ ]]; then

                    echo "$year: $name ranked $rank_female out of $total_names_female female names."
                    namefound_female=true
                fi
            fi
        fi

    done < "$file"

    #To handle if the name isnt found for a male if gender given was both
        if [[ "$gender" =~ ^[bB]$ ]]; then
            if [[ $namefound_male == false ]];then
                echo "$year: $name not found among male names."
            fi
        fi

        #To handle if the name isnt found for a female if gender given was both
        if [[ "$gender" =~ ^[bB]$ ]]; then
            if [[ $namefound_female == false ]];then
                echo "$year: $name not found among female names."
            fi
        fi

        #handling if the gender given wasnt both
        if [[ "$gender" =~ ^[fF]$ ]]; then
            if [[ $namefound_female == false ]];then
                echo "$year: $name not found among female names."
            fi
        fi
        
        if [[ "$gender" =~ ^[mM]$ ]]; then
            if [[ $namefound_male == false ]];then
                echo "$year: $name not found among male names."
            fi
        fi

}

# Check for proper command-line arguments
if [[ $# != 2 ]]; 
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

# Check if the file for the specified year exists
if [[ ! -f "us_baby_names/yob$year.txt" ]]; 
then
    echo "Error: No data file exists for the selected year $year." >&2
    exit 4
fi

#keep reading input until EOF
while true; do
    echo "Enter names (or press Ctrl+D to exit):"
    read -r line || break  # Break if EOF 

    #whitespace indicates new name
    for name in $line; do
        # Checking if the name entered is valid (Only alphabetical characters)
        if ! [[ "$name" =~ ^[a-zA-Z]+$ ]]; then
            echo "Error: Name '$name' is invalid. Only alphabetical characters are allowed." >&2
            continue 
        fi

        rank "$name" "$year" "$gender"
    done
done