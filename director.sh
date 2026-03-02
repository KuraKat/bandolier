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
run_level 3 "cat \$(find inhere -name '.*' -type f)"

# Level 4 -> 5
run_level 4 "cat \$(file inhere/* | grep 'text' | cut -d ':' -f 1)"

# Level 5 -> 6
run_level 5 "cat \$(find inhere -type f -size 1033c ! -executable)"

# Level 6 -> 7
run_level 6 "cat \$(find / -user bandit7 -group bandit6 -size 33c 2> /dev/null)"

# Level 7 -> 8
run_level 7 "grep \"millionth\" data.txt"

# Level 8 -> 9
run_level 8 "cat data.txt | sort | uniq -u"

# Level 9 -> 10
run_level 9 "strings data.txt | grep 'grep' | awk \'{print \$NF}\'"
