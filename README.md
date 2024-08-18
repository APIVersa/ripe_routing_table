# Ripe Routing Table Generator
A Script to Get a Full Routing Table From Ripe Sources

This script will download the latest BGP routing table from RIPE NCC RIS Service (https://www.ripe.net/analyse/internet-measurements/routing-information-service-ris/). This table is pretty much guaranteed to have 99%+ of the global routing table in it, as it uses several bgp sessions with thousands of peers across to world to compile it, giving a pretty accurate image of the global routing table from multiple perspectives including all Tier 1 networks. The RIPE NCC is also peered in serveral Internet Exchanges (IXPs), which gives a look into prefixes that aren't even announced upstream to global Tier 1 networks such as hobby networks and so on.

The script will:
- Download the Latest Data
- Convert the data to text format
- Create a script to import it into the routing table
- Import it into the routing table
- 
Requires having bgpdump installed (apt install bgpdump) and gunzip (apt install gunzip)
