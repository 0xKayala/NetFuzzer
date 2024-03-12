#!/bin/bash

# ANSI color codes
RED='\033[91m'
RESET='\033[0m'

# ASCII art
echo -e "${RED}"
cat << "EOF"

               __  ____                         
   ____  ___  / /_/ __/_  __________  ___  _____
  / __ \/ _ \/ __/ /_/ / / /_  /_  / / _ \/ ___/
 / / / /  __/ /_/ __/ /_/ / / /_/ /_/  __/ /    
/_/ /_/\___/\__/_/  \__,_/ /___/___/\___/_/   v1.0.0

                       Made by Satya Prakash (0xKayala)                

EOF
echo -e "${RESET}"                                                      

# Help menu
display_help() {
    echo -e "NetFuzzer is a comprehensive network security assessment tool for internal/external networks including firewalls, routers, switches, Active Directory, SMBs, etc.\n\n"
    echo -e "Usage: $0 [options]\n\n"
    echo "Options:"
    echo "  -h, --help              Display help information"
    echo "  -t, --target <target>   Target IP address, range, or hostname"
    echo "  -f, --filename <file>   File containing list of targets (one per line)"
    echo "  -s, --scan <scan_type>  Specify the type of scan to run:"
    echo "                          1. live_hosts - Discover live hosts"
    echo "                          2. reverse_dns - Perform reverse DNS lookup"
    echo "                          3. port_scan - Scan ports and detect versions"
    echo "                          4. os_detection - Detect OS"
    echo "                          5. traceroute - Perform traceroute"
    echo "                          6. ssl_enum - Perform SSL enumeration"
    echo "                          7. smb_enum - Perform SMB enumeration"
    echo "                          8. rpc_enum - Perform RPC enumeration"
    exit 0
}

# Check if Nmap is installed, if not, install it
if ! command -v nmap &> /dev/null; then
    echo "Installing Nmap..."
    sudo apt-get update
    sudo apt-get install -y nmap
fi

# Check if SMB Client is installed, if not, install it
if ! command -v smbclient &> /dev/null; then
    echo "Installing smbclient..."
    sudo apt -y install smbclient
fi

# Check if RPC Client is installed, if not, install it
if ! command -v rpcclient &> /dev/null; then
    echo "Installing smbclient..."
    sudo apt -y install smbclient
fi

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -h|--help)
            display_help
            ;;
        -t|--target)
            target="$2"
            shift
            shift
            ;;
        -f|--file)
            filename="$2"
            shift
            shift
            ;;
        -s|--scan)
            scan_type="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Ask the user to enter the target IP Address or Hostname
if [ -z "$target" ] && [ -z "$filename" ]; then
    echo "Please provide a target IP address with -t or a file with -f option."
    display_help
fi

# Run the specified scan
case $scan_type in
    live_hosts)
        echo "Discovering live hosts..."
        sudo nmap -sn "$target" -oG live_hosts.txt
        ;;
    reverse_dns)
        echo "Performing reverse DNS lookup..."
        sudo nmap -R -sL "$target" -oG reverse_dns.txt
        ;;
    port_scan)
        echo "Scanning ports and detecting versions..."
        sudo nmap -Pn -sC -sV -T4 -A -O -p- "$target" -oN port_scan.txt
        ;;
    os_detection)
        echo "Detecting OS..."
        sudo nmap -O "$target" -oG os_detection.txt
        ;;
    traceroute)
        echo "Performing traceroute..."
        sudo nmap --traceroute "$target" -oG traceroute.txt
        ;;
    ssl_enum)
        echo "Performing SSL Enumeration..."
        sudo nmap -Pn -sV --script ssl-enum-ciphers -p 443 "$target" -oG ssl_enum.txt
        ;;
    smb_enum)
        echo "Performing SMB enumeration using smbclient..."
        smbclient -L "\\\\$target\\\\" -N
        ;;
    rpc_enum)
        echo "Performing RPC enumeration using rpcclient..."
        rpcclient -U "" -N "$target"
        ;;
    *)
        echo "Invalid scan type. Please specify a valid scan type."
        display_help
        ;;
esac

echo "Network Security Assessment is completed - Happy Fuzzing"
