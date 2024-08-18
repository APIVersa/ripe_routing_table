# Ripe Routing Table Generator
A Script to Get a Full Routing Table From Ripe Sources

This script will download the latest Routing Table from Ripe NCC and perform the following on it:
- Extract the data
- Convert it to a text file
- Remove Bogons, Local Addresses, and Private Ranges
- Split that file into ipv4 and ipv6 files
- Prepend and Append every line with the commands to import to 2 tables( Table 144 for IPv4 and table 266 for IPv6)
- Merge the 2 into a single file with .sh extention
- Add #!/bin/bash to the file
- Set the file as executable
- Clear the tables 144 and 266 for import
- Run the script to import the routes to the table

Requires having bgpdump installed (apt install bgpdump) and gunzip (apt install gunzip)
