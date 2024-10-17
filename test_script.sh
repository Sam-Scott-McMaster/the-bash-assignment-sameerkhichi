#!/bin/bash
#
# A simple framework for testing the bn.sh script
#
# Returns the number of failed test cases.
#
# Format of a test:
#     test 'command' expected_return_value 'stdin text' 'expected stdout' 'expected stderr'
#
# Some example test cases are given. You should add more test cases.
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

    # CHECK STDOUT, filtering out the "Enter names" prompt
    local A_STDOUT=$($COMMAND <<< "$STDIN" 2>/dev/null | grep -v "Enter names or press Ctrl+D to exit:")

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
# TEST CASES
##########################################

# 1. Valid usage: Male name for 2022, expecting return code 0
test './bn.sh 2022 m' 0 'James' '2022: James ranked 4 out of 14255 male names.' ''

# 2. Valid usage: Female name for 2022, expecting return code 0
test './bn.sh 2022 f' 0 'Olivia' '2022: Olivia ranked 1 out of 17660 female names.' ''

# 3. Valid usage: Both genders for 1969, expecting return code 0
test './bn.sh 1969 b' 0 'sam' '1969: sam ranked 5861 out of 8708 female names.
1969: sam ranked 318 out of 5042 male names.' ''

# 4. Invalid assigned gender: Expecting return code 2 (for invalid gender format)
test './bn.sh 2022 z' 2 'Sam' '' 'Error: Assigned gender must be f|F|m|M|b|B.
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'

# 5. Incorrect year format: Expecting return code 2 (invalid year format)
test './bn.sh 202A m' 2 '' '' 'Error: Year must be a four-digit integer.
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'

# 6. Missing data file: Expecting return code 4 (file not found for the year)
test './bn.sh 1800 m' 4 '' '' 'Error: No data file exists for the selected year 1800.'

# 7. Invalid name exits with code 3
test './bn.sh 2022 b' 3 'Sam123' '' 'Error: Name '\''Sam123'\'' is invalid. Only alphabetical characters are allowed.'

# 8. No names found in the dataset for given name and gender: Valid case with no output for names.
test './bn.sh 2022 f' 0 'NotAName' '2022: NotAName not found among female names.' ''

# 9. Valid usage: Expect return code 0 for valid input.
test './bn.sh 1969 f' 0 'sam' '1969: sam ranked 5861 out of 8708 female names.' ''

# Return final number of failures
exit $fails
