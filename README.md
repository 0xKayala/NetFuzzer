# NetFuzzer
NetFuzzer is a comprehensive network security assessment tool designed for internal and external networks. It includes features such as host discovery, port scanning, OS detection, SSL enumeration, and SMB and RPC enumeration. This tool uses Nmap, smbclient, rpcclient, and other utilities, with the potential for additional features in the future. NetFuzzer aims to simplify network security assessments and welcomes collaborations and contributions to enhance its functionality and usability.

**Important:** Make sure the tools `Nmap`, `smbclient` & `rpcclient` are installed on your machine and executing correctly to use the `NetFuzzer` without any issues.

### Tools included:
[Nmap]() ``<br><br>
[smbclient/rpcclient]() ``

### Templates:
[Fuzzing Templates](https://github.com/0xKayala/fuzzing-templates) `git clone https://github.com/0xKayala/fuzzing-templates.git`

## Screenshot
![image](https://github.com/0xKayala/NetFuzzer/assets/16838353/07e81a29-ad7c-4e07-b3ab-3355be8ac5be)


## Output
![image](https://github.com/0xKayala/NucleiFuzzer/assets/16838353/16c8eac9-6924-4196-ae71-70e98057e47c)

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
```  

## Installation:

To install `NetFuzzer`, follow these steps:

```
git clone https://github.com/0xKayala/NetFuzzer.git
cd NetFuzzer
sudo chmod +x install.sh
./install.sh
nf -h
```
