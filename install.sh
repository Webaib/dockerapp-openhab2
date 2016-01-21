#!/bin/bash
# base configuration nicked from github.com/limetech/dockerapp-plex
# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# chfn workaround - Known issue within Dockers
ln -s -f /bin/true /usr/bin/chfn

# Update Apt-Get
add-apt-repository ppa:webupd8team/java -y
apt-get -q update

# Set Timezone
apt-get install -y ntp
echo 'server 0.uk.pool.ntp.org' > /etc/ntp.conf
echo 'Europe/London' > /etc/timezone

# Install Java 8
apt-get purge -qy openjdk*
apt-get install -y openjdk-8-jdk

# Downloads Openhab and extras
apt-get install -qy wget unzip
mkdir /downloads
cd /downloads


wget -nv https://openhab.ci.cloudbees.com/job/openHAB-Distribution/lastSuccessfulBuild/artifact/distributions/openhab-online/target/openhab-online-2.0.0-SNAPSHOT.zip
#wget -nv https://github.com/cdjackson/HABmin2/blob/master/output/HABmin2-0.0.15-release.zip?raw=true
#wget -nv https://github.com/cdjackson/HABmin2/blob/master/output/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar?raw=true


# Main runtime
unzip -q openhab-online-2.0.0-SNAPSHOT.zip -d /opt/openhab

# HabMin
#mkdir -r /opt/openhab/webapps/habmin2
#unzip -q HABmin2-0.0.15-release.zip -d /opt/openhab/webapps/habmin2
#cp -rp org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar /opt/openhab/addons/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar

# Add user:group and chown
adduser --system --no-create-home --group openhab
usermod openhab -a -G dialout
chown -R openhab:openhab /opt/openhab
chmod +x /opt/openhab/addons/*.jar

# Add startup
# ln -s /opt/openhab/runtime/karaf/bin/openHAB-service /etc/init.d/
systemctl enable /opt/openhab/runtime/karaf/bin/openHAB.service

#mkdir -p /etc/service/openhab
#cat <<'EOT' > /etc/service/openhab/run
#!/bin/bash
#umask 000
#exec /opt/openhab/start.sh
#EOT
#chmod +x /etc/service/openhab/run

# Quick Cleanup
rm /opt/openhab/*.bat 
rm -r /downloads
rm /install.sh
