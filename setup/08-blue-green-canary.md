# Blue-Green and Canary Deployment

## Overview

This project demonstrates two application deployment strategies:

- Blue-Green Deployment
- Canary Deployment

The purpose is to release a new application version with reduced downtime and controlled traffic.

---

# Environment Design

The project has two environments.

## Blue Environment

The Blue environment represents the current application version.

    Blue-TG
       |
       +-- Server 1
       +-- Server 2

Application:

    Villa Agency Website

---

## Green Environment

The Green environment represents the new application version.

    Green-TG
       |
       +-- Server 3
       +-- Server 4

Application:

    Klassy Cafe Website

---

# Complete Architecture

    User
      |
      v
    Route 53
      |
      v
    HTTPS :443
      |
      v
    Application Load Balancer
      |
      +--------------------------+
      |                          |
      v                          v
    Blue-TG                    Green-TG
      |                          |
    +---+---+                  +---+---+
    |       |                  |       |
    v       v                  v       v
 Server 1 Server 2          Server 3 Server 4
    |       |                  |       |
    +---+---+                  +---+---+
        |                          |
    Villa Website             Cafe Website

---

# What is Blue-Green Deployment?

Blue-Green Deployment uses two separate application environments.

The Blue environment contains the current production version.

The Green environment contains the new application version.

The new version can be tested in Green before production traffic is moved.

---

# Blue-Green Deployment Flow

## Step 1 - Blue is Production

Initially, production traffic is sent to Blue.

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

Blue serves:

    Villa Agency Website

---

## Step 2 - Deploy New Version to Green

The new application version is deployed to:

    Server 3
    Server 4

These servers belong to:

    Green-TG

Green serves:

    Klassy Cafe Website

At this stage, Green can be tested without moving normal production traffic.

---

# Step 3 - Test Green

Before shifting production traffic, verify:

    ✓ Server 3 is running
    ✓ Server 4 is running
    ✓ Apache is running
    ✓ Target Group is healthy
    ✓ Website is working
    ✓ ALB can reach Green targets

Check the Green Target Group:

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

# Step 4 - Switch Production Traffic

After Green has been successfully tested, production traffic can be moved from Blue to Green.

Before:

    ALB
      |
      v
    Blue-TG
      |
      +-- Server 1
      +-- Server 2

After:

    ALB
      |
      v
    Green-TG
      |
      +-- Server 3
      +-- Server 4

Green is now the production environment.

---

# Rollback

One of the main advantages of Blue-Green Deployment is fast rollback.

If Green has a problem:

    Green
      |
      | Application problem
      v
    Rollback
      |
      v
    Blue
      |
      v
    Production

The ALB can be changed to forward production traffic back to Blue.

---

# Why Keep Blue Available?

After moving traffic to Green, do not immediately delete Blue.

Keep Blue available during the validation period.

This provides a quick rollback option if:

    Application errors
    Server errors
    Configuration problems
    Unexpected behavior
    Performance problems

are detected.

---

# What is Canary Deployment?

Canary Deployment gradually introduces a new application version to users.

Instead of sending 100% of traffic to Green immediately, only a small percentage of traffic is sent to Green.

Example:

    Blue  → 90%
    Green → 10%

The application is monitored before increasing Green traffic.

---

# Canary Deployment Strategy

## Stage 1 - 90/10

Start with:

    Blue  → 90%
    Green → 10%

Monitor:

    HTTP 5xx errors
    Target health
    Response time
    Application behavior
    User experience

If the application is healthy, continue.

---

# Stage 2 - 50/50

Increase Green traffic:

    Blue  → 50%
    Green → 50%

Continue monitoring the application.

If problems occur, reduce Green traffic or move traffic back to Blue.

---

# Stage 3 - 0/100

After successful testing:

    Blue  → 0%
    Green → 100%

Green becomes the main production environment.

---

# Canary Flow

    Start

      |
      v

    Blue 90%
    Green 10%

      |
      v

    Monitor

      |
      v

    Blue 50%
    Green 50%

      |
      v

    Monitor

      |
      v

    Blue 0%
    Green 100%

      |
      v

    Green Production

---

# Canary Rollback

If problems occur during canary deployment:

    Green traffic
          |
          v
      Reduce traffic
          |
          v
      Send traffic
        back to
          |
          v
        Blue

Example:

    Before problem:

    Blue 50%
    Green 50%

    After rollback:

    Blue 100%
    Green 0%

This minimizes the impact of a failed release.

---

# Traffic Management

The Application Load Balancer is responsible for routing traffic.

The target groups represent the application environments:

    Blue-TG
        |
        +-- Current Version

    Green-TG
        |
        +-- New Version

Traffic can be controlled using ALB listener rules and routing configuration.

---

# Important ALB Concept

A standard ALB listener forwards traffic according to its listener rules.

For simple Blue-Green deployment:

    HTTPS :443
        |
        v
    Blue-TG

When the new version is ready:

    HTTPS :443
        |
        v
    Green-TG

For weighted canary routing, configure routing using supported ALB rule actions and target group weights.

