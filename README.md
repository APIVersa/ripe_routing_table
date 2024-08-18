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

The warnings:
- You may wish to remove all default routes from your routing table first if you wish to used rules based routing
- Be sure to specify the currect outbound interface and gateway IPs when prompted - if you do not know them, you can use "ip route" to find the current default route on your system. the IP after "via" is your gateway and the part after "dev" is the interface. for IPv6 gateway, use "ip -6 route" to find the default information there.
- This may take a long time to run, be patient. The global routing table is very large. As of posting this, there are over 1 Million IPv4 routes and almost 250k IPv6 routes to import. The conversion takes a long time from the format that is provided by RIPE to a standard text file. It isn't frozen, just let is keep running.
- A full-table will take up a lot of RAM. Be sure your system can handle it. For a full-table, I highly recommend at least 2GB of RAM. This is in addition to anything else you have running. So for example if you have a system with 4GB RAM and system is currently using 2GB of RAM, you have 2GB for this table to run in.
