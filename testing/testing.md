# Testing and Validation

## Overview

This document explains how to test the AWS Blue-Green and Canary Deployment project.

The testing process verifies:

- EC2 instances
- Apache web server
- Target Groups
- Health Checks
- Application Load Balancer
- Route 53
- HTTPS
- Blue-Green Deployment
- Canary Deployment
- Rollback
- High Availability

---

# 1. EC2 Instance Testing

Open:

    AWS Console
        ↓
    EC2
        ↓
    Instances

Verify all four servers are running.

Expected:

    Blue-Server-1   → Running
    Blue-Server-2   → Running
    Green-Server-3  → Running
    Green-Server-4  → Running

Also verify:

    Status checks → 2/2 checks passed

---

# 2. Apache Service Testing

Connect to each EC2 instance using SSH when required.

Run:

    sudo systemctl status httpd

Expected:

    Active: active (running)

If Apache is not running:

    sudo systemctl start httpd

Enable Apache at boot:

    sudo systemctl enable httpd

---

# 3. Local Website Testing

On each EC2 instance run:

    curl http://localhost

Expected result:

    HTML content of the deployed website

Blue servers should return the Villa Agency website.

Green servers should return the Klassy Cafe website.

---

# 4. Check Apache Port

Run:

    sudo ss -tlnp | grep :80

Expected:

    Apache is listening on port 80

The application uses:

    HTTP → Port 80

---

# 5. Test Blue Servers

Test Server 1:

    http://SERVER-1-PUBLIC-IP

Expected:

    Villa Agency Website

Test Server 2:

    http://SERVER-2-PUBLIC-IP

Expected:

    Villa Agency Website

Both Blue servers should display the same application.

---

# 6. Test Green Servers

Test Server 3:

    http://SERVER-3-PUBLIC-IP

Expected:

    Klassy Cafe Website

Test Server 4:

    http://SERVER-4-PUBLIC-IP

Expected:

    Klassy Cafe Website

Both Green servers should display the same application.

---

# 7. Target Group Health Check

Open:

    AWS Console
        ↓
    EC2
        ↓
    Target Groups

Open:

    Blue-TG

Expected:

    Server 1 → Healthy
    Server 2 → Healthy

Open:

    Green-TG

Expected:

    Server 3 → Healthy
    Server 4 → Healthy

---

# 8. Test Health Check

The configured health check is:

    Protocol: HTTP
    Port: 80
    Path: /

The ALB sends requests to the EC2 instances.

Expected:

    HTTP Response
          ↓
       Success
          ↓
       Healthy

If the server does not respond correctly:

    HTTP Failure
          ↓
       Unhealthy

---

# 9. Application Load Balancer Testing

Open:

    AWS Console
        ↓
    EC2
        ↓
    Load Balancers

Select:

    Blue-Green-ALB

Verify:

    State → Active

Copy the ALB DNS name.

Example:

    blue-green-alb-xxxxxxxx.ap-south-1.elb.amazonaws.com

Open:

    http://ALB-DNS-NAME

Expected:

    Villa Agency Website

This confirms that the ALB can route traffic to the Blue Target Group.

---

# 10. Test ALB Target Health

Open:

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

Then check:

    Green-TG
        ↓
    Targets

Expected:

    Server 3 → Healthy
    Server 4 → Healthy

---

# 11. Test HTTP to HTTPS Redirect

Open:

    http://your-domain.com

Expected behavior:

    HTTP :80
       ↓
    Redirect
       ↓
    HTTPS :443

The browser should automatically open:

    https://your-domain.com

The final connection should use HTTPS.

---

# 12. HTTPS Testing

Open:

    https://your-domain.com

Verify:

    ✓ Website loads
    ✓ HTTPS is enabled
    ✓ Certificate is valid
    ✓ Domain matches certificate
    ✓ No certificate warning is displayed

---

# 13. Verify ACM Certificate

Open:

    AWS Certificate Manager
        ↓
    Certificates

Verify:

    Status → Issued

Check:

    Domain Name
    Certificate Status
    Expiration
    Validation Method

The certificate should be associated with the ALB HTTPS listener.

---

# 14. Route 53 Testing

Open:

    Route 53
        ↓
    Hosted zones
        ↓
    Your Domain

Verify the A record.

Expected:

    Record Type: A
    Alias: Yes
    Target: Application Load Balancer

Test DNS from Windows:

    nslookup your-domain.com

Test DNS from Linux:

    nslookup your-domain.com

or:

    dig your-domain.com

---

# 15. Blue-Green Deployment Testing

Initially, production traffic is sent to Blue.

Expected:

    User
      ↓
    ALB
      ↓
    Blue-TG
      ↓
    Server 1 / Server 2
      ↓
    Villa Agency Website

Green remains available for testing.

---

# 16. Test Green Environment

Before switching traffic, verify:

    Server 3 → Healthy
    Server 4 → Healthy

Open the Green Target Group and verify the target health.

Expected:

    Green-TG

    Server 3 → Healthy
    Server 4 → Healthy

---

# 17. Blue-Green Traffic Switch

After testing Green, change the ALB listener rule/default action to forward production traffic to:

    Green-TG

Traffic becomes:

    User
      ↓
    ALB
      ↓
    Green-TG
      ↓
    Server 3 / Server 4
      ↓
    Klassy Cafe Website

---

# 18. Verify Green Production

Open:

    https://your-domain.com

Expected:

    Klassy Cafe Website

This confirms that production traffic has been moved from Blue to Green.

---

# 19. Blue-Green Rollback Testing

To test rollback, assume Green has a problem.

