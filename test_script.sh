#!/bin/bash
#
# A simple framework for testing the bn scripts
#
# Returns the number of failed test cases.
#
# Format of a test:
#     test 'command' expected_return_value 'stdin text' 'expected stdout' 'expected stderr'
#
# Sam Scott, McMaster University, 2024

# GLOBALS: tc = test case number, fails = number of failed cases
declare -i tc=0
declare -i fails=0

############################################
# Run a single test. Runs a given command 3 times
# to check the return value, stdout, and stderr
#
# GLOBALS: tc, fails
# PARAMS: $1 = command
#         $2 = expected return value
#         $3 = standard input text to send
#         $4 = expected stdout
#         $5 = expected stderr
# RETURNS: 0 = success, 1 = bad return, 
#          2 = bad stdout, 3 = bad stderr
############################################
test() {
    tc=tc+1

    local COMMAND=$1
    local RETURN=$2
    local STDIN=$3
    local STDOUT=$4
    local STDERR=$5

    # CHECK RETURN VALUE
    $COMMAND <<< "$STDIN" >/dev/null 2>/dev/null
    local A_RETURN=$?

    if [[ "$A_RETURN" != "$RETURN" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected Return: $RETURN"
        echo "   Actual Return: $A_RETURN"
        fails=$fails+1
        return 1
    fi

    # CHECK STDOUT
    local A_STDOUT=$($COMMAND <<< "$STDIN" 2>/dev/null)

    if [[ "$STDOUT" != "$A_STDOUT" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDOUT: $STDOUT"
        echo "   Actual STDOUT: $A_STDOUT"
        fails=$fails+1
        return 2
    fi
    
    # CHECK STDERR
    local A_STDERR=$($COMMAND <<< "$STDIN" 2>&1 >/dev/null)

    if [[ "$STDERR" != "$A_STDERR" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDERR: $STDERR"
        echo "   Actual STDERR: $A_STDERR"
        fails=$fails+1
        return 3
    fi
    
    # SUCCESS
    echo "Test $tc Passed"
    return 0
}

##########################################
# RANK FUNCTION
##########################################
rank() {
    local name=$1
    local year=$2
    local gender=$3
    local file="us_baby_names/$year.txt"

    # Check if the data file for the given year exists
    if [[ ! -f "$file" ]]; then
        echo "Error: No data file exists for the selected year $year." >&2
        return 4
    fi

    local rank=0
    local total_names=0
    local found=0

    while IFS= read -r line; do
        total_names=$((total_names + 1))
        # Assuming the file format is "name,rank"
        IFS=',' read -r file_name file_rank <<< "$line"

        if [[ "$file_name" == "$name" ]]; then
            rank=$file_rank
            found=1
            break
        fi
    done < "$file"

    if [[ $found -eq 1 ]]; then
        echo "$year: $name ranked $rank out of $total_names $gender names."
    else
        echo "$year: $name not found among $gender names." >&2
        return 1
    fi
}

##########################################
# TEST CASES
##########################################

# Success cases
test './bn 1969 M' 0 'sam SCOTT Bob' '1969: sam ranked 318 out of 5042 male names.
1969: SCOTT ranked 12 out of 5042 male names.
1969: Bob ranked 380 out of 5042 male names.
1969: lucy not found among male names.' ''

test './bn 1969 b' 0 'sam SCOTT Bob' '1969: sam ranked 318 out of 5042 male names.
1969: sam ranked 5861 out of 8708 female names.
1969: SCOTT ranked 12 out of 5042 male names.
1969: SCOTT ranked 983 out of 8708 female names.
1969: Bob ranked 380 out of 5042 male names.
1969: Bob not found among female names.
1969: lucy not found among male names.
1969: lucy ranked 391 out of 8708 female names.' ''

# Error cases
test './bn 1969 F' 3 'Sam2' '' 'Badly formatted name: Sam2'
test './bn 1111 X' 2 '' '' 'Badly formatted assigned gender: X
bn <year> <assigned gender: f|F|m|M|b|B>'
test './bn 2020 m' 4 '' '' 'Error: No data file exists for the selected year 2020.'

# Return code
exit $fails

