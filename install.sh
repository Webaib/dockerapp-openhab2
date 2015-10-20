#!/bin/bash
# base configuration nicked from github.com/limetech/dockerapp-plex
# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
chown -R nobody:users /home

# chfn workaround - Known issue within Dockers
ln -s -f /bin/true /usr/bin/chfn

# Install Java 7
apt-get -q update
apt-get purge -qy openjdk*
apt-get install -y openjdk-7-jdk

# Downloads Openhab and extras
apt-get -q update
apt-get install -qy wget unzip
mkdir /downloads
cd /downloads


wget -nv  https://openhab.ci.cloudbees.com/job/openHAB2/lastSuccessfulBuild/artifact/distribution/target/distribution-2.0.0-SNAPSHOT-runtime.zip
wget -nv  https://openhab.ci.cloudbees.com/job/openHAB/lastSuccessfulBuild/artifact/distribution/target/distribution-1.8.0-SNAPSHOT-addons.zip
wget -nv https://github.com/cdjackson/HABmin2/releases/download/0.0.15/HABmin2-0.0.15-release.zip
wget -nv https://github.com/cdjackson/HABmin2/releases/download/0.0.15/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar

# Main runtime
unzip -q distribution-2.0.0-SNAPSHOT-runtime.zip -d /opt/openhab

# Addons copy zwave jar across
unzip -q distribution-1.8.0-SNAPSHOT-addons.zip -d /downloads/addons/
cp -rp addons/org.openhab.binding.zwave-1.8.0-SNAPSHOT.jar /opt/openhab/conf/addons/

# HabMin jar
cp -rp org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar /opt/openhab/conf/addons/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar

# HabMin2 webapp
#unzip -q HABmin2-0.0.15-release.zip -d /opt/openhab/webapps/habmin2

# Add user:group and chown
adduser --system --no-create-home --group openhab
usermod openhab -a -G dialout
chown -R openhab:openhab /opt/openhab
chmod +x /opt/openhab/conf/addons/*.jar

# This is now handled by a custom config
#cp -rp /opt/openhab/configurations/openhab_default.cfg /opt/openhab/configurations/openhab.cfg

# Move startup as were using a custom one
# mv /opt/openhab/start.sh /opt/openhab/start.sh.original

# Add startup
mkdir -p /etc/service/openhab
cat <<'EOT' > /etc/service/openhab/run
#!/bin/bash
umask 000
exec /opt/openhab/start.sh
EOT
chmod +x /etc/service/openhab/run

# Quick Cleanup
rm /opt/openhab/*.bat 
rm -r /downloads
rm /install.sh
