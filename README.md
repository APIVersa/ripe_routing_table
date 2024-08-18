# Ripe Routing Table Generator
A Script to Get a Full Routing Table From Ripe Sources

This script will download the latest BGP routing table from RIPE NCC RIS Service (https://www.ripe.net/analyse/internet-measurements/routing-information-service-ris/). This table is pretty much guaranteed to have 99%+ of the global routing table in it, as it uses several bgp sessions with thousands of peers across to world to compile it, giving a pretty accurate image of the global routing table from multiple perspectives including all Tier 1 networks. The RIPE NCC is also peered in serveral Internet Exchanges (IXPs), which gives a look into prefixes that aren't even announced upstream to global Tier 1 networks such as hobby networks and so on.

The script will:
- Download the Latest Data
- Convert the data to text format
- Clean up the data and split it into IPv4 + IPv6 lists
- Create 2 scripts to import it into the routing table (ipv4.sh and ipv6.sh)

What you need to do:
- Run the script
- Wait for it to finish
- Run ipv4.sh if you want to import ipv4 table (as root or use sudo)
- Run ipv6.sh if you want to import ipv6 table (as root or use sudo)
- When you run those scripts, it will ask you for interface and gateway information. This script can be re-run for every upstream you have on a different interface if you wish to add routes for them. For example, if you have 2 upstreams, lets just call them upstream 1 and upstream 2. They both only provide default routes, but you'd like to do some rules based routing between the 2. Both are connected to your server over a different interface OR (1 or both) are via VXLAN, GRE, Wireguard, Etc. giving them their own interface names. In this case you could run the same ipv4.sh or ipv6.sh 2 times, specify the interface and gateway for upstream 1 the first time and upstream 2 the second time.

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
- You may wish to remove all default routes from your routing table first if you wish to use rules based routing
- Be sure to specify the currect outbound interface and gateway IPs when prompted - if you do not know them, you can use "ip route" to find the current default route on your system. the IP after "via" is your gateway and the part after "dev" is the interface. for IPv6 gateway, use "ip -6 route" to find the default information there.
- This may take a long time to run, be patient. The global routing table is very large. As of posting this, there are over 1 Million IPv4 routes and almost 250k IPv6 routes to import. The conversion takes a long time from the format that is provided by RIPE to a standard text file. It isn't frozen, just let is keep running.
- A full-table will take up a lot of RAM. Be sure your system can handle it. For a full-table, I highly recommend at least 2GB of RAM. This is in addition to anything else you have running. So for example if you have a system with 4GB RAM and system is currently using 2GB of RAM, you have 2GB for this table to run in.

Extra notes:
- You may want to run this regularly, as the global routing table is updated very frequently as ranges are added and deleted.
- This will not last over a reboot. If you want it to last over reboot, add the ipv4.sh and ipv6.sh to @reboot with in crontab with a 5 minute delay (sleep 5 && command_here)
- If using DHCP, your default route from upstream will keep coming back. Highly suggested is to set static IPs for all interfaces that you will be using. For that reason, this is not recommended to be used in an environment where you cannot use static IP addresses for some reason, such as public wifi networks.
- If you switch between networks, for example by moving from 1 wifi network to another, the routing table will be reset and you'll need to re-import using ipv4.sh and ipv6.sh

Final things:
- The final ipv4.sh and ipv6.sh files are too large to upload here to github, but we maintain copies on our website as mentioned below. This script will allow you to generate them yourself. You can expect total process to take about 30 minutes to 1 hour in total, including importing using the ipv4.sh and ipv6.sh scripts. The space needed will be about 200MB on hard disk and 2GB in RAM.
- We maintain copies of all of this on our website, including final, ready-to-run and kept updated ipv4.sh and ipv6.sh scripts, text dumps of the RIPE route prefixes, etc. You can find all that and more at https://files.apiversa.com
