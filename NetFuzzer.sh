#!/bin/bash

# ANSI color codes
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
RESET='\033[0m'

# ASCII art
echo -e "${RED}"
cat << "EOF"

                       __  ____                         
           ____  ___  / /_/ __/_  __________  ___  _____
          / __ \/ _ \/ __/ /_/ / / /_  /_  / / _ \/ ___/
         / / / /  __/ /_/ __/ /_/ / / /_/ /_/  __/ /    
        /_/ /_/\___/\__/_/  \__,_/ /___/___/\___/_/   v1.2.0
        
                                       Made by Satya Prakash (0xKayala)                 

EOF
echo -e "${RESET}"

# Help menu
display_help() {
    cat << EOF
NetFuzzer: A comprehensive network security assessment tool for internal/external networks including firewalls, routers, switches, Active Directory, SMBs, etc.

Usage: $0 [options]

Options:
  -h, --help              Display this help menu
  -t, --target <target>   Target IP address, range, or hostname
  -f, --filename <file>   File containing a list of targets (one per line)
  -s, --scan <scan_type>  Specify the type of scan to run:
                          1. live_hosts       - Discover live hosts
                          2. reverse_dns      - Perform reverse DNS lookup
                          3. port_scan        - Scan ports and detect versions
                          4. os_detection     - Detect OS
                          5. traceroute       - Perform traceroute
                          6. ssl_enum         - Perform SSL enumeration
                          7. smb_enum         - Perform SMB enumeration
                          8. rpc_enum         - Perform RPC enumeration
                          9. vuln_scan        - Perform vulnerability scan
                         10. nuclei_scan      - Perform Nuclei scan
  -o, --output <dir>      Specify output directory (default: ./results)
EOF
    exit 0
}

# Dependency Checker
check_dependencies() {
    dependencies=("nuclei" "httpx" "nmap" "smbclient" "rpcclient" "go" "git")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "${YELLOW}Installing missing dependency: $dep...${RESET}"
            case $dep in
                nuclei|httpx)
                    go install -v github.com/projectdiscovery/$dep/cmd/$dep@latest
                    ;;
                nmap)
                    sudo apt-get update && sudo apt-get install -y nmap
                    ;;
                smbclient|rpcclient)
                    sudo apt-get install -y smbclient
                    ;;
                go)
                    sudo apt-get install -y golang
                    ;;
                git)
                    sudo apt-get install -y git
                    ;;
            esac
        fi
    done

    # Clone/update nuclei templates
    local nuclei_dir="$HOME/nuclei-templates"
    if [ ! -d "$nuclei_dir" ]; then
        echo -e "${YELLOW}Cloning Nuclei templates...${RESET}"
        git clone https://github.com/projectdiscovery/nuclei-templates.git "$nuclei_dir"
    else
        echo -e "${GREEN}Updating Nuclei templates...${RESET}"
        git -C "$nuclei_dir" pull
    fi
}

# Initialize script
check_dependencies

# Parse command line arguments
output_dir="./results"
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            display_help
            ;;
        -t|--target)
            target="$2"
            shift; shift
            ;;
        -f|--filename)
            filename="$2"
            shift; shift
            ;;
        -s|--scan)
            scan_type="$2"
            shift; shift
            ;;
        -o|--output)
            output_dir="$2"
            shift; shift
            ;;
        *)
            echo -e "${RED}Unknown option: $key${RESET}"
            display_help
            ;;
    esac
done

# Argument validation
if [ -z "$target" ] && [ -z "$filename" ]; then
    echo -e "${RED}Error: You must provide a target (-t) or a filename (-f).${RESET}"
    display_help
fi

if [ -z "$scan_type" ]; then
    echo -e "${RED}Error: You must specify a scan type (-s).${RESET}"
    display_help
fi

# Ensure output directory exists
mkdir -p "$output_dir"

# Define scan types
declare -A scans=(
    [1]="live_hosts"
    [2]="reverse_dns"
    [3]="port_scan"
    [4]="os_detection"
    [5]="traceroute"
    [6]="ssl_enum"
    [7]="smb_enum"
    [8]="rpc_enum"
    [9]="vuln_scan"
    [10]="nuclei_scan"
)

scan_name=${scans[$scan_type]}
if [ -z "$scan_name" ]; then
    echo -e "${RED}Error: Invalid scan type.${RESET}"
    display_help
fi

# Execute scans
run_scan() {
    local target_input=$1
    local output_file="$output_dir/${scan_name}_${target_input//[:\//]/_}.txt"

    case $scan_name in
        live_hosts)
            nmap -sn "$target_input" -oN "$output_file"
            ;;
        reverse_dns)
            nmap -R -sL "$target_input" -oN "$output_file"
            ;;
        port_scan)
            nmap -Pn -sC -sV -T4 -A -O "$target_input" -oN "$output_file"
            ;;
        os_detection)
            nmap -O "$target_input" -oN "$output_file"
            ;;
        traceroute)
            nmap --traceroute "$target_input" -oN "$output_file"
            ;;
        ssl_enum)
            sudo nmap -Pn -sV --script ssl-enum-ciphers -p 443 "$target_input" -oN "$output_file"
            ;;
        smb_enum)
            smbclient -L "\\$target_input\\" > "$output_file"
            ;;
        rpc_enum)
            rpcclient -U "" -N "$target_input" > "$output_file"
            ;;
        vuln_scan)
            sudo nmap -Pn --script vuln -sV "$target_input" -oN "$output_file"
            ;;
        nuclei_scan)
            nuclei -u "$target_input" -t "$HOME/nuclei-templates" -es info -rl 5 -o "$output_file"
            ;;
    esac

    echo -e "${GREEN}Results saved to $output_file${RESET}"
}

# Process targets
if [ -n "$target" ]; then
    run_scan "$target"
elif [ -n "$filename" ]; then
    while IFS= read -r line; do
        run_scan "$line"
    done < <(sort -u "$filename")
fi

echo -e "${GREEN}Network Security Assessment completed. Happy Scanning!${RESET}"
