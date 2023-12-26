#!/usr/bin/env bash

assert() {
    if [ $# -ne 3 ]; then
        echo 'Usage: assert args expected_exit_status expected_errorname'
        exit 1
    fi

    expected_exit_status="$1"
    expected_errorname="$2"
    args="$3"

    stdout=$(powershell.exe -C "..\dist\tablestyle.exe $args" 2>&1)
    actual_exit_status=$?
    actual_errorname=$(echo "$stdout" | grep -oE '^.+Error')

    if [ -n "$actual_errorname" ] && [ $(echo "$stdout" | wc -l) -gt 1 ]; then
        echo ".\tablestyle.exe $args => FAIL: exception handling not implemented"
        exit 1
    fi

    if [ "$actual_exit_status" = "$expected_exit_status" ] && [ "$actual_errorname" = "$actual_errorname" ]; then
        echo ".\tablestyle.exe $args => PASS"
    elif [ "$actual_exit_status" = "$expected_exit_status" ]; then
        echo ".\tablestyle.exe $args => FAIL: $expected_errorname expected as an exit status, but got $actual_errorname"
        exit 1
    else
        echo ".\tablestyle.exe $args => FAIL: $expected_exit_status expected as an error, but got $actual_exit_status"
        exit 1
    fi
}


cd test_files

# pass
assert 0 "" "get input.docx" 
assert 0 "" "apply -o output.docx input.docx" 
assert 0 "" "apply -f config.jsonl -o output.docx input.docx" 
assert 0 "" "apply -n 'My Table' -o output.docx input.docx" 

# help
assert 0 "" "-h"
assert 0 "" "get -h"
assert 0 "" "apply -h"

# invalid choice 
assert 1 "" "input.docx"

# required args
assert 1 "" "get"
assert 1 "" "apply"

# mutually exclusive args
assert 1 "" "apply -n 'My Table' -f config.jsonl -o output.docx input.docx"

# error handled
assert 1 AttributeError ""
assert 1 FileNotFoundError "apply -f filenotexist.jsonl -o output.docx input.docx"
assert 1 PackageNotFoundError "get filenotexist.docx"
assert 1 PackageNotFoundError "apply -o output.docx filenotexist.docx"
assert 1 PackageNotFoundError "get filenotexist.txt"
assert 1 PackageNotFoundError "apply -o output.docx formatnotdocx.docx"
assert 1 PackageNotFoundError "apply -f config.jsonl -o output.docx formatnotdocx.docx"
assert 1 PackageNotFoundError "apply -n 'My Table' -o output.docx formatnotdocx.docx"
assert 1 KeyError "apply -o notdocx.doc input.docx"
assert 1 KeyError "apply -f config.jsonl -o notdocx.doc input.docx"
assert 1 KeyError "apply -n 'My Table' -o notdocx.doc input.docx"
assert 1 KeyError "apply -o notdocx input.docx"
assert 1 KeyError "apply -f config.jsonl -o notdocx input.docx"
assert 1 KeyError "apply -n 'My Table' -o notdocx input.docx"
assert 1 KeyError "apply -f wrongkey.jsonl -o output.docx input.docx"
assert 1 KeyError "apply -f stylenotexist.jsonl -o output.docx input.docx"
assert 1 KeyError "apply -n 'my table' -o output.docx input.docx"
assert 1 JSONDecodeError "apply -f badjson.jsonl -o output.docx input.docx"
assert 1 IndexError "apply -f excesslines.jsonl -o output.docx input.docx"