Example:

    Green
       |
       | Application problem
       v
    Rollback
       |
       v
    Blue

Change the ALB routing back to:

    Blue-TG

Then test:

    https://your-domain.com

Expected:

    Villa Agency Website

This confirms that the previous version can be restored.

---

# 20. Canary Deployment Testing

Canary deployment introduces Green gradually.

Example:

    Stage 1:

    Blue  → 90%
    Green → 10%

Monitor the application.

Check:

    Target health
    HTTP errors
    Response time
    Application behavior

If everything is healthy, continue.

---

# 21. Canary Stage 2

Increase the traffic:

    Blue  → 50%
    Green → 50%

Continue monitoring.

Verify that:

    Blue targets are healthy
    Green targets are healthy
    Application is responding correctly

---

# 22. Canary Stage 3

After successful validation:

    Blue  → 0%
    Green → 100%

Green is now serving all production traffic.

Test:

    https://your-domain.com

Expected:

    Green Application

---

# 23. Canary Rollback Testing

If Green fails during canary deployment:

    Stop increasing Green traffic

Then move traffic back to Blue.

Example:

    Before:

    Blue 50%
    Green 50%

    Rollback:

    Blue 100%
    Green 0%

Test:

    https://your-domain.com

Expected:

    Blue Application

---

# 24. High Availability Testing

Stop one Blue EC2 instance.

Example:

    Server 1 → Stopped
    Server 2 → Running

After the health check detects the failure:

    Server 1 → Unhealthy
    Server 2 → Healthy

The ALB should continue routing traffic to the healthy target.

Test:

    https://your-domain.com

Expected:

    Application continues to work

---

# 25. Green High Availability Testing

Stop Server 3.

Expected:

    Server 3 → Unhealthy
    Server 4 → Healthy

The ALB should stop sending new traffic to Server 3 and continue using Server 4.

---

# 26. Security Group Testing

Verify the ALB Security Group:

    HTTP  : 80  → 0.0.0.0/0
    HTTPS : 443 → 0.0.0.0/0

Verify the EC2 Security Group:

    HTTP : 80 → ALB-SG

SSH:

    SSH : 22 → My IP

Avoid unnecessary public inbound access.

---

# 27. End-to-End Testing

The final application flow should be:

    User
      ↓
    Domain
      ↓
    Route 53
      ↓
    ALB
      ↓
    HTTPS :443
      ↓
    Target Group
      ↓
    EC2
      ↓
    Apache
      ↓
    Website

Verify every layer.

---

# 28. Complete Testing Checklist

## Infrastructure

    [ ] Default VPC is available
    [ ] Required subnets are available
    [ ] Internet connectivity works
    [ ] EC2 instances are running
    [ ] EC2 status checks are passing

## EC2

    [ ] Apache is installed
    [ ] Apache is running
    [ ] Port 80 is listening
    [ ] Website files exist
    [ ] Website loads locally

## Security

    [ ] ALB Security Group allows port 80
    [ ] ALB Security Group allows port 443
    [ ] EC2 Security Group allows port 80 from ALB-SG
    [ ] SSH is restricted

## Target Groups

    [ ] Blue-TG exists
    [ ] Green-TG exists
    [ ] Server 1 is healthy
    [ ] Server 2 is healthy
    [ ] Server 3 is healthy
    [ ] Server 4 is healthy

## Load Balancer

    [ ] ALB is Active
    [ ] HTTP listener exists
    [ ] HTTPS listener exists
    [ ] Target Groups are configured
    [ ] Health checks are passing

## Route 53

    [ ] Hosted Zone exists
    [ ] Domain resolves
    [ ] A record exists
    [ ] Alias points to ALB

## HTTPS

    [ ] ACM certificate is Issued
    [ ] Certificate is attached to ALB
    [ ] HTTPS :443 works
    [ ] HTTP :80 redirects to HTTPS

## Deployment

    [ ] Blue environment works
    [ ] Green environment works
    [ ] Blue-Green switch works
    [ ] Canary deployment works
    [ ] Rollback works

## High Availability

    [ ] One server can be stopped
    [ ] ALB detects unhealthy target
    [ ] Traffic continues through healthy target

---

# 29. Expected Final Result

The completed project should provide:

    https://your-domain.com
              |
              v
          Route 53
              |
              v
      Application Load Balancer
              |
        +-----+-----+
        |           |
        v           v
      Blue        Green
       TG           TG
        |           |
    Server 1     Server 3
    Server 2     Server 4

Blue:

    Villa Agency Website

Green:

    Klassy Cafe Website

The deployment supports:

    Blue-Green Deployment
    Canary Deployment
    Health Checks
    HTTPS
    Traffic Shifting
    Rollback
    High Availability

---

# Troubleshooting Summary

## Website Not Loading

Check:

    EC2 status
    Apache status
    Port 80
    Security Group
    Route Table
    Internet Gateway

## Target Unhealthy

Check:

    Apache
    Port 80
    Health Check Path
    EC2 Security Group
    ALB Security Group

## HTTPS Not Working

Check:

    ACM Certificate
    Certificate Region
    HTTPS Listener
    Port 443
    Route 53 Record

## DNS Not Working

Check:

    Hosted Zone
    Name Servers
    A Record
    ALB Alias
    DNS Propagation

---

# Conclusion

Testing confirms that the AWS infrastructure, web servers, load balancer, DNS, HTTPS configuration, health checks, and deployment strategies are working together.

The project demonstrates how Blue-Green and Canary deployment strategies can reduce deployment risk and provide a reliable rollback mechanism.