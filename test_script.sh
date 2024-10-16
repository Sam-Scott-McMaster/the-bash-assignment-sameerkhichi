#!/bin/bash
#
# A simple framework for testing the bn.sh scripts
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

#valid name with gender as both
test './bn.sh 2023 b' 0 'Avery' '2023: Avery ranked 407 out of 14635 male names.
2023: Avery ranked 310 out of 18040 female names.' ''

#Valid name with gender as female
test './bn.sh 2022 m' 0 'Olivia' '2022: Olivia ranked 2 out of 17660 female names.' ''

#valid name with gender as male
test './bn.sh 2022 f' 0 'James' '2022: James ranked 1 out of 14255 male names.' ''

#Valid name for both genders name as ALex
test './bn.sh 2022 b' 0 'Alex' '2022: Alex ranked 55 out of 14255 male names.
2022: Alex ranked 154 out of 17660 female names.' ''

#invalid gender character
test './bn.sh 2022 z' 2 '' '' 'Badly formatted assigned gender: z
bn <year> <assigned gender: f|F|m|M|b|B>'

#invalid name format
test './bn.sh 2022 B' 3 '123' '' 'Error: Name '\''123'\'' is invalid. Only alphabetical characters are allowed.'

#invalid name with no valid file
test './bn.sh 2022 F' 4 'Liam' '' 'Error: No data file exists for the selected year 2022.'

# return code
exit $fails
