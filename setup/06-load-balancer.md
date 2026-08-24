# Application Load Balancer Setup

## Overview

An Application Load Balancer (ALB) distributes incoming application traffic across multiple EC2 instances.

In this project, the ALB is the main entry point for users.

The ALB receives traffic from Route 53 and forwards it to the Blue or Green Target Group.

---

## Application Load Balancer Flow

    User
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
    Blue-TG               Green-TG
      |                      |
      +-- Server 1           +-- Server 3
      +-- Server 2           +-- Server 4

---

# Step 1 - Open Load Balancers

Go to:

    AWS Console
        ↓
    EC2
        ↓
    Load Balancers

Click:

    Create Load Balancer

---

# Step 2 - Select Load Balancer Type

Select:

    Application Load Balancer

An Application Load Balancer works at Layer 7 and supports HTTP and HTTPS traffic.

Click:

    Create

---

# Step 3 - Configure Basic Settings

Enter:

    Load Balancer name:
    Blue-Green-ALB

Scheme:

    Internet-facing

IP address type:

    IPv4

The ALB is Internet-facing because users access the application from the internet.

---

# Step 4 - Configure Network

Select the same:

    VPC

that is being used by the EC2 instances.

Select subnets from at least two Availability Zones.

Example:

    Availability Zone 1a
        |
        +-- Public Subnet

    Availability Zone 1b
        |
        +-- Public Subnet

Using multiple Availability Zones improves availability.

---

# Step 5 - Configure Security Group

Select the ALB Security Group created earlier.

Example:

    ALB-SG

The ALB Security Group should allow:

    HTTP  : 80  ← Internet
    HTTPS : 443 ← Internet

---

# Step 6 - Configure HTTP Listener

Create an HTTP listener:

    Protocol:
    HTTP

    Port:
    80

For the initial setup, HTTP can forward to the Blue Target Group.

Example:

    HTTP :80
       |
       v
    Blue-TG

Later, after HTTPS is configured, HTTP will redirect to HTTPS.

---

# Step 7 - Configure HTTPS Listener

The HTTPS listener will be configured after the ACM certificate is created.

Configuration:

    Protocol:
    HTTPS

    Port:
    443

    Security Policy:
    Default recommended policy

    Certificate:
    ACM Certificate

The HTTPS listener will forward traffic to the required Target Group.

---

# Step 8 - Create the Load Balancer

Review the configuration:

    Name:
    Blue-Green-ALB

    Scheme:
    Internet-facing

    IP Address Type:
    IPv4

    VPC:
    Default VPC

    Subnets:
    Public subnets in two Availability Zones

    Security Group:
    ALB-SG

    Listener:
    HTTP :80

Click:

    Create load balancer

---

# Step 9 - Wait for ALB State

After creating the ALB, its state will initially be:

    Provisioning

Wait until the state becomes:

    Active

The ALB will receive a DNS name.

Example:

    blue-green-alb-xxxxxxxx.ap-south-1.elb.amazonaws.com

The exact DNS name will be different for every ALB.

---

# Step 10 - Configure Blue Target Group

Open:

    EC2
        ↓
    Load Balancers
        ↓
    Blue-Green-ALB
        ↓
    Listeners and rules

For the HTTP listener, configure the default action to:

    Forward to:
    Blue-TG

Traffic flow:

    User
      |
      v
    ALB :80
      |
      v
    Blue-TG
      |
      +-- Server 1
      +-- Server 2

---

# Step 11 - Test the ALB

Copy the ALB DNS name.

Example:

    blue-green-alb-xxxxxxxx.ap-south-1.elb.amazonaws.com

Open it in a browser:

    http://ALB-DNS-NAME

Expected result:

    Villa Agency Website

The request should be forwarded to the Blue Target Group.

---

# Step 12 - Check Target Health

Go to:

    EC2
        ↓
    Target Groups
        ↓
    Blue-TG
        ↓
    Targets

Expected:

    Server 1 → Healthy
    Server 2 → Healthy

If both targets are healthy, the ALB can send traffic to them.

---

# Step 13 - Test Load Balancing

Refresh the ALB DNS name multiple times.

