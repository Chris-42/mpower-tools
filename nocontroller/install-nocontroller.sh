#!/bin/sh
#
echo "Installing nocontroller ..."
sed 's/pkill -9 mcad/exit 0\n        pkill -9 mcad/;s/pkill -9 wpa_supplicant/exit 0\n        pkill -9 wpa_supplicant/' /usr/etc/syswrapper.sh > /etc/persistent/syswrapper.sh
chmod 755 /etc/persistent/syswrapper.sh

startscript=/var/etc/persistent/start.sh
poststart=/etc/persistent/rc.poststart

wget --no-check-certificate https://raw.githubusercontent.com/magcode/mpower-tools/master/nocontroller/start.sh -O $startscript
chmod 755 $startscript

if [ ! -f $poststart ]; then
    echo "$poststart not found, creating it ..."
    touch $poststart
    echo "#!/bin/sh" >> $poststart
    chmod 755 $poststart
fi

if grep -q "$startscript" "$poststart"; then
   echo "Found $poststart entry. File will not be changed"
else
   echo "Adding start command to $poststart"
   echo "$startscript" >> $poststart
fi
 
echo "Done!"
echo "run 'save' command if done."
