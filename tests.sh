#!/bin/bash

#Made by Ron Even

VERSION=1.0

TMP_FILE="./.tmpfile"

DEBUG=0
if [ "$1" == "-d" ]; then
        DEBUG=1
fi

COUNTER=0
FAILED_TESTS=""

print_single_invalid_output()
{
    echo -e "$1\n"
    if [ $DEBUG -eq 1 ]; then
            echo -e "Expected as hex:"
            echo -e "$1" | hexdump -C
            printf "\n"
    fi
}

print_actual_output()
{
    echo -e "Got:\n$1\n"
    if [ $DEBUG -eq 1 ]; then
            echo -e "Got as hex:"
            echo -e "$1" | hexdump -C
            echo -e "\n"
    fi
}

print_error_header_for_command()
{
    echo -e "\t\t❌ FAILED"
    echo -e "$1\n"
}

print_success_header()
{
    echo -e "\t\t✅ PASSED"
}

validate() {
        command="$1"
        COUNTER=$((COUNTER + 1))
        echo "*****************************************"
        printf "$COUNTER"
        eval "$command" > $TMP_FILE 2>&1
        result=$(cat $TMP_FILE)
        rm -f $TMP_FILE

        # Ignore first argument
        shift

        matched=0
        general_error=0

        for arg in "$@"
        do
            expected=`printf "$arg"`

            if [ "$result" == "$expected" ]
            then
                    print_success_header
                    matched=1
            fi
        done

        # If we reached here and matched=0 it means no matches were found. Print details
        if [ $matched -eq 0 -a $general_error -ne 1 ]
        then
            print_error_header_for_command "$command"
            print_actual_output "$result"

            if [ $# -gt 1 ]
            then
                echo -e "Expected (one of the $# following outputs):\n"
                for arg in "$@"
                do
                    expected=`printf "%s" "$arg"`

                    print_single_invalid_output "$expected"

                    if [ "$arg" != "${@: -1}" ]
                    then
                        echo -e "----- OR -----\n"
                    fi
                done
            else
                echo -e "Expected:\n"
                print_single_invalid_output "$expected"
            fi

            FAILED_TESTS+="$COUNTER,"
        fi
}

validate_test_files() {
    REQUIRED_FILES="test_main.c ex1.c"
    NOT_FOUND_REQUIRED_FILES=0
    for required in $REQUIRED_FILES
    do
        found=$(ls | grep -wc "$required")
        if [ $found -eq 0 ]
        then
            echo "❌ couldn't find $required"
            NOT_FOUND_REQUIRED_FILES=$[NOT_FOUND_REQUIRED_FILES + 1]
        fi
    done

    if [ $NOT_FOUND_REQUIRED_FILES -ne 0 ]
    then
        echo "$NOT_FOUND_REQUIRED_FILES files/directories couldn't be found in the tests directory (`pwd`)"
        echo "Please make sure they exist and run tests.sh again"
        exit 1
    fi
}

declare_step() {
    echo "Testing $1..."
}

declare_stage() {
    echo "           Testing $1             "
}

is_big_endian() {
    python3 -c 'import sys;print("1" if sys.byteorder=="big" else "0", end="")'
}

validate_test_files

echo -e "\n\n"

TEST_EXEC="test.out"
rm -rf $TEST_EXEC
gcc ex1.c test_main.c -o $TEST_EXEC
if [ $? -ne 0 ]
then
	echo "❌ Failed compiling test files! Make sure ex1.c and test_main.c files are present in the script directory"
else
	declare_step "Big Endian"
	validate "./$TEST_EXEC --is-big-endian" $(is_big_endian)

	declare_step "Merge bytes"
	validate "./$TEST_EXEC --merge-bytes 89ABCDEF12893456 AB45A2B3AF3F1E67" "89ABCDEFAF3F1E67"
    validate "./$TEST_EXEC --merge-bytes 0000000000000000 76543210ABCDEF19" "00000000ABCDEF19"
    validate "./$TEST_EXEC --merge-bytes ABCABDEBFEBABDCE 1111111111111111" "ABCABDEB11111111"
    validate "./$TEST_EXEC --merge-bytes 1111111111111111 1561561561561561" "1111111161561561"
    validate "./$TEST_EXEC --merge-bytes 5994A123EF548FE4 4821234561234878" "5994A12361234878"
    validate "./$TEST_EXEC --merge-bytes 0000000000000000 0000000000000000" "0000000000000000"
    validate "./$TEST_EXEC --merge-bytes 0F0F0F0F0F0F0F0F F0F0F0F0F0F0F0F0" "0F0F0F0FF0F0F0F0"
    validate "./$TEST_EXEC --merge-bytes F0F0F0F0F0F0F0F0 0F0F0F0F0F0F0F0F" "F0F0F0F00F0F0F0F"
    validate "./$TEST_EXEC --merge-bytes 1000100010001000 0020020020020020" "1000100020020020"

    declare_step "Put byte"
    INPUT="0011223344556677"
    validate "./$TEST_EXEC --put-byte $INPUT EE 0" "EE11223344556677"
    validate "./$TEST_EXEC --put-byte $INPUT EE 1" "00EE223344556677"
    validate "./$TEST_EXEC --put-byte $INPUT EE 2" "0011EE3344556677"
    validate "./$TEST_EXEC --put-byte $INPUT EE 3" "001122EE44556677"
    validate "./$TEST_EXEC --put-byte $INPUT EE 4" "00112233EE556677"
    validate "./$TEST_EXEC --put-byte $INPUT EE 5" "0011223344EE6677"
    validate "./$TEST_EXEC --put-byte $INPUT EE 6" "001122334455EE77"
    validate "./$TEST_EXEC --put-byte $INPUT EE 7" "00112233445566EE"

    INPUT="1100000000000011"
    validate "./$TEST_EXEC --put-byte $INPUT 66 0" "6600000000000011"
    validate "./$TEST_EXEC --put-byte $INPUT 66 1" "1166000000000011"
    validate "./$TEST_EXEC --put-byte $INPUT 66 2" "1100660000000011"
    validate "./$TEST_EXEC --put-byte $INPUT 66 3" "1100006600000011"
    validate "./$TEST_EXEC --put-byte $INPUT 66 4" "1100000066000011"
    validate "./$TEST_EXEC --put-byte $INPUT 66 5" "1100000000660011"
    validate "./$TEST_EXEC --put-byte $INPUT 66 6" "1100000000006611"
    validate "./$TEST_EXEC --put-byte $INPUT 66 7" "1100000000000066"
    
fi


echo ""
echo "************ 📝  SUMMARY  📝 ************"
failed_count=$(echo $FAILED_TESTS | tr -cd ',' | wc -c)
success_count=$((COUNTER-failed_count))
echo "           $success_count/$COUNTER tests passed!"
if [ $success_count -ne $COUNTER ]
then
    echo "Failed tests are:"
    FAILED_TESTS=${FAILED_TESTS%?}
    echo $FAILED_TESTS
    echo "NOTE: Expected and actual results look the same?"
    echo "Maybe there is a hidden character or an excess \n your code prints."
    echo "Run \"$0 -d\" to see the exact ASCII bytes of the expected and actual results"
fi

echo "*****************************************"


echo ""
echo "*****************************************"
echo "**  This script was made by Ron Even   **"
echo "**         script version: $VERSION         **"
echo "*****************************************"