Example concept:

    HTTPS :443
         |
         v
      ALB Rule
         |
      +--+-----------+
      |              |
      v              v
   Blue-TG        Green-TG
     90%             10%

---

# Blue-Green vs Canary

| Feature | Blue-Green | Canary |
|---|---|---|
| Environments | Two | Usually two |
| Traffic Shift | Fast switch | Gradual |
| Rollback | Fast | Gradual or immediate |
| Risk | Lower than direct deployment | Very low when gradual |
| Testing | New environment before switch | Real traffic gradually |
| Main Goal | Fast release and rollback | Controlled release |

---

# Blue-Green Deployment Example

Current production:

    Blue
    Villa Agency

New version:

    Green
    Klassy Cafe

Production initially:

    100% Blue

After validation:

    100% Green

If Green fails:

    100% Blue

---

# Canary Deployment Example

Initial:

    Blue 90%
    Green 10%

After successful monitoring:

    Blue 50%
    Green 50%

Final:

    Blue 0%
    Green 100%

---

# Monitoring During Deployment

During Blue-Green or Canary deployment, monitor:

    Target health
    HTTP 4xx errors
    HTTP 5xx errors
    Response time
    EC2 status
    Apache status
    Application behavior
    ALB metrics

AWS CloudWatch can be used for advanced monitoring.

---

# Failure Scenario

Suppose Green Server 3 becomes unhealthy.

Before:

    Green-TG

    Server 3 → Healthy
    Server 4 → Healthy

After failure:

    Server 3 → Unhealthy
    Server 4 → Healthy

The ALB should stop sending new traffic to the unhealthy target.

If the Green environment is not reliable, traffic can be returned to Blue.

---

# Complete Deployment Process

    1. Blue is production
            |
            v
    2. Deploy new version to Green
            |
            v
    3. Verify Green servers
            |
            v
    4. Verify Green Target Group
            |
            v
    5. Test Green application
            |
            v
    6. Start Canary deployment
            |
            v
    7. Send small percentage of traffic to Green
            |
            v
    8. Monitor application
            |
            +------ Problem ------+
            |                      |
            |                      v
            |                  Rollback
            |                      |
            |                      v
            |                     Blue
            |
            v
    9. Increase Green traffic
            |
            v
    10. Green receives 100% traffic
            |
            v
    11. Green becomes production
            |
            v
    12. Keep Blue available temporarily
            |
            v
    13. Remove old Blue environment after validation

---

# Testing Checklist

Before switching traffic:

    [ ] Green Server 3 is running
    [ ] Green Server 4 is running
    [ ] Apache is running
    [ ] Green Target Group is healthy
    [ ] Website is accessible
    [ ] ALB health checks are passing
    [ ] HTTPS is working
    [ ] Route 53 is resolving correctly

During canary deployment:

    [ ] 10% Green traffic works
    [ ] No major errors
    [ ] Target health is healthy
    [ ] Response time is acceptable
    [ ] 50% Green traffic works
    [ ] Final 100% Green traffic works

After deployment:

    [ ] Green is serving production traffic
    [ ] Application is healthy
    [ ] Blue is available for rollback
    [ ] Old resources are removed only after validation

---

# Rollback Checklist

If Green fails:

    1. Stop increasing Green traffic.
    2. Check ALB target health.
    3. Check EC2 instances.
    4. Check Apache.
    5. Check application logs.
    6. Move traffic back to Blue.
    7. Verify Blue health.
    8. Investigate the Green environment.
    9. Fix the problem.
    10. Test Green again before retrying deployment.

---

# Production Improvements

This project demonstrates the deployment concept using EC2 and ALB.

A production-ready implementation can be improved with:

    Auto Scaling Groups
    Launch Templates
    CloudWatch
    CloudWatch Alarms
    AWS WAF
    AWS Systems Manager
    IAM least privilege
    Terraform
    AWS CloudFormation
    GitHub Actions
    CI/CD Pipeline
    Docker
    Amazon ECR
    Amazon ECS
    Kubernetes

---

# Final Architecture

                            Internet
                             |
                             v
                         Route 53
                             |
                             v
                     HTTPS :443
                             |
                             v
              Application Load Balancer
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
             Blue-TG                  Green-TG
                 |                       |
            +----+----+             +----+----+
            |         |             |         |
            v         v             v         v
         Server 1  Server 2      Server 3  Server 4
           Blue      Blue         Green      Green
            |         |             |         |
            +----+----+             +----+----+
                 |                       |
          Villa Agency              Klassy Cafe

---

# Project Outcome

This project demonstrates how AWS can be used to build a highly available web application deployment with:

    ✓ EC2
    ✓ Default VPC
    ✓ Multiple Availability Zones
    ✓ Security Groups
    ✓ Application Load Balancer
    ✓ Target Groups
    ✓ Route 53
    ✓ AWS Certificate Manager
    ✓ HTTPS
    ✓ Health Checks
    ✓ Blue-Green Deployment
    ✓ Canary Deployment
    ✓ Traffic Shifting
    ✓ Rollback Strategy

The project provides a practical understanding of how modern DevOps deployment strategies can be implemented using AWS services.