# Security Group Configuration

## What is a Security Group?

A Security Group is a virtual firewall for AWS resources such as EC2 instances and Application Load Balancers.

It controls which network traffic is allowed to reach a resource.

In this project, Security Groups are used to allow web traffic to the Application Load Balancer and EC2 instances.

---

# Security Groups Used

This project can use two Security Groups:

1. ALB Security Group
2. EC2 Security Group

Using separate Security Groups is a better security practice because EC2 instances do not need to accept web traffic directly from the entire internet.

---

# 1. ALB Security Group

The Application Load Balancer is public because users access the application through the ALB.

Create or select a Security Group for the ALB.

Example name:

    ALB-SG

## Inbound Rules

Allow:

    HTTP
    Port: 80
    Source: 0.0.0.0/0

    HTTPS
    Port: 443
    Source: 0.0.0.0/0

This allows users from the internet to access the Application Load Balancer.

---

# 2. EC2 Security Group

Create or select a Security Group for the EC2 instances.

Example name:

    EC2-SG

The EC2 instances run Apache on port 80.

## Inbound Rule

Allow:

    Type: HTTP
    Port: 80
    Source: ALB-SG

This means that the EC2 instances accept HTTP traffic from the Application Load Balancer.

The EC2 instances do not need to allow HTTP traffic from:

    0.0.0.0/0

This is more secure because users access the application through the ALB.

---

# 3. SSH Access

SSH is used to connect to Linux EC2 instances when required.

Example:

    Type: SSH
    Port: 22
    Source: My IP

Using:

    My IP

is safer than:

    0.0.0.0/0

Do not open SSH to the entire internet unless it is specifically required for a temporary learning purpose.

---

# Security Group Architecture

The traffic flow is:

    Internet
       |
       | HTTP :80
       | HTTPS :443
       v
    ALB-SG
       |
       | HTTP :80
       v
    EC2-SG
       |
       +-- Server 1
       +-- Server 2
       +-- Server 3
       +-- Server 4

---

# Step 1 - Open Security Groups

Go to:

    AWS Console
        ↓
    EC2
        ↓
    Security Groups

Click:

    Create security group

---

# Step 2 - Create ALB Security Group

Enter:

    Security group name:
    ALB-SG

    Description:
    Security group for Application Load Balancer

    VPC:
    Select the Default VPC used by this project

---

# Step 3 - Configure ALB Inbound Rules

Add:

    HTTP
    Port: 80
    Source: 0.0.0.0/0

Add:

    HTTPS
    Port: 443
    Source: 0.0.0.0/0

These rules allow users to access the ALB using HTTP and HTTPS.

---

# Step 4 - Configure ALB Outbound Rules

For this learning project, the default outbound rule can be used:

    All traffic
    Destination: 0.0.0.0/0

The ALB needs to communicate with the registered EC2 targets.

---

# Step 5 - Create EC2 Security Group

Create another Security Group.

Enter:

    Security group name:
    EC2-SG

    Description:
    Security group for application EC2 instances

    VPC:
    Select the Default VPC used by this project

---

# Step 6 - Configure EC2 Inbound Rules

Add:

    Type: HTTP
    Port: 80
    Source: ALB-SG

This allows the Application Load Balancer to send HTTP requests to Apache running on the EC2 instances.

For SSH administration, add:

    Type: SSH
    Port: 22
    Source: My IP

Only add SSH if you need direct SSH access to the servers.

---

# Step 7 - Configure EC2 Outbound Rules

The default outbound rule can be used:

    All traffic
    Destination: 0.0.0.0/0

This allows the EC2 instances to download packages and website files during setup.

For example, the User Data script needs internet access to run commands such as:

    yum install

and:

    wget

---

# Important Security Concept

Do not expose EC2 HTTP ports directly to the internet when using an Application Load Balancer.

Avoid this configuration:

    EC2
      |
      +-- HTTP :80
      |   Source: 0.0.0.0/0

Prefer:

    ALB
      |
      | HTTP :80
      v
    EC2
      |
      Source: ALB-SG

This creates a better security boundary.

---

# Security Group Flow

The final configuration is:

    Internet
       |
       | 80 / 443
       v
    ALB-SG
       |
       | 80
       v
    EC2-SG
       |
       +-------------------------+
       |                         |
       v                         v
    Blue Environment        Green Environment
       |                         |
    Server 1                  Server 3
    Server 2                  Server 4

---

# Testing Security Groups

After launching the EC2 instances and configuring Apache:

Test Apache locally on an EC2 server:

    curl http://localhost

Expected result:

    Website HTML content

Test the application through the ALB after the Load Balancer is configured.

The correct application path is:

    Internet
       ↓
    ALB
       ↓
    Target Group
       ↓
    EC2
       ↓
    Apache
       ↓
    Website

---

# Common Security Group Problems

## Problem 1 - Target is Unhealthy

Check:

    EC2-SG allows HTTP :80 from ALB-SG

---

## Problem 2 - Website Does Not Open

Check:

    ALB-SG allows HTTP :80

and:

    ALB-SG allows HTTPS :443

if HTTPS is configured.

---

## Problem 3 - SSH Does Not Work

Check:

    EC2 Security Group
    Port: 22
    Source: My IP

Also verify that the EC2 instance has a public IP and the subnet has internet connectivity.

---

# Security Best Practices

- Do not expose SSH to 0.0.0.0/0 unnecessarily.
- Allow HTTP to EC2 only from the ALB Security Group.
- Allow public HTTP/HTTPS access only to the ALB.
- Use HTTPS for production traffic.
- Use separate Security Groups for different AWS components.
- Remove unnecessary inbound rules.
- Regularly review Security Group rules.

---

# Final Configuration

## ALB-SG

    Inbound:

    HTTP  : 80  → 0.0.0.0/0
    HTTPS : 443 → 0.0.0.0/0

## EC2-SG

    Inbound:

    HTTP : 80 → ALB-SG
    SSH  : 22 → My IP (only when required)

---

# Next Step

After configuring the Security Groups, launch the four EC2 instances.

Next file:

    setup/04-ec2.md