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
    >&2 echo "                          9. vuln_scan - Perform vulnerability scan"
    >&2 echo "                          10. nuclei_scan - Perform Nuclei scan"
    exit 0
}

# Get the current user's home directory
home_dir=$(eval echo ~"$USER")

# Check if nuclei-templates are already cloned.
if [ ! -d "$home_dir/nuclei-templates" ]; then
    echo "Cloning nuclei-templates..."
    git clone https://github.com/projectdiscovery/nuclei-templates.git "$home_dir/nuclei-templates"
fi

# Check if nuclei is installed, if not, install it
if ! command -v nuclei &> /dev/null; then
    echo "Installing Nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
fi

# Check if httpx is installed, if not, install it
if ! command -v httpx &> /dev/null; then
    echo "Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
fi

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
        9) scan_type="vuln_scan";;
        10) scan_type="nuclei_scan";;
        *) echo "Invalid scan type. Please specify a valid scan type."
           display_help
           ;;
    esac
fi

# Run the specified scan
if [ -n "$target" ]; then
    case $scan_type in
        live_hosts)
            echo "Discovering live hosts of $target"
            sudo nmap -sn "$target" -oN live_hosts.txt
            ;;
        reverse_dns)
            echo "Performing reverse DNS lookup on $target"
            sudo nmap -R -sL "$target" -oN reverse_dns.txt
            ;;
        port_scan)
            echo "Scanning ports and detecting versions of $target"
            sudo nmap -Pn -sC -sV -T4 -A -O -p- "$target" -oN port_scan.txt
            ;;
        os_detection)
            echo "Detecting OS of $target"
            sudo nmap -O "$target" -oN os_detection.txt
            ;;
        traceroute)
            echo "Performing traceroute on $target"
            sudo nmap --traceroute "$target" -oN traceroute.txt
            ;;
        ssl_enum)
            echo "Performing SSL Enumeration on $target"
            sudo nmap -Pn -sV --script ssl-enum-ciphers -p 443 "$target" -oN ssl_enum.txt
            ;;
        smb_enum)
            echo "Performing SMB enumeration using smbclient on $target"
            smbclient -L "\\\\$target\\\\" -N
            ;;
        rpc_enum)
            echo "Performing RPC enumeration using rpcclient on $target"
            rpcclient -U "" -N "$target"
            ;;
        vuln_scan)
            echo "Performing vulnerability scan using Nmap on $target"
            sudo nmap -Pn --script vuln -sV "$target" -oN vuln_scan.txt
            ;;
        nuclei_scan)
            echo "Performing Nuclei Scan on $target"
            nuclei -u "$target" -t "$home_dir/nuclei-templates" -rl 05 -o "nuclei_scan.txt"
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
            echo "Discovering live hosts of $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo nmap -sn {} -oN live_hosts.txt
            ;;
        reverse_dns)
            echo "Performing reverse DNS lookup on $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo nmap -R -sL {} -oN reverse_dns.txt
            ;;
        port_scan)
            echo "Scanning ports and detecting versions of $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo nmap -Pn -sC -sV -T4 -A -O -p- {} -oN port_scan.txt
            ;;
        os_detection)
            echo "Detecting OS of $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo nmap -O {} -oN os_detection.txt
            ;;
        traceroute)
            echo "Performing traceroute on $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo nmap --traceroute {} -oN traceroute.txt
            ;;
        ssl_enum)
            echo "Performing SSL Enumeration on $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo nmap -Pn -sV --script ssl-enum-ciphers -p 443 {} -oN ssl_enum.txt
            ;;
        smb_enum)
            echo "Performing SMB enumeration using smbclient on $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} smbclient -L "\\\\{}\\\\" -N
            ;;
        rpc_enum)
            echo "Performing RPC enumeration using rpcclient on $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} rpcclient -U "" -N {}
            ;;
        vuln_scan)
            echo "Performing vulnerability scan using Nmap on $filename"
            sort "$filename" | uniq | tee "$filename" | xargs -P10 -I{} sudo nmap -Pn --script vuln -sV {} -oN vuln_scan.txt
            ;;
        nuclei_scan)
            echo "Performing Nuclei Scan on $filename"
            nuclei -l "$filename" -t "$home_dir/nuclei-templates" -rl 05 -o "nuclei_scan.txt"
            ;;
        *)
            echo "Invalid scan type. Please specify a valid scan type."
            display_help
            ;;
    esac
fi

# End with a general message as the scan is completed
echo "Network Security Assessment is completed - Happy Fuzzing"
