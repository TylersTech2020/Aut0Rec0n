#!/bin/bash

# Define the target domains
domains=("example.com" "test.com" "example.org")

# Define the output directory
output_dir="./scan_results"

# Loop through the target domains
for domain in "${domains[@]}"
do
    # Create a directory for the current domain's results
    mkdir -p "$output_dir/$domain"

    # Scan for open ports
    nmap -v -oN "$output_dir/$domain/open_ports.txt" "$domain"

    # Scan for subdomains
    sublist3r -d "$domain" -o "$output_dir/$domain/subdomains.txt"

    # Scan for file paths
    gobuster dir -u "https://$domain" -w /usr/share/wordlists/dirb/common.txt -o "$output_dir/$domain/file_paths.txt" -k
done

# Compare the new scan results with the previous ones and send an email if there are any differences
changes=$(git --git-dir="$output_dir/.git" --work-tree="$output_dir" diff HEAD~1 HEAD)

if [[ -n $changes ]]
then
    echo "$changes" | mail -s "Scan results have changed" youremail@example.com
fi
