# AWS Blue-Green & Canary Deployment

## Project Overview

This project demonstrates a highly available web application deployment on AWS using Amazon EC2, Application Load Balancer, Target Groups, Route 53, AWS Certificate Manager, HTTPS, Security Groups, Blue-Green Deployment, Canary Deployment, Health Checks, Rollback, and High Availability.

The project contains two application environments:

- Blue Environment → Villa Agency Website
- Green Environment → Klassy Cafe Website

Each environment contains two EC2 servers.

---

## Architecture Diagram

The following architecture diagram represents the AWS infrastructure used in this project.

![AWS Blue-Green Canary Deployment Architecture](architecture/architecture-diagram.png)

---

## Project Architecture

The project uses four EC2 instances.

Blue Environment:

- Server 1 → Villa Agency Website
- Server 2 → Villa Agency Website

Green Environment:

- Server 3 → Klassy Cafe Website
- Server 4 → Klassy Cafe Website

---

## Application Traffic Flow

User
  |
  v
Route 53
  |
  v
Application Load Balancer
  |
  +---------------------------+
  |                           |
  v                           v
Blue Target Group       Green Target Group
  |                           |
  +-- Server 1                +-- Server 3
  +-- Server 2                +-- Server 4
  |                           |
Villa Agency              Klassy Cafe
Website                    Website

---

## AWS Services Used

| AWS Service | Purpose |
|---|---|
| Amazon VPC | Provides the AWS network |
| Default VPC | Used as the project network |
| Amazon EC2 | Hosts the web applications |
| Apache HTTP Server | Serves the websites |
| Application Load Balancer | Distributes application traffic |
| Target Groups | Manage Blue and Green servers |
| Amazon Route 53 | DNS and domain management |
| AWS Certificate Manager | Provides SSL/TLS certificate |
| Security Groups | Control network traffic |
| Internet Gateway | Provides internet connectivity |

---

# Blue Environment

The Blue environment represents the current application version.

Blue Target Group:

- Server 1
- Server 2

Application:

Villa Agency Website

Website template:

TemplateMo 591 - Villa Agency

Blue servers use:

user-data/blue-server.sh

The User Data script automatically:

1. Installs Apache
2. Installs wget
3. Installs unzip
4. Downloads the Villa Agency website
5. Extracts the website
6. Copies the website files to /var/www/html
7. Enables Apache
8. Starts Apache

---

# Green Environment

The Green environment represents the new application version.

Green Target Group:

- Server 3
- Server 4

Application:

Klassy Cafe Website

Website template:

TemplateMo 558 - Klassy Cafe

Green servers use:

user-data/green-server.sh

The User Data script automatically:

1. Installs Apache
2. Installs wget
3. Installs unzip
4. Downloads the Klassy Cafe website
5. Extracts the website
6. Copies the website files to /var/www/html
7. Enables Apache
8. Starts Apache

---

# EC2 Architecture

The four EC2 instances are divided into two environments.

Blue Environment:

Server 1
Server 2

Application:

Villa Agency Website

Green Environment:

Server 3
Server 4

Application:

Klassy Cafe Website

The servers are deployed across multiple Availability Zones to improve availability.

---

# EC2 User Data Automation

User Data is used to automatically configure the EC2 instances during launch.

The process is:

EC2 Launch
    |
    v
User Data
    |
    v
Install Apache
    |
    v
Install wget and unzip
    |
    v
Download Website
    |
    v
Extract Website
    |
    v
Copy Files to /var/www/html
    |
    v
Enable Apache
    |
    v
Start Apache
    |
    v
Website Ready

This reduces manual configuration and makes server setup consistent.

---

# Target Groups

Two Target Groups are used.

## Blue Target Group

Name:

Blue-TG

Targets:

- Server 1
- Server 2

Application:

Villa Agency Website

## Green Target Group

Name:

Green-TG

Targets:

- Server 3
- Server 4

Application:

Klassy Cafe Website

---

# Health Checks

The Application Load Balancer uses health checks to determine whether an EC2 instance is available.

Health Check Configuration:

- Protocol: HTTP
- Port: 80
- Path: /

The ALB periodically sends requests to the EC2 instances.

If the application responds successfully:

Healthy

If the application does not respond correctly:

Unhealthy

The ALB does not send new traffic to unhealthy targets.

---

# Application Load Balancer

