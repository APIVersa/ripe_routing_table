#!/bin/bash
echo "Removing any old data and making folder..."
rm -r ribs > /dev/null 2>&1
mkdir ribs > /dev/null 2>&1
echo "Getting the GZ file from ripe..."
wget -O ribs/latest-bview.gz https://data.ris.ripe.net/rrc00/latest-bview.gz > /dev/null 2>&1
echo "Extracting from the GZ file..."
gunzip ribs/latest-bview.gz > /dev/null 2>&1
echo "Using BGPDUMP to get Prefixes..."
bgpdump ribs/latest-bview | grep '^PREFIX:' | awk '{print $2}' > ribs/allranges.txt
echo "Removing the old files..."
rm ribs/latest-bview > /dev/null 2>&1
echo "Removing Duplicates..."
sort -u ribs/allranges.txt > ribs/nodupes.txt
echo "Removing allranges.txt..."
rm ribs/allranges.txt > /dev/null 2>&1
echo "Splitting to ipv4.txt and ipv6.txt..."
grep -v ":" ribs/nodupes.txt > ribs/ipv4.txt
grep ":" ribs/nodupes.txt > ribs/ipv6.txt
echo "Removing nodupes.txt..."
rm ribs/nodupes.txt > /dev/null 2>&1
echo "Removing local addresses and bogons ipv4..."
sed -i -E '/(^0\.|^10\.|^100\.64\.|^127\.|^169\.254\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.0\.0\.|^192\.168\.|^198\.18\.|^198\.51\.100\.|^203\.0\.113\.|^224\.|^240\.)/d' ribs/ipv4.txt
echo "Removing local addresses and bogons ipv6..."
sed -i -E '/(^::1|^fc00:|^fd00:|^fe80:|^ff00:|^::|^2001:db8:|^2002:|^::ffff:)/d' ribs/ipv6.txt
echo "Prepending ipv4.txt..."
sed -i 's/^/ip route add /' ribs/ipv4.txt
echo "Prepending ipv6.txt..."
sed -i 's/^/ip -6 route add /' ribs/ipv6.txt
echo "Appending ipv4.txt..."
sed -i -E 's/$/ via GATEWAY_V4_HERE dev INTERFACE_HERE proto kernel metric 1024/' ribs/ipv4.txt
echo "Appending ipv6.txt..."
sed -i -E 's/$/ via GATEWAY_V6_HERE dev INTERFACE_HERE proto kernel metric 1024/' ribs/ipv6.txt
echo "Creating ipv4.sh..."
touch ribs/ipv4.sh && chmod +x ribs/ipv4.sh
echo "Creating ipv6.sh..."
touch ribs/ipv6.sh && chmod +x ribs/ipv6.sh

echo "Adding the headers to ipv4.sh..."
cat > ribs/ipv4.sh <<'EOF'
#!/bin/bash

# Function to validate an IPv4 address
validate_ipv4() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Function to validate the network interface
validate_interface() {
    local iface=$1
    if [[ -z "$iface" || ! -d "/sys/class/net/$iface" ]]; then
        return 1
    else
        return 0
    fi
}

# Ask for the network interface
while true; do
    read -p "Enter the network interface (e.g., eth0): " interface
    validate_interface "$interface"
    if [[ $? -eq 0 ]]; then
        break
    else
        echo "Invalid interface. Please try again."
    fi
done

# Ask for the gateway address
while true; do
    read -p "Enter the IPv4 gateway address: " gateway
    validate_ipv4 "$gateway"
    if [[ $? -eq 0 ]]; then
        break
    else
        echo "Invalid IPv4 address. Please try again."
    fi
done

# Replace placeholders with user input
sed -i "s/GATEWAY_V4_HERE/$gateway/" ribs/ipv4.txt
sed -i "s/INTERFACE_HERE/$interface/" ribs/ipv4.txt
EOF

echo "Adding the headers to ipv6.sh..."
cat > ribs/ipv6.sh <<'EOF'
#!/bin/bash

# Function to validate an IPv6 address
validate_ipv6() {
    local ip=$1
    if [[ $ip =~ ^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$ || $ip =~ ^([0-9a-fA-F]{1,4}:){1,7}:$ || $ip =~ ^::([0-9a-fA-F]{1,4}:){1,6}[0-9a-fA-F]{1,4}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate the network interface
validate_interface() {
    local iface=$1
    if [[ -z "$iface" || ! -d "/sys/class/net/$iface" ]]; then
        return 1
    else
        return 0
    fi
}

# Ask for the network interface
while true; do
    read -p "Enter the network interface (e.g., eth0): " interface
    validate_interface "$interface"
    if [[ $? -eq 0 ]]; then
        break
    else
        echo "Invalid interface. Please try again."
    fi
done

# Ask for the gateway address
while true; do
    read -p "Enter the IPv6 gateway address: " gateway
    validate_ipv6 "$gateway"
    if [[ $? -eq 0 ]]; then
        break
    else
        echo "Invalid IPv6 address. Please try again."
    fi
done

# Replace placeholders with user input
sed -i "s/GATEWAY_V6_HERE/$gateway/" ribs/ipv6.txt
sed -i "s/INTERFACE_HERE/$interface/" ribs/ipv6.txt
EOF

echo "Adding the ranges to ipv4.sh..."
cat ribs/ipv4.txt >> ribs/ipv4.sh
echo "Adding the ranges to ipv6.sh..."
cat ribs/ipv6.txt >> ribs/ipv6.sh
echo "Moving scripts to current directory and cleaning up..."
mv ribs/ipv4.sh ./ipv4.sh
mv ribs/ipv6.sh ./ipv6.sh
rm -r ./ribs
echo "This script is now finished. Please run ipv4.sh to import IPv6 records to your routing table or ipv6.sh to import IPv6 records to your routing table. Please note, by default they will be added to your default routing table. If you would like them to be added to a different table, please edit the script to add the table before running it."
