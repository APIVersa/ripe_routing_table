# Ripe Routing Table Generator
A Script to Get a Full Routing Table From Ripe Sources

This script will download the latest BGP routing table from RIPE NCC RIS Service (https://www.ripe.net/analyse/internet-measurements/routing-information-service-ris/). This table is pretty much guaranteed to have 99%+ of the global routing table in it, as it uses several bgp sessions with thousands of peers across to world to compile it, giving a pretty accurate image of the global routing table from multiple perspectives including all Tier 1 networks. The RIPE NCC is also peered in serveral Internet Exchanges (IXPs), which gives a look into prefixes that aren't even announced upstream to global Tier 1 networks such as hobby networks and so on.

The script will:
- Download the Latest Data
- Convert the data to text format
- Create a script to import it into the routing table
- Import it into the routing table

What does it require:
- BGPDUMP (apt install bgpdump)
- GUNZIP (apt install gunzip)

Why?
There are many reasons why you would want to generate a global routing table for your own usage.
- In a testing environment to simulate a BGP session from an upstream
- In a real world situation where an Upstream only provides you with a default route but you would like to do advanced rules-based routing
- In a real world situation where an Upstream only provides you with a default route but you have downstreams that would like to have a full routing table
- In a real world situation where you would like to limit access to certain IP addresses on your network by removing the default route and adding only certain routes to your router to allow for filtering to clients on the network (if the gateway can't access it, it's unreachable for the entire network).
