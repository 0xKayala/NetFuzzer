#!/bin/bash

# Rename and move NetFuzzer.sh file to /usr/bin/netfuzzer
sudo mv NetFuzzer.sh /usr/bin/netfuzzer

# Make the NucleiFuzzer file executable
sudo chmod u+x /usr/bin/netfuzzer

# Remove the NetFuzzer folder from the home directory
if [ -d "$home_dir/NetFuzzer" ]; then
    echo "Removing NetFuzzer folder..."
    rm -r "$home_dir/NetFuzzer"
fi

echo "NetFuzzer has been installed successfully! Now Enter the command 'netfuzzer' to run the tool."
