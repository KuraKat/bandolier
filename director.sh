#!/bin/bash

# --- CONFIGURATION & COLORS ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Default values
START_LEVEL=0
CURRENT_PASS="bandit0"

# --- ARGUMENT PARSING ---
# Usage: ./director.sh -l 5 -p PASSWORD
while getopts "l:p:" opt; do
  case $opt in
    l) START_LEVEL=$OPTARG ;;
    p) CURRENT_PASS=$OPTARG ;;
    *) echo "Usage: $0 -l <level_to_start_at> -p <password_for_that_level>"; exit 1 ;;
  esac
done

# Create password dump
echo "" > bandit_pass.txt

#
# We store the command needed to get the NEXT level's password
# CMDS[0] is the command to run on bandit0 to get bandit1's pass
declare -a CMDS

CMDS[0]="echo -n 'RESULT:'; cat readme"
CMDS[1]="echo -n 'RESULT:'; cat ./-"
CMDS[2]="echo -n 'RESULT:'; cat ./--spaces\ in\ this\ filename--"
CMDS[3]="echo -n 'RESULT:'; cat \$(find inhere -name '.*' -type f)"
CMDS[4]="echo -n 'RESULT:'; cat \$(file inhere/* | grep 'text' | cut -d ':' -f 1)"
CMDS[5]="echo -n 'RESULT:'; cat \$(find inhere -type f -size 1033c ! -executable)"
CMDS[6]="echo -n 'RESULT:'; cat \$(find / -user bandit7 -group bandit6 -size 33c 2>/dev/null)"
CMDS[7]="echo -n 'RESULT:'; grep 'millionth' data.txt | awk '{print \$NF}'"
CMDS[8]="echo -n 'RESULT:'; sort data.txt | uniq -u"
CMDS[9]="echo -n 'RESULT:'; strings data.txt | grep '===' | awk '{print \$NF}'"
CMDS[10]="echo -n 'RESULT:'; base64 -d data.txt | awk '{print \$NF}'"
CMDS[11]="echo -n 'RESULT:'; tr 'A-Za-z' 'N-ZA-Mn-za-m' < data.txt | awk '{print \$NF}'"
CMDS[12]="PAYLOAD:scripts/level12.sh"


# --- THE EXECUTION ---
run_level() {
    local level=$1
    local cmd=$2

    echo -e "${CYAN}--------------------------------------------------${NC}"
    echo -e "${YELLOW}[!] ATTACKING LEVEL: $level -> $((level+1))${NC}"
    echo -e "${CYAN}--------------------------------------------------${NC}"

    # Run the performer script (Expect)
    ./performer.exp "bandit$level" "$CURRENT_PASS" "$cmd"

    # Capture the password for the next level
    if [ -f "last_pass.txt" ]; then
        NEW_PASS=$(cat last_pass.txt)
        if [ -n "$NEW_PASS" ]; then
  	    echo "Password $level - $((level+1))" >> bandit_pass.txt
	    echo "$NEW_PASS" >> bandit_pass.txt
            echo -e "\n${GREEN}[+] SUCCESS! Password for Level $((level+1)): $NEW_PASS${NC}\n"
            CURRENT_PASS=$NEW_PASS
            rm last_pass.txt
            return 0
        fi
    fi
    
    echo -e "\n${RED}[-!] FAILED TO RETRIEVE PASSWORD${NC}"
    exit 1
}

# --- MAIN LOOP ---
echo -e "${GREEN}Starting automation from Level $START_LEVEL...${NC}"

for (( i=$START_LEVEL; i<${#CMDS[@]}; i++ )); do
    RAW_CMD="${CMDS[$i]}"
    FINAL_CMD=""

    if [[ "$RAW_CMD" == PAYLOAD:* ]]; then
	SCRIPT_PATH="${RAW_CMD#PAYLOAD:}"
	echo "$SCRIPT_PATH"
        if [ -f "$SCRIPT_PATH" ]; then
  	    echo -e "${CYAN}[i] Encoding payload: $SCRIPT_PATH${NC}"

	    B64_CONTENT=$(cat "$SCRIPT_PATH" | base64 -w 0)
	    FINAL_CMD="echo "$B64_CONTENT" | base64 -d | bash"
        else
	    echo -e "${RED}[!] Error: Payload file $SCRIPT_PATH not found!${NC}"
	    exit 1
	fi
    else
	FINAL_CMD="$RAW_CMD"
    fi

    echo "$START_LEVEL"
    run_level "$i" "$FINAL_CMD"
    sleep 2 # Just to make it look cool/readable
done

echo -e "${GREEN}Automation complete or reached end of logic table.${NC}"
