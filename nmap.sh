#!/usr/bin/env bash

###############[ NMAP Speeder ]###############
#                                            #
# Paolo Monti - 2022                         #
#                                            #
# E-mail: p.monti@protonmail.com             #
#                                            #
##############################################

# Define ANSI color variables
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
# No color
NC='\033[0m'

# Define some constants
OK=0
ERR_NO_PARAM=1
ERR_NO_ROOT=2
ERR_UNK_OPT=3

# GLOBAL VARIABLE
NO_SCRIPT=''

############### HELPER FUNCTIONS ###############

# Display help
usage()
{
        echo -e "\n${YELLOW}Usage: $(basename $0) domain/IP to scan${NC} [options]\n\nOptions:\n\n\t-ns:\tno script. Nmap will use -sV -O options instead than -A\n"
        [ -n "$1" ] && echo -e "${RED}[-]${NC} $1"
        [ -n "$2" ] && exit $2 || exit $OK
}

# Display informative message
info()
{
        echo -e "${BLUE}[+]${NC} $1"
}

# Perform the scan by nmap
scan()
{
        info "Scanning started at $(date +'%T %F')"
        info "Running the first stage of the network scan: ports detection..."
        local TARGET="$1"
        local PORTS=$(nmap -Pn -sU -sS -T4 -p- --min-rate=1000 "$TARGET" 2>/dev/null| awk -F/ '/^[0-9]/{p=$2~"^tcp"?p"T:"$1",":p"U:"$1","}END{print(substr(p,1,length(p)-1))}')
        local REPORT="nmap-$(date +%F-%T).xml"
        local SCANTYPE='-sU -sS -A'
        [ "$NO_SCRIPT" = 'Y' ] && SCANTYPE='-sU -sS -sV -O'
        info "Running the second stage of the network scan: services, OS detection, etc."
        info "Command line supplied to nmap: $SCANTYPE -p $PORTS $TARGET -oX $REPORT"
        info "The scan result will be saved inside the file $REPORT"
        nmap $SCANTYPE -p "$PORTS" "$TARGET" -oX "$REPORT"
        info "Scanning finished at $(date +'%T %F')"
}

############### MAIN BODY ###############

# Did we get the domain/IP address to scan on command line?
[ $# -lt 1 ] && usage "Error. You need to supply at least one domain/IP address to scan." $ERR_NO_PARAM

# Did we get a "no script (-ns)" option on command line?
if [ -n "$2" ]
then
        [ ${2,} == '-ns' ] && NO_SCRIPT='Y' || usage "Error. Unknown option specified." $ERR_UNK_OPT
fi

# Check if the current account is root
[ $(id -u) == "$OK" ] || usage "Error. You need root privileges to run the scan. Please, run the script with sudo." $ERR_NO_ROOT

scan "$1"
