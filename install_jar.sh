#!/bin/bash
# install updates
yum update -y

# install apache httpd
yum install httpd -y

# install java 8
yum install java-1.8.0 -y

# create the working directory
mkdir /opt/spring-boot-ec2-demo
# create configuration specifying the used profile
echo "RUN_ARGS=--spring.profiles.active=ec2" > /opt/spring-boot-ec2-demo/spring-boot-ec2-demo.conf

# create a springboot user to run the app as a service
useradd springboot
# springboot login shell disabled
chsh -s /sbin/nologin springboot
chown springboot:springboot /opt/spring-boot-ec2-demo/aws-spring-boot-demo-0.0.1-SNAPSHOT.jar
chmod 500 /opt/spring-boot-ec2-demo/aws-spring-boot-demo-0.0.1-SNAPSHOT.jar

# create a symbolic link
ln -s /opt/spring-boot-ec2-demo/aws-spring-boot-demo-0.0.1-SNAPSHOT.jar /etc/init.d/spring-boot-ec2-demo

# forward port 80 to 8080
echo "<VirtualHost *:80>
ProxyRequests Off
ProxyPass / http://localhost:8080/
ProxyPassReverse / http://localhost:8080/
</VirtualHost>" >> /etc/httpd/conf/httpd.conf

# start the httpd and spring-boot-ec2-demo
service httpd start
service spring-boot-ec2-demo start

# automatically start httpd and spring-boot-ec2-demo if this ec2 instance reboots
chkconfig httpd on
chkconfig spring-boot-ec2-demo on