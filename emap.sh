#!/bin/bash
echo "    ------------------------------------"
echo "    --------------ENUM MAP--------------"
echo "    ------------------------------------"
echo "[+] Starting Preliminary Scan of $1"
SCAN=$(nmap -sT $1 -p- --open |  grep -oP '^\d+')
echo "$SCAN" > $1_ports.txt
SCAN_RDY=$(echo "$SCAN" | sed ':a; N; $!ba; s/\n/,/g')
printf "\n[+] Open TCP ports found for $1:\n\n$SCAN\n\n"
echo "[+] Starting In-depth TCP Scan of $1"
FULL_SCAN=$(nmap -A $1 --reason -p$SCAN_RDY)
echo "$FULL_SCAN" | tee $1_fullscan.txt
echo "$FULL_SCAN" | grep -oP '^\d+/tcp.*' > $1_sumscan.txt 
echo "[+] Thorough Port Scan of $1 has Completed"
echo "[+] ALL TCP PORT SCANNING PROCESSES HAVE COMPLETED"
echo "    ------------------------------------"
echo "[+] Starting TFTP UDP Enum Scan of $1"
TFTP_SCAN=$(nmap -sU -p 69 --script tftp-enum.nse $1) | tee $1_udptftpscan.txt
echo "[+] Starting In-depth UDP Scan of $1 -- This could take a while..."
UDP_SCAN=$(nmap -sUV -T4 -F --version-intensity 0 $1)
echo "$UDP_SCAN" | tee $1_udpfullscan.txt
echo "$UDP_SCAN" | grep -oP '^\d+/tcp.*' > $1_udpsumscan.txt 
echo "$UDP_SCAN" | grep -oP '^\d+' > $1_udpports.txt
echo "[+] UDP Port Scan of $1 has Completed"
echo "    ------------------------------------"
echo "[+] Performing MASSSCAN for Both TCP and UDP Ports. Tun0 is used as interface."
MASS_SCAN=$(masscan -p1-65535,U:1-65535 $1 --rate=1000 -e tun0 -p1-65535,U:1-65535 | tee $1_masscan_all_ports.txt)
echo "    ------------------------------------"
echo "[+] All EMAP Scans have Completed."
echo "    ------------------------------------"
echo "    -----------EMAP COMPLETED-----------"
echo "    ------------------------------------"
