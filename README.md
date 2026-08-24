# AWS Blue-Green and Canary Deployment

An AWS deployment project that demonstrates highly available web applications behind an Application Load Balancer, with Blue-Green deployment, Canary traffic shifting, HTTPS, health checks, and rollback.

## Project Overview

The project uses four Amazon EC2 instances in two application environments:

| Environment | Servers | Application | Target group |
|---|---|---|---|
| Blue | Server 1, Server 2 | Villa Agency Website | `Blue-TG` |
| Green | Server 3, Server 4 | Klassy Cafe Website | `Green-TG` |

Blue represents the current production version. Green represents the candidate version that can be tested before receiving production traffic.

## Architecture

![AWS Blue-Green Canary Deployment Architecture](architecture/architecture-diagram.png)

Traffic flows through Route 53 and HTTPS on the Application Load Balancer. The ALB routes requests to healthy targets in the Blue or Green target group.

```text
User -> Route 53 -> HTTPS ALB
                    |       |
                 Blue-TG  Green-TG
                 |   |    |    |
              Server 1  Server 2  Server 3  Server 4
```

## AWS Services

- Amazon VPC and Availability Zones
- Amazon EC2 with Apache HTTP Server
- Application Load Balancer and Target Groups
- Security Groups
- Amazon Route 53
- AWS Certificate Manager
- Internet Gateway

## Deployment Guide

Follow the guides in this order:

1. [Route 53 domain setup](setup/01-route53.md)
2. [VPC and network setup](setup/02-vpc.md)
3. [Security group configuration](setup/03-security-group.md)
4. [EC2 instance setup](setup/04-ec2.md)
5. [Target group configuration](setup/05-target-groups.md)
6. [Application Load Balancer setup](setup/06-load-balancer.md)
7. [HTTPS and ACM configuration](setup/07-https-acm.md)
8. [Blue-Green and Canary deployment](setup/08-blue-green-canary.md)
9. [Testing and validation](testing/testing.md)

## EC2 User Data

Use the matching script when launching each environment:

- [Blue server setup](user-data/blue-server.sh)
- [Green server setup](user-data/green-server.sh)

The scripts install Apache, download the selected website, copy it to `/var/www/html`, and start the web server.

## Deployment Flow

1. Prepare the VPC, subnets, route table, and security groups.
2. Launch two Blue and two Green EC2 instances using the matching user-data scripts.
3. Create target groups and register the EC2 instances.
4. Configure the ALB, listeners, health checks, and HTTPS certificate.
5. Point the Route 53 record to the ALB.
6. Test Blue and Green independently.
7. Shift traffic from Blue to Green using a full switch or staged Canary percentages such as 90/10, 50/50, and 0/100.
8. Roll back to Blue if Green fails validation or monitoring.

## Prerequisites

- An AWS account with permissions to create the services listed above
- A domain name managed through Route 53, or a domain whose DNS can be updated
- An AWS Region with at least two Availability Zones
- An SSH key pair for EC2 access
- The public IP address used for restricted SSH access

Review the security group guide before exposing any instance to the internet. EC2 HTTP traffic should be permitted from the ALB security group, and SSH should be restricted to your IP when needed.

## Repository Structure

```text
aws-blue-green-canary-deployment/
├── README.md
├── LICENSE
├── architecture/
│   └── architecture-diagram.png
├── setup/
│   ├── 01-route53.md
│   ├── 02-vpc.md
│   ├── 03-security-group.md
│   ├── 04-ec2.md
│   ├── 05-target-groups.md
│   ├── 06-load-balancer.md
│   ├── 07-https-acm.md
│   └── 08-blue-green-canary.md
├── testing/
│   └── testing.md
└── user-data/
    ├── blue-server.sh
    └── green-server.sh
```

## Learning Outcomes

This project covers EC2 provisioning, VPC networking, security groups, Apache, ALB routing, target health checks, DNS, ACM certificates, HTTPS, Blue-Green deployment, Canary deployment, rollback, and high availability.

## Future Improvements

- Auto Scaling Groups and Launch Templates
- CloudWatch metrics, alarms, and centralized logging
- AWS WAF and Systems Manager
- Terraform or AWS CloudFormation
- GitHub Actions and automated deployment
- Automated rollback and infrastructure testing

## Author

Vikas Jagtap | B.Sc. Computer Science | AWS and DevOps

[GitHub profile](https://github.com/vikasjagtap9696)
