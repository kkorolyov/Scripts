#!/bin/bash

# CentOS7 Scrumptious setup script
## Updates OS
## Installs basic tools
## Optionally installs various server applications

me="$(basename $0) ->"

function installConfirm {
	echo -n "$me Install ${1}? [N/Y]: "
	read confirm
	[ "$confirm" == "Y" -o "$confirm" == "y" ]
}

function selfSign {
	keyDir="/etc/ssl/private"
	certDir="/etc/ssl/certs"
	mkdir -p "$keyDir"
	mkdir -p "$certDir"

	key="${keyDir}/${1}-self.key"
	cert="${certDir}/${1}-self.crt"

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$key" -out "$cert"
}

# Update system
echo "$me Updating system..."
yum -y update > /dev/null
yum -y upgrade > /dev/null
echo "$me Done updating"; echo

# Install basic tools
echo "$me Installing basic tools..."
tools=(
	"wget"
	"yum-utils"
	"gcc"
	"bzip2"
	"kernel-devel"
	"dkms"
	"net-tools"
	"vim"
	"git"
)
for tool in "${tools[@]}"; do
	yum -y install "$tool" > /dev/null
	echo "$me Installed $tool"
done
echo "$me Installed basic tools"; echo

# Install Docker
if installConfirm "Docker"; then
	echo "$me Installing Docker..."
	
	yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo
	yum makecache fast
	yum -y install docker-engine > /dev/null
	
	echo "$me Installed Docker"; echo
fi

#Install MySQL
if installConfirm "MySQL"; then
	echo "$me Installing MySQL..."
	
	mysqlRPM="/tmp/mysql.rpm"
	wget -o /dev/null -O "$mysqlRPM" https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
	rpm -U "$mysqlRPM"
	yum -y install mysql-community-server > /dev/null
	systemctl enable mysqld
	systemctl start mysqld

	mysqlTempPass="$(grep 'temporary password' /var/log/mysqld.log | sed 's/^.*\s//')"
	echo -n "MySQL root password: "
	read mysqlPass
	mysql -uroot -p"$mysqlTempPass" -e"ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysqlPass}'"

	echo "$me Installed MySQL"; echo
fi

#Install PostgreSQL
if installConfirm "PostgreSQL"; then
	echo "$me Installing PostgreSQL..."
	
	yum -y install postgresql-server > /dev/null
	postgresql-setup initdb
	systemctl enable postgresql
	systemctl start postgresql
	
	echo "$me Installed PostgreSQL"; echo
fi

#Install Tomcat
if installConfirm "Tomcat"; then
	echo "$me Installing Tomcat..."
	
	yum -y install java-1.8.0-openjdk-devel > /dev/null

	tomcatTar="/tmp/tomcat.tar.gz"
	wget -o /dev/null -O "$tomcatTar" http://apache.mirrors.ionfish.org/tomcat/tomcat-9/v9.0.0.M17/bin/apache-tomcat-9.0.0.M17.tar.gz
	tar -xzf "$tomcatTar" -C /opt
	tomcatDir="/opt/$(tar -tzf $tomcatTar | head -1 | sed -e 's:/.*::')"
	
	useradd -d "$tomcatDir" -s /sbin/nologin -M tomcat
	chown -R tomcat:tomcat "$tomcatDir"
	
	keystoreDir="${tomcatDir}/conf/.keystore"
	keytool -genkey -alias tomcat -keyalg RSA -keystore "$keystoreDir"
	cat << EOT > "${tomcatDir}/howToSSL.txt"
<!-- Add the following snippet to ${tomcatDir}/conf/server.xml -->
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
		maxThreads="150" SSLEnabled="true">
	<SSLHostConfig>
		<Certificate certificateKeystoreFile="${keystoreDir}"
				certificateKeystorePassword="<SET_ME>"
				type="RSA" />
	</SSLHostConfig>
</Connector>
EOT
	
	cat << EOT > /usr/lib/systemd/system/tomcat.service
# Systemd service file for tomcat
[Unit]
Description=Apache Tomcat Web Application Server
After=syslog.target network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment=JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::")
Environment=CATALINA_HOME=$tomcatDir

ExecStart=$tomcatDir/bin/startup.sh
ExecStop=$tomcatDir/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOT
	systemctl daemon-reload
	systemctl enable tomcat
	systemctl start tomcat

	echo "$me Installed Tomcat"; echo
fi

#Install NGINX
if installConfirm "NGINX"; then
	echo "$me Installing NGINX..."
	
	cat << 'EOT' > /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
EOT
	
	yum -y install nginx > /dev/null
	
	selfSign "nginx"
	cat << EOT > /etc/nginx/howToSSL.txt
# Add the following snippet to an nginx .conf
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	server_name _;

	return 301 https://$host$request_uri;
}
server {
	listen 443 ssl;
	server_name <NAME>;

	ssl_certificate /etc/ssl/certs/nginx-self.crt;
	ssl_certificate_key /etc/ssl/private/nginx-self.key;
EOT
	
	echo "$me Installed NGINX"; echo
fi
