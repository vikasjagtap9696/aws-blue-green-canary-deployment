# Target Groups Configuration

## Overview

A Target Group is a collection of EC2 instances that receive traffic from the Application Load Balancer (ALB).

In this project, we create two Target Groups:

- Blue Target Group
- Green Target Group

The Blue Target Group contains Server 1 and Server 2.

The Green Target Group contains Server 3 and Server 4.

---

## Target Group Architecture

    Application Load Balancer
              |
       +------+------+
       |             |
       v             v
   Blue Target    Green Target
      Group          Group
       |               |
   +---+---+       +---+---+
   |       |       |       |
   v       v       v       v
Server 1 Server 2 Server 3 Server 4
  Blue     Blue    Green    Green

---

# 1. Create Blue Target Group

## Purpose

The Blue Target Group contains the EC2 instances running the current application version.

In this project:

    Server 1 → Villa Agency Website
    Server 2 → Villa Agency Website

---

## Step 1 - Open Target Groups

Go to:

    AWS Console
        ↓
    EC2
        ↓
    Target Groups

Click:

    Create target group

---

## Step 2 - Select Target Type

Select:

    Target type:
    Instances

This allows EC2 instances to be registered directly with the Target Group.

---

## Step 3 - Configure Blue Target Group

Enter:

    Target group name:
    Blue-TG

Select:

    Target type:
    Instances

Protocol:

    HTTP

Port:

    80

IP address type:

    IPv4

VPC:

    Select the Default VPC used in this project

---

## Step 4 - Configure Health Check

Configure:

    Health check protocol:
    HTTP

    Health check path:
    /

    Health check port:
    Traffic port

The ALB will periodically send a request to the health check path.

If the EC2 instance responds successfully, the target becomes healthy.

---

## Step 5 - Register Blue Servers

Select:

    Server 1
    Server 2

Set port:

    80

Click:

    Include as pending below

Then create the Target Group.

---

# 2. Create Green Target Group

## Purpose

The Green Target Group contains the EC2 instances running the new application version.

In this project:

    Server 3 → Klassy Cafe Website
    Server 4 → Klassy Cafe Website

---

## Step 1 - Create Target Group

Go to:

    EC2
        ↓
    Target Groups
        ↓
    Create target group

Select:

    Target type:
    Instances

---

## Step 2 - Configure Green Target Group

Enter:

    Target group name:
    Green-TG

Protocol:

    HTTP

Port:

    80

IP address type:

    IPv4

VPC:

    Select the Default VPC used in this project

---

## Step 3 - Configure Health Check

Configure:

    Health check protocol:
    HTTP

    Health check path:
    /

    Health check port:
    Traffic port

---

## Step 4 - Register Green Servers

Select:

    Server 3
    Server 4

Set port:

    80

Click:

    Include as pending below

Then create the Target Group.

---

# Target Group Summary

The final configuration should be:

    Blue-TG
        |
        +-- Server 1
        +-- Server 2
        |
        +-- Villa Agency Website


    Green-TG
        |
        +-- Server 3
        +-- Server 4
        |
        +-- Klassy Cafe Website

---

# Health Checks

Health checks allow the ALB to determine whether an EC2 instance is available to receive traffic.

The ALB sends:

    HTTP GET /

to the registered EC2 instance.

Example:

    ALB
     |
     | HTTP :80
     v
    EC2
     |
     v
    Apache
     |
     v
    Website

If the application responds correctly:

    Target = Healthy

If the application does not respond correctly:

    Target = Unhealthy

---

# Target Health States

Common target states include:

    Initial
    Healthy
    Unhealthy
    Draining

## Initial

The target has been registered and health checks are still being performed.

## Healthy

The target is successfully passing health checks.

## Unhealthy

The target is failing health checks.

## Draining

The target is being removed from the Target Group while existing connections are allowed to finish.

---

# Verify Blue Target Group

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

---

# Verify Green Target Group

Go to:

    EC2
        ↓
    Target Groups
        ↓
    Green-TG
        ↓
    Targets

Expected:

    Server 3 → Healthy
    Server 4 → Healthy

---

# Troubleshooting Unhealthy Targets

If a target is unhealthy, check the following.

## 1. Check EC2 Instance

Make sure the EC2 instance is:

    Running

Also verify:

    Status checks: 2/2 checks passed

---

## 2. Check Apache

Connect to the EC2 instance and run:

    sudo systemctl status httpd

Apache should show:

    Active: active (running)

If Apache is stopped:

    sudo systemctl start httpd

---

## 3. Check Port 80

Run:

    sudo ss -tlnp | grep :80

Apache should be listening on port 80.

---

## 4. Test Website Locally

Run:

    curl http://localhost

The server should return HTML content.

---

## 5. Check Security Group

The EC2 Security Group must allow:

    HTTP
    Port: 80
    Source: ALB-SG

The ALB Security Group should allow:

    HTTP
    Port: 80
    Source: 0.0.0.0/0

---

## 6. Check Health Check Path

The Target Group health check path is:

    /

Make sure the application responds correctly to:

    http://EC2-IP/

---

# Why Use Two Target Groups?

Two Target Groups separate the two application versions.

    Blue-TG
        |
        +-- Version 1
        +-- Server 1
        +-- Server 2


    Green-TG
        |
        +-- Version 2
        +-- Server 3
        +-- Server 4

This separation makes Blue-Green deployment easier.

---

# Blue-Green Deployment Flow

Before deployment:

    ALB
     |
     v
    Blue-TG
     |
     +-- Server 1
     +-- Server 2

Green environment:

    Green-TG
     |
     +-- Server 3
     +-- Server 4

After successful testing, traffic can be moved to Green.

    ALB
     |
     v
    Green-TG
     |
     +-- Server 3
     +-- Server 4

---

# Canary Deployment

The two Target Groups can also be used for controlled traffic distribution.

Example:

    Blue  → 90%
    Green → 10%

Then:

    Blue  → 50%
    Green → 50%

Finally:

    Blue  → 0%
    Green → 100%

This allows the new application version to receive traffic gradually.

---

# Final Architecture

    Internet
       |
       v
    Route 53
       |
       v
    Application Load Balancer
       |
       +-------------------------+
       |                         |
       v                         v
    Blue-TG                   Green-TG
       |                         |
    +--+--+                    +--+--+
    |     |                    |     |
    v     v                    v     v
 Server Server               Server Server
   1      2                    3      4
    |     |                    |     |
    +--+--+                    +--+--+
       |                          |
     Villa                      Cafe
    Website                    Website

---

# Important Notes

- Use HTTP port 80 between the ALB and EC2 instances.
- Configure health checks before testing the ALB.
- Make sure all four targets are healthy before deployment testing.
- Do not send traffic to an unhealthy target.
- Keep the Blue environment available while testing Green.
- Keeping Blue available makes rollback faster if Green has a problem.

---

# Expected Result

At the end of this step:

    Blue-TG
        Server 1 → Healthy
        Server 2 → Healthy

    Green-TG
        Server 3 → Healthy
        Server 4 → Healthy

Both Target Groups are ready to be connected to the Application Load Balancer.

---

# Next Step

Create and configure the Application Load Balancer.

Next file:

    setup/06-load-balancer.md