The Application Load Balancer is the main entry point for the application.

Traffic flow:

Internet
   |
   v
Route 53
   |
   v
Application Load Balancer
   |
   +----------------------+
   |                      |
   v                      v
Blue-TG                Green-TG
   |                      |
   +-- Server 1           +-- Server 3
   +-- Server 2           +-- Server 4

The ALB provides:

- Load balancing
- Health checks
- Traffic routing
- HTTPS termination
- High availability

---

# Route 53

Amazon Route 53 is used for DNS management.

Example:

your-domain.com

Traffic flow:

User
 |
 v
your-domain.com
 |
 v
Route 53
 |
 v
Application Load Balancer

The Route 53 A record uses an Alias pointing to the Application Load Balancer.

---

# HTTPS Configuration

AWS Certificate Manager is used to provide the SSL/TLS certificate.

HTTPS traffic flow:

User
 |
 | HTTPS :443
 v
Application Load Balancer
 |
 v
Target Group
 |
 v
EC2 Servers

HTTP traffic is redirected to HTTPS.

HTTP :80
   |
   v
Redirect
   |
   v
HTTPS :443

---

# ACM Certificate Process

The HTTPS certificate process is:

Domain
   |
   v
AWS Certificate Manager
   |
   v
Request Public Certificate
   |
   v
DNS Validation
   |
   v
Certificate Issued
   |
   v
Attach Certificate to ALB
   |
   v
HTTPS :443

For eligible ACM-managed public certificates, AWS can automatically renew the certificate when the required validation configuration remains available.

---

# Security Groups

Two Security Groups are used.

## ALB Security Group

Inbound:

- HTTP : 80 → Internet
- HTTPS : 443 → Internet

## EC2 Security Group

Inbound:

- HTTP : 80 → ALB Security Group
- SSH : 22 → My IP, only when required

Recommended traffic flow:

Internet
   |
   v
ALB Security Group
   |
   v
EC2 Security Group
   |
   v
EC2 Instances

The EC2 HTTP port should not unnecessarily be exposed directly to the entire internet when using an Application Load Balancer.

---

# Blue-Green Deployment

Blue-Green Deployment uses two separate application environments.

Blue:

Current production version

Green:

New application version

Initially:

User
 |
 v
ALB
 |
 v
Blue-TG
 |
 +-- Server 1
 +-- Server 2

The Green environment can be tested separately.

After successful testing, production traffic can be moved to:

Green-TG

Traffic becomes:

User
 |
 v
ALB
 |
 v
Green-TG
 |
 +-- Server 3
 +-- Server 4

Green then becomes the production environment.

---

# Blue-Green Rollback

If the Green environment has a problem, traffic can be moved back to Blue.

Green
 |
 | Application Problem
 v
Rollback
 |
 v
Blue
 |
 v
Production

This provides a fast rollback mechanism.

One important advantage of Blue-Green deployment is that the previous environment can remain available during validation.

---

# Canary Deployment

Canary Deployment gradually moves traffic from the old application version to the new version.

Example:

Stage 1:

Blue  → 90%
Green → 10%

Monitor the application.

If everything is working correctly:

Stage 2:

Blue  → 50%
Green → 50%

Continue monitoring.

After successful validation:

Stage 3:

Blue  → 0%
Green → 100%

Green becomes the production environment.

---

# Canary Deployment Flow

ALB
 |
 +----------------------+
 |                      |
 v                      v
Blue-TG              Green-TG
90%                    10%
 |
 v
Monitoring
 |
 v
Blue 50%
Green 50%
 |
 v
Monitoring
 |
 v
Blue 0%
Green 100%

---

# High Availability

The project uses multiple EC2 instances and multiple Availability Zones.

Example:

Availability Zone 1a
 |
 +-- Server 1
 +-- Server 2

Availability Zone 1b
 |
 +-- Server 3
 +-- Server 4

If one EC2 instance becomes unhealthy, the Application Load Balancer can continue sending traffic to healthy instances.

---

# Failure Testing

Example:

Before failure:

Server 1 → Healthy
Server 2 → Healthy

If Server 1 fails:

Server 1 → Unhealthy
Server 2 → Healthy

The ALB stops sending new traffic to Server 1 and continues using Server 2.

This demonstrates:

- Health Checks
- Fault Tolerance
- Load Balancing
- High Availability

