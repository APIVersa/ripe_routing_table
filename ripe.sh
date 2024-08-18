#!/bin/bash

# Function to validate IPv4 addresses
validate_ipv4() {
    local ipv4=$1
    if [[ $ipv4 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        for octet in $(echo $ipv4 | tr "." " "); do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Function to validate IPv6 addresses
validate_ipv6() {
    local ipv6=$1
    if [[ $ipv6 =~ ^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$ || $ipv6 =~ ^([0-9a-fA-F]{1,4}:){1,7}:$ || $ipv6 =~ ^:([0-9a-fA-F]{1,4}:){1,7}$ || $ipv6 =~ ^([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}$ || $ipv6 =~ ^([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}$ || $ipv6 =~ ^([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}$ || $ipv6 =~ ^([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}$ || $ipv6 =~ ^([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}$ || $ipv6 =~ ^[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})$ || $ipv6 =~ ^:((:[0-9a-fA-F]{1,4}){1,7})$ || $ipv6 =~ ^fe80::[0-9a-fA-F]{0,4}(:[0-9a-fA-F]{1,4}){0,4}%[0-9a-zA-Z]{1,}$ || $ipv6 =~ ^::(ffff(:0{1,4}){0,1}:){0,1}(([0-9]{1,3}\.){3}[0-9]{1,3})$ || $ipv6 =~ ^([0-9a-fA-F]{1,4}:){1,4}:(([0-9]{1,3}\.){3}[0-9]{1,3})$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate network interface
validate_interface() {
    local interface=$1
    if ip link show "$interface" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Request and validate user input for the interface name
while true; do
    read -p "Enter the main interface name (e.g., enp3s0): " INTERFACE
    if validate_interface "$INTERFACE"; then
        break
    else
        echo "Invalid interface name or the interface does not exist. Please try again."
    fi
done

# Request and validate user input for the IPv4 gateway
while true; do
    read -p "Enter the IPv4 gateway: " IPV4_GATEWAY
    if validate_ipv4 "$IPV4_GATEWAY"; then
        break
    else
        echo "Invalid IPv4 address. Please enter a valid IPv4 address."
    fi
done

# Request and validate user input for the IPv6 gateway
while true; do
    read -p "Enter the IPv6 gateway: " IPV6_GATEWAY
    if validate_ipv6 "$IPV6_GATEWAY"; then
        break
    else
        echo "Invalid IPv6 address. Please enter a valid IPv6 address."
    fi
done

echo -e "Removing any old data and making folder...\n"
rm -r ribs && mkdir ribs

echo -e "Getting the GZ file from RIPE...\n"
wget -O ribs/latest-bview.gz https://data.ris.ripe.net/rrc00/latest-bview.gz

echo -e "Extracting from the GZ file...\n"
gunzip ribs/latest-bview.gz

echo -e "Using BGPDUMP to get Prefixes...\n"
bgpdump ribs/latest-bview | grep '^PREFIX:' | awk '{print $2}' > ribs/allranges.txt

echo -e "Removing the old files...\n"
rm ribs/latest-bview

echo -e "Removing Duplicates...\n"
sort -u ribs/allranges.txt > ribs/nodupes.txt

echo -e "Removing allranges.txt...\n"
rm ribs/allranges.txt

echo -e "Splitting to ipv4.txt and ipv6.txt...\n"
grep -v ":" ribs/nodupes.txt > ribs/ipv4.txt
grep ":" ribs/nodupes.txt > ribs/ipv6.txt

echo -e "Removing nodupes.txt...\n"
rm ribs/nodupes.txt

echo -e "Removing local addresses and bogons IPv4...\n"
sed -i -E '/(^0\.|^10\.|^100\.64\.|^127\.|^169\.254\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.0\.0\.|^192\.168\.|^198\.18\.|^198\.51\.100\.|^203\.0\.113\.|^224\.|^240\.)/d' ribs/ipv4.txt

echo -e "Removing local addresses and bogons IPv6...\n"
sed -i -E '/(^::1|^fc00:|^fd00:|^fe80:|^ff00:|^::|^2001:db8:|^2002:|^::ffff:)/d' ribs/ipv6.txt

echo -e "Prepending ipv4.txt for import to table 144...\n"
sed -i 's/^/ip route add /' ribs/ipv4.txt

echo -e "Prepending ipv6.txt for import to table 244...\n"
sed -i 's/^/ip -6 route add /' ribs/ipv6.txt

echo -e "Appending ipv4.txt for import to table 144...\n"
sed -i -E "s/\$/ via $IPV4_GATEWAY dev $INTERFACE proto kernel metric 1024 table 144/" ribs/ipv4.txt

echo -e "Appending ipv6.txt for import to table 244...\n"
sed -i -E "s/\$/ via $IPV6_GATEWAY dev $INTERFACE proto kernel metric 1024 table 266/" ribs/ipv6.txt

echo -e "Combining ipv4.txt and ipv6.txt and creating bash script...\n"
cat ribs/ipv4.txt ribs/ipv6.txt > ribs/routes.sh

# Check if table 144 has routes and flush if it does
if ip route show table 144 | grep -q "."; then
    echo -e "Clearing the routing table 144...\n"
    ip route flush table 144
else
    echo -e "No routes in table 144. Skipping flush...\n"
fi

# Check if table 266 has routes and flush if it does
if ip -6 route show table 266 | grep -q "."; then
    echo -e "Clearing the routing table 266...\n"
    ip -6 route flush table 266
else
    echo -e "No routes in table 266. Skipping flush...\n"
fi

echo -e "Running routes.sh to add routes...\n"
chmod +x ribs/routes.sh
bash ribs/routes.sh

echo -e "Removing routes.sh...\n"
rm ribs/routes.sh
