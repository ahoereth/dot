#!/bin/bash
# Ref: https://bbs.archlinux.org/viewtopic.php?id=148165
# Run `/opt/lampp/lampp security` and edit `/opt/lampp/etc/httpd.conf` first:
# Uncomment `Include /etc/extra/httpd-vhosts.conf` and set `unixd_module`
# `user` and `group` variables to your user and the `www` group (owning group
# of `/opt/lampp/htdocs` and `$sitesDir` -- `user` should be in that group.)

sitesDir="/home/ahoereth/htdocs"
hostsFile="/etc/hosts"
xamppVHosts="/opt/lampp/etc/extra/httpd-vhosts.conf"

# Clear hostsFile
clearhosts=`sed '/#XAMPP virtual hosts/ {N; /.*\n.*/d}' $hostsFile`
echo "$clearhosts" > $hostsFile

# Start new hosts list
hosts="#XAMPP virtual hosts\n127.0.0.1"

# Get all site names
siteNames=`ls $sitesDir`

# Delete xamppVHosts
#rm $xamppVHosts

# Set xamppVHosts and generate hosts list
addrarr=($siteNames)
for address in "${addrarr[@]}"
do
	hosts+=" $address.localhost"
  echo -e "\
<VirtualHost 127.0.0.1:80>
  DocumentRoot $sitesDir/$address
  ServerName $address.localhost
  ErrorLog $sitesDir/$address/$address.error.log
  CustomLog $sitesDir/$address/$address.access.log common
  <Directory $sitesDir/$address>
    Require all granted
  </Directory>
</VirtualHost>\n" \
  >> $xamppVHosts
done

# Write hosts
echo -e $hosts >> $hostsFile