The ALB distributes requests across healthy targets.

The traffic flow is:

    User
      |
      v
    ALB
      |
      +-- Server 1
      |
      +-- Server 2

The ALB decides which healthy target receives the request.

---

# Step 14 - Configure Green Target Group

The Green Target Group can be used as the second application environment.

Green contains:

    Server 3
    Server 4

Green application:

    Klassy Cafe Website

Traffic flow:

    ALB
      |
      v
    Green-TG
      |
      +-- Server 3
      +-- Server 4

The Green environment can be tested before moving production traffic to it.

---

# Step 15 - Listener Rules

Listener rules determine how the ALB handles requests.

A listener contains:

    Listener
       |
       +-- Rules
       |
       +-- Default Action

Example:

    HTTP :80
       |
       v
    Redirect to HTTPS :443

Then:

    HTTPS :443
       |
       v
    Forward to Target Group

---

# HTTP to HTTPS Redirect

After the ACM certificate is configured, change the HTTP listener.

The HTTP listener should use:

    Protocol:
    HTTP

    Port:
    80

    Action:
    Redirect

Destination:

    HTTPS
    Port 443

The traffic flow becomes:

    http://your-domain.com
              |
              v
          HTTP :80
              |
              v
        Redirect
              |
              v
        HTTPS :443
              |
              v
          Target Group

---

# ALB Health Check

The ALB uses Target Group health checks to determine which EC2 instances can receive traffic.

Example:

    Protocol:
    HTTP

    Port:
    80

    Path:
    /

If the target is healthy:

    ALB → Target

If the target becomes unhealthy:

    ALB → Stop sending new traffic

---

# High Availability

The ALB is deployed across multiple Availability Zones.

Example:

    Availability Zone 1a
          |
          +-- ALB Subnet
          +-- Server 1
          +-- Server 2


    Availability Zone 1b
          |
          +-- ALB Subnet
          +-- Server 3
          +-- Server 4

This provides better availability.

---

# Failure Testing

Stop one EC2 instance.

Example:

    Before:

    Server 1 → Healthy
    Server 2 → Healthy

Stop Server 1.

After the health check detects the failure:

    Server 1 → Unhealthy
    Server 2 → Healthy

The ALB continues sending traffic to the healthy target.

This demonstrates the benefit of health checks and load balancing.

---

# Troubleshooting

## ALB Cannot Reach EC2

Check:

    1. EC2 instance is running
    2. Apache is running
    3. EC2 Security Group allows HTTP :80 from ALB-SG
    4. Target Group health check path is correct
    5. Target is registered
    6. Target is healthy

---

## Target is Unhealthy

Run on the EC2 instance:

    sudo systemctl status httpd

Test:

    curl http://localhost

Check port:

    sudo ss -tlnp | grep :80

Check Security Group:

    HTTP :80
    Source: ALB-SG

---

## ALB DNS Does Not Open

Check:

    1. ALB state is Active
    2. ALB has at least two subnets
    3. ALB Security Group allows port 80
    4. Target Group contains healthy targets
    5. Apache is running on EC2

---

# Important Security Note

The recommended architecture is:

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
       +-- Server 1
       +-- Server 2
       +-- Server 3
       +-- Server 4

Users should access the application through the ALB instead of directly accessing EC2 public IP addresses.

---

# Final ALB Architecture

    Internet
       |
       v
    Route 53
       |
       v
    Application Load Balancer
       |
       +--------------------------+
       |                          |
       v                          v
    Blue-TG                    Green-TG
       |                          |
       +-- Server 1               +-- Server 3
       +-- Server 2               +-- Server 4

    Blue:
    Villa Agency Website

    Green:
    Klassy Cafe Website

---

# Expected Result

At the end of this step:

    Application Load Balancer → Active

    HTTP Listener:
    Port 80

    Blue Target Group:
    Server 1 + Server 2

    Green Target Group:
    Server 3 + Server 4

    Blue targets:
    Healthy

    Green targets:
    Healthy

The ALB is now ready for HTTPS configuration.

---

# Next Step

Configure HTTPS using AWS Certificate Manager (ACM).

Next file:

    setup/07-https-acm.md