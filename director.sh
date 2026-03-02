#!/bin/bash

# Define some colors for the "Hacker" look
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# The starting password
CURRENT_PASS="bandit0"

run_level() {
    local level=$1
    local cmd=$2

    echo -e "${CYAN}--------------------------------------------------${NC}"
    echo -e "${YELLOW}[!] TARGETING: BANDIT LEVEL $level${NC}"
    echo -e "${YELLOW}[!] USING PASS: $CURRENT_PASS${NC}"
    echo -e "${CYAN}--------------------------------------------------${NC}"
    sleep 1

    # Run the expect script
    ./performer.exp "bandit$level" "$CURRENT_PASS" "$cmd"

    # Read the password found by the expect script
    if [ -f "last_pass.txt" ]; then
        NEW_PASS=$(cat last_pass.txt)
        if [ -n "$NEW_PASS" ]; then
            echo -e "\n${GREEN}[+] SUCCESS! Password Found: $NEW_PASS${NC}\n"
            CURRENT_PASS=$NEW_PASS
            rm last_pass.txt
        else
            echo -e "\n${RED}[-] FAILED TO FIND PASSWORD${NC}"
            exit 1
        fi
    fi
}

# --- THE SCRIPT SEQUENCE ---

# Level 0 -> 1
run_level 0 "cat readme"

# Level 1 -> 2
run_level 1 "cat ./-"

# Level 2 -> 3
run_level 2 "cat ./--spaces\ in\ this\ filename--"

# Level 3-> 4
run_level 3 "cat ./inhere/...Hiding-From-You"

# Level 4 -> 5
run_level 4 "file ./inhere/* | grep text && cat ./inhere/-file07"

# Level 5 -> 6
run_level 5 "find -size 1033c -not -executable -exec file {} +  -exec cat {} + | tr -d " ""

# Level 6 -> 7

