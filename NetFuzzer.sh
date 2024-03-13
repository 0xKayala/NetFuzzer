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
    >&2 echo -e "NetFuzzer is a comprehensive network security assessment tool for internal/external networks including firewalls, routers, switches, Active Directory, SMBs, etc.\n\n"
    >&2 echo -e "Usage: $0 [options]\n\n"
    >&2 echo "Options:"
    >&2 echo "  -h, --help              Display help information"
    >&2 echo "  -t, --target <target>   Target IP address, range, or hostname"
    >&2 echo "  -f, --filename <file>   File containing list of targets (one per line)"
    >&2 echo "  -s, --scan <scan_type>  Specify the type of scan to run:"
    >&2 echo "                          1. live_hosts - Discover live hosts"
    >&2 echo "                          2. reverse_dns - Perform reverse DNS lookup"
    >&2 echo "                          3. port_scan - Scan ports and detect versions"
    >&2 echo "                          4. os_detection - Detect OS"
    >&2 echo "                          5. traceroute - Perform traceroute"
    >&2 echo "                          6. ssl_enum - Perform SSL enumeration"
    >&2 echo "                          7. smb_enum - Perform SMB enumeration"
    >&2 echo "                          8. rpc_enum - Perform RPC enumeration"
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
    echo "Installing rpcclient..."
    sudo apt -y install smbclient
fi

# Check if smap is installed, if not, install it
if ! command -v smap &> /dev/null; then
    echo "Installing smap..."
    go install -v github.com/s0md3v/smap/cmd/smap@latest
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
        -f|--filename)
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

# Convert numeric scan_type to string
if [[ $scan_type =~ ^[0-9]+$ ]]; then
    case $scan_type in
        1) scan_type="live_hosts";;
        2) scan_type="reverse_dns";;
        3) scan_type="port_scan";;
        4) scan_type="os_detection";;
        5) scan_type="traceroute";;
        6) scan_type="ssl_enum";;
        7) scan_type="smb_enum";;
        8) scan_type="rpc_enum";;
        *) echo "Invalid scan type. Please specify a valid scan type."
           display_help
           ;;
    esac
fi

# Run the specified scan
if [ -n "$target" ]; then
    case $scan_type in
        live_hosts)
            echo "Discovering live hosts..."
            smap -sn "$target" -oN live_hosts.txt | cat live_hosts.txt
            ;;
        reverse_dns)
            echo "Performing reverse DNS lookup..."
            smap -R -sL "$target" -oN reverse_dns.txt | cat reverse_dns.txt
            ;;
        port_scan)
            echo "Scanning ports and detecting versions..."
            sudo smap -Pn -sC -sV -T4 -A -O -p0-65535 "$target" -oN port_scan.txt | cat port_scan.txt
            ;;
        os_detection)
            echo "Detecting OS..."
            smap -O "$target" -oN os_detection.txt | cat os_detection.txt
            ;;
        traceroute)
            echo "Performing traceroute..."
            smap --traceroute "$target" -oN traceroute.txt | cat traceroute.txt
            ;;
        ssl_enum)
            echo "Performing SSL Enumeration..."
            sudo smap -Pn -sV --script ssl-enum-ciphers -p443 "$target" -oN ssl_enum.txt | cat ssl_enum.txt
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
fi

if [ -n "$filename" ]; then
    case $scan_type in
        live_hosts)
            echo "Discovering live hosts..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} smap -sn {} -oN live_hosts.txt | cat live_hosts.txt
            ;;
        reverse_dns)
            echo "Performing reverse DNS lookup..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo smap -R -sL {} -oN reverse_dns.txt | cat reverse_dns.txt
            ;;
        port_scan)
            echo "Scanning ports and detecting versions..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo smap -Pn -sC -sV -T4 -A -O -p0-65535 {} -oN port_scan.txt | cat port_scan.txt
            ;;
        os_detection)
            echo "Detecting OS..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} smap -O {} -oN os_detection.txt | cat os_detection.txt
            ;;
        traceroute)
            echo "Performing traceroute..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} smap --traceroute {} -oN traceroute.txt | cat traceroute.txt
            ;;
        ssl_enum)
            echo "Performing SSL Enumeration..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo smap -Pn -sV --script ssl-enum-ciphers -p443 {} -oN ssl_enum.txt | cat ssl_enum.txt
            ;;
        smb_enum)
            echo "Performing SMB enumeration using smbclient..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} smbclient -L "\\\\{}\\\\" -N
            ;;
        rpc_enum)
            echo "Performing RPC enumeration using rpcclient..."
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} rpcclient -U "" -N {}
            ;;
        *)
            echo "Invalid scan type. Please specify a valid scan type."
            display_help
            ;;
    esac
fi

# End with a general message as the scan is completed
echo "Network Security Assessment is completed - Happy Fuzzing"
