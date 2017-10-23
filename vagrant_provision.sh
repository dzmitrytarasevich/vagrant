#!/bin/sh

# Title: Tomcat 8 Application Server vagrant provisioning script
# Tomcat version: Apache Tomcat 8.5.23
# Java version: Java JDK 8u151

# Disable SELINUX
echo "Disabling SELINUX..."
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Update system
echo "Updating system..."
sudo yum update -y > /dev/null 2>&1

# Install useful packages
echo "Installing useful packages..."
sudo yum install -y epel-release > /dev/null 2>&1
sudo yum install -y mc mlocate tree vim > /dev/null 2>&1
updatedb > /dev/null 2>&1

# Create tomcat user & password
echo "Creating tomcat user account..."
sudo useradd -s /bin/bash user > /dev/null 2>&1
echo user:password | chpasswd

# Install & configure Java JDK
echo "Installing & configuring java..."
echo "Extracting JDK package..."
sudo cp /vagrant/jdk-8u151-linux-x64.tar.gz /opt && cd /opt && tar -xzvf jdk-8u151-linux-x64.tar.gz > /dev/null 2>> /vagrant/jdk-error.log
# check if extracted directory exists, if true continue, if false exit with error
if [ -d /opt/jdk1.8.0_151 ]; then
echo "JDK Extracted successfully..."
else
echo "ERROR: JDK exctraction failed! See /vagrant/jdk-error.log..."
exit 1
fi

# Update java alternatives
echo "Updating alternatives..."
alternatives --install /usr/bin/java java /opt/jdk1.8.0_151/bin/java 2 > /dev/null 2>> /vagrant/jdk-error.log
alternatives --config java 2>> /vagrant/jdk-error.log
alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_151/bin/jar 2 > /dev/null 2>> /vagrant/jdk-error.log
alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_151/bin/javac 2 > /dev/null 2>> /vagrant/jdk-error.log
alternatives --set jar /opt/jdk1.8.0_151/bin/jar > /dev/null 2>> /vagrant/jdk-error.log
alternatives --set javac /opt/jdk1.8.0_151/bin/javac > /dev/null 2>> /vagrant/jdk-error.log

# Set java environment variables
echo "Setting Java Environment Variables..."
echo "JAVA_HOME=/opt/jdk1.8.0_151/" >> /etc/bashrc > /dev/null 2>&1
echo "JRE_HOME=/opt/jdk1.8.0_151/jre" >> /etc/bashrc > /dev/null 2>&1
echo "PATH=$PATH:/opt/jdk1.8.0_151/bin:/optjdk1.8.0_151/jre/bin" >> /etc/bashrc > /dev/null 2>&1
echo "Java configuration complete!"

# Install & start apache
echo "Installing & configuring Apache Tomcat 8..."
echo "Extracting Apache Tomcat..."
cp /vagrant/apache-tomcat-8.5.23.tar.gz /opt && cd /opt && tar -xzvf apache-tomcat-8.5.23.tar.gz > /dev/null 2>> /vagrant/tomcat-error.log
# check if extracted directory exists, if true continue, if false exit with error
if [ -d /opt/apache-tomcat-8.5.23/ ]; then
echo "Apache Tomcat extracted successfully!"
else
echo "ERROR: Tomcat extraction failed. See /vagrant/tomcat-error.log!"
exit 1
fi

# Start tomcat service
echo "Starting Tomcat service..."
/opt/apache-tomcat-8.5.23/bin/startup.sh
