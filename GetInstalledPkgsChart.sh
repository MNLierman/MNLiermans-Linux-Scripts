#!/bin/bash

# Get Installed Pkgs Chart
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements, commercial use of @MNLierman's scripts by written agreement only.
#
# This script creates an html file with a chart/table of installed pkgs on the system,
# their dependencies, and the installation details, such as version and date (if provided).

OUTPUT_FILE="packages_list.html"

# Create or clear the output file
echo "<html><body><h1>Installed Packages</h1><table border='1'>" > $OUTPUT_FILE
echo "<tr><th>Package</th><th>Dependencies</th><th>Installation Date</th></tr>" >> $OUTPUT_FILE

for pkg in $(dpkg-query -W -f='${binary:Package}\n'); do
    dependencies=$(apt-rdepends $pkg | grep -v "^ ")
    install_date=$(dpkg-query -W -f='${binary:Package}\t${Version}\t${Status}\t${Installed-Size}\t${Date}\n' | grep $pkg)
    
    echo "<tr>" >> $OUTPUT_FILE
    echo "<td>$pkg</td>" >> $OUTPUT_FILE
    echo "<td><pre>$dependencies</pre></td>" >> $OUTPUT_FILE
    echo "<td><pre>$install_date</pre></td>" >> $OUTPUT_FILE
    echo "</tr>" >> $OUTPUT_FILE
done

echo "</table></body></html>" >> $OUTPUT_FILE

echo "Package list saved to $OUTPUT_FILE"

