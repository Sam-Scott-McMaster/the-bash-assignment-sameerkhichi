#!/bin/bash

# Clear previous results
> test_results.txt

# Function to test a specific input scenario
run_test() {
    local input="$1"
    local expected_output="$2"

    # Run the command and capture the output
    output=$(echo "$input" | ./bn)  # Replace ./bn with the actual command to run your utility
    echo "$output" >> test_results.txt  # Append the output to the results file

    # Check if the output matches the expected output
    if [[ "$output" == *"$expected_output"* ]]; then
        echo "Test passed for input '$input'" >> test_results.txt
    else
        echo "Test failed for input '$input': Expected '$expected_output', got '$output'" >> test_results.txt
    fi
}

# Run your tests
echo "Running tests..." >> test_results.txt

# Example test cases (modify as needed)
run_test "bn 1969 M" "1969: sam ranked 318 out of 5042 male names."
run_test "bn 1969 b" "1969: sam ranked 318 out of 5042 male names."
run_test "bn 2000 F" "2000: lucy ranked 324 out of 17658 female names."
run_test "bn 1111" "Error: No data for 1111."  # Expected error message
run_test "bn 1111 X" "Badly formatted assigned gender: x"  # Expected error message
run_test "bn 2000 F" "lucy not found among male names."  # Expected error message

echo "Tests completed. Check test_results.txt for details."

