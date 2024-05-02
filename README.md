# NetFuzzer
NetFuzzer is a comprehensive network security assessment tool designed for internal and external networks. It includes features such as host discovery, port scanning, OS detection, SSL enumeration, and SMB and RPC enumeration. This tool uses Nmap, smbclient, rpcclient, and other utilities, with the potential for additional features in the future. NetFuzzer aims to simplify network security assessments and welcomes collaborations and contributions to enhance its functionality and usability.

**Important:** Make sure the tools `Nmap`, `smbclient` & `rpcclient` are installed on your machine and executing correctly to use the `NetFuzzer` without any issues.

### Tools included:
[Nmap]() `sudo apt -y install nmap`<br><br>
[smbclient/rpcclient]() `sudo apt -y install smbclient`

## Screenshot
![image](https://github.com/0xKayala/NetFuzzer/assets/16838353/8cd3a6d5-dff1-4f93-a373-bd9e689055c8)

## Output
![image](https://github.com/0xKayala/NetFuzzer/assets/16838353/297e0cd2-faa9-48c3-b6e4-56a7fec4dfb5)
![image](https://github.com/0xKayala/NetFuzzer/assets/16838353/63fbbd71-f20b-4d50-b620-b438f9e49a11)
![image](https://github.com/0xKayala/NetFuzzer/assets/16838353/eec79e73-16bf-480a-b70e-afa3059a1421)
![image](https://github.com/0xKayala/NetFuzzer/assets/16838353/59825ca9-57c1-490e-a024-f509b93ec0a2)

## Usage

```sh
netfuzzer -h
```

This will display help for the tool. Here are the options it supports.

```console
NetFuzzer is a comprehensive network security assessment tool for internal/external networks including firewalls, routers, switches, Active Directory, SMBs, etc.


Usage: /usr/bin/netfuzzer [options]


Options:
  -h, --help              Display help information
  -t, --target <target>   Target IP address, range, or hostname
  -f, --filename <file>   File containing list of targets (one per line)
  -s, --scan <scan_type>  Specify the type of scan to run:
                          1. live_hosts - Discover live hosts
                          2. reverse_dns - Perform reverse DNS lookup
                          3. port_scan - Scan ports and detect versions
                          4. os_detection - Detect OS
                          5. traceroute - Perform traceroute
                          6. ssl_enum - Perform SSL enumeration
                          7. smb_enum - Perform SMB enumeration
                          8. rpc_enum - Perform RPC enumeration
                          9. vuln_scan - Perform vulnerability scan"
                          10. nuclei_scan - Perform Nuclei scan"
```  

## Installation:

To install `NetFuzzer`, follow these steps:

```
git clone https://github.com/0xKayala/NetFuzzer.git && cd NetFuzzer && sudo chmod +x install.sh && ./install.sh && netfuzzer -h && cd ..
```
