#!/bin/sh

echo2() {
    local message=$1
    
    ORANGE='\033[1;36m'
    NC='\033[0m' # No Color
    
    echo -e "${ORANGE}${message}${NC}"
}