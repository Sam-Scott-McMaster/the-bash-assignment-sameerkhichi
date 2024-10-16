#!/bin/bash
#
# A simple framework for testing the bn scripts
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

    #CHECK RETURN VALUE
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

    #CHECK STDOUT
    local A_STDOUT=$($COMMAND <<< "$STDIN" 2>/dev/null)

    if [[ "$STDOUT" != "$A_STDOUT" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDOUT: $STDOUT"
        echo "   Actual STDOUT: $A_STDOUT"
        fails=$fails+1
        return 2
    fi
    
    #CHECK STDERR
    local A_STDERR=$($COMMAND <<< "$STDIN" 2>&1 >/dev/null)

    if [[ "$STDERR" != "$A_STDERR" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDERR: $STDERR"
        echo "   Actual STDERR: $A_STDERR"
        fails=$fails+1
        return 3
    fi
    
    #SUCCESS
    echo "Test $tc Passed"
    return 0
}

#Valid Name with Lowercase Letters
test './bn 2022 f' 0 'olivia' '2022: Olivia ranked 2 out of 17660 female names.' ''

#Valid Name with Uppercase Letters
test './bn 2022 m' 0 'Liam' '2022: Liam ranked 1 out of 14255 male names.' ''

#Name Not Found for Male
test './bn 2022 m' 0 'Zachary' '2022: Zachary not found among male names.' ''

#Name Not Found for Female
test './bn 2022 f' 0 'Charley' '2022: Charley not found among female names.' ''

#entering multiple names with both genders
test './bn 2022 b' 0 'Emma Liam' '2022: Emma ranked 1 out of 17660 female names.
2022: Liam ranked 1 out of 14255 male names.' ''

#Invalid Year Format
test './bn 202A m' 2 '' '' 'Error: Year must be a four-digit integer.'

#Year Out of Range
test './bn 1800 m' 4 'John' '' 'Error: No data file exists for the selected year 1800.'

#blank name
test './bn 2022 b' 0 '' '' 'Error: Name is invalid. Only alphabetical characters are allowed.'

#Name with Special Characters
test './bn 2022 f' 3 'Olivia@' '' 'Error: Name '\''Olivia@'\'' is invalid. Only alphabetical characters are allowed.'

#Non-Existent Gender Input
test './bn 2022 z' 2 '' '' 'Badly formatted assigned gender: z
bn <year> <assigned gender: f|F|m|M|b|B>'

#return code
exit $fails