---

# Testing

The project includes testing for:

- EC2 instances
- Apache service
- Website availability
- Target Group health
- Application Load Balancer
- Route 53
- HTTPS
- ACM certificate
- Blue-Green deployment
- Canary deployment
- Rollback
- High availability

Detailed testing instructions are available in:

testing/testing.md

---

# Complete Deployment Process

1. Use AWS Default VPC
2. Configure Security Groups
3. Launch four EC2 instances
4. Configure EC2 servers using User Data
5. Install Apache and websites
6. Create Blue Target Group
7. Create Green Target Group
8. Register EC2 targets
9. Configure health checks
10. Create Application Load Balancer
11. Configure Route 53
12. Request ACM public certificate
13. Configure HTTPS listener on port 443
14. Redirect HTTP port 80 to HTTPS
15. Test Blue environment
16. Test Green environment
17. Perform Blue-Green deployment
18. Perform Canary deployment
19. Monitor application
20. Test rollback
21. Verify high availability

---

# Repository Structure

aws-blue-green-canary-deployment/
|
|-- README.md
|
|-- architecture/
|   |-- architecture-diagram.png
|
|-- user-data/
|   |-- blue-server.sh
|   |-- green-server.sh
|
|-- setup/
|   |-- 01-route53.md
|   |-- 02-vpc.md
|   |-- 03-security-group.md
|   |-- 04-ec2.md
|   |-- 05-target-groups.md
|   |-- 06-load-balancer.md
|   |-- 07-https-acm.md
|   |-- 08-blue-green-canary.md
|
|-- testing/
|   |-- testing.md
|
|-- LICENSE

---

# Learning Outcomes

Through this project, I learned:

- AWS EC2
- Default VPC
- Security Groups
- Availability Zones
- Apache Web Server
- EC2 User Data
- Application Load Balancer
- Target Groups
- Health Checks
- Route 53
- DNS
- AWS Certificate Manager
- SSL/TLS
- HTTPS
- Blue-Green Deployment
- Canary Deployment
- Traffic Shifting
- Rollback
- High Availability
- AWS networking fundamentals
- Basic DevOps deployment concepts

---

# Interview Questions

## What is the purpose of this project?

The purpose of this project is to demonstrate how AWS can be used to deploy a highly available web application and implement controlled deployment strategies such as Blue-Green and Canary deployment.

## Why did you use an Application Load Balancer?

The Application Load Balancer distributes traffic across healthy EC2 instances and provides health checks, traffic routing, and HTTPS termination.

## Why did you create two Target Groups?

Two Target Groups are used to separate the Blue and Green application environments.

## What is Blue-Green Deployment?

Blue-Green Deployment uses two separate environments. Blue represents the current production environment and Green represents the new application version.

Traffic can be switched from Blue to Green after testing.

## What is Canary Deployment?

Canary Deployment gradually sends a small percentage of traffic to the new application version before sending all traffic to it.

## What happens if Green fails?

Traffic can be moved back to Blue. This provides a quick rollback mechanism.

## Why did you use ACM?

AWS Certificate Manager provides the SSL/TLS certificate required for HTTPS.

## Why did you use Route 53?

Route 53 is used for DNS management and to connect the domain name with the Application Load Balancer.

## Why are Target Groups used?

Target Groups contain the EC2 instances that receive traffic from the Application Load Balancer.

## What is a Health Check?

A Health Check allows the ALB to determine whether an EC2 instance is healthy and ready to receive traffic.

---

# Future Improvements

This project can be extended with:

- Auto Scaling Groups
- Launch Templates
- Amazon CloudWatch
- CloudWatch Alarms
- AWS WAF
- AWS Systems Manager
- Terraform
- AWS CloudFormation
- GitHub Actions
- CI/CD Pipeline
- Docker
- Amazon ECR
- Amazon ECS
- Kubernetes
- Automated deployment
- Automated rollback
- Infrastructure as Code
- Monitoring and alerting

---

# Project Goal

The main goal of this project is to understand how AWS infrastructure, load balancing, DNS, HTTPS, health checks, Blue-Green deployment, Canary deployment, traffic shifting, rollback, and high availability work together to provide a reliable application deployment strategy.

---

# Author

Vikas Jagtap

B.Sc. Computer Science | AWS & DevOps

GitHub:
https://github.com/vikasjagtap9696