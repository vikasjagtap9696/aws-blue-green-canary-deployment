#!/bin/bash

# Update packages
yum update -y

# Install Apache, wget and unzip
yum install -y httpd wget unzip

# Download Villa Agency website
wget --content-disposition \
https://templatemo.com/download/templatemo_591_villa_agency

# Extract website files
unzip -o templatemo_591_villa_agency.zip

# Copy website files to Apache web directory
cp -r templatemo_591_villa_agency/* /var/www/html/

# Set ownership
chown -R apache:apache /var/www/html

# Set permissions
chmod -R 755 /var/www/html

# Enable Apache at system startup
systemctl enable httpd

# Start Apache
systemctl start httpd

# Check Apache status
systemctl status httpd --no-pager