# HTTPS Configuration Using AWS Certificate Manager

## Overview

HTTPS is used to secure communication between users and the application.

In this project:

- Route 53 manages the domain
- AWS Certificate Manager provides the SSL/TLS certificate
- Application Load Balancer handles HTTPS traffic
- HTTP traffic is redirected to HTTPS

The final traffic flow is:

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

# What is HTTPS?

HTTPS means:

    HyperText Transfer Protocol Secure

HTTPS encrypts communication between the user's browser and the application.

HTTP:

    http://your-domain.com

HTTPS:

    https://your-domain.com

HTTPS is recommended for production applications.

---

# What is ACM?

ACM means:

    AWS Certificate Manager

ACM is an AWS service used to create and manage SSL/TLS certificates.

In this project, ACM provides the certificate used by the Application Load Balancer.

---

# HTTPS Architecture

    User
      |
      | HTTPS :443
      v
    Application Load Balancer
      |
      | HTTP :80
      v
    EC2 Servers

The SSL/TLS connection is terminated at the Application Load Balancer.

---

# Prerequisites

Before creating the certificate, make sure:

    ✓ Domain is available
    ✓ Route 53 Hosted Zone is created
    ✓ Application Load Balancer is created
    ✓ ALB is Active
    ✓ Route 53 DNS is configured

Example domain:

    vikascloud.online

Use your own domain if you are following this project yourself.

---

# Step 1 - Open AWS Certificate Manager

Login to:

    AWS Management Console

Search for:

    Certificate Manager

Open:

    AWS Certificate Manager (ACM)

Make sure you are in the same AWS Region as the Application Load Balancer.

For example:

    ap-south-1

The ACM certificate must be created in the same Region as the ALB.

---

# Step 2 - Request a Certificate

Go to:

    ACM
      ↓
    Certificates
      ↓
    Request

Select:

    Request a public certificate

Click:

    Next

---

# Step 3 - Enter Domain Name

Enter your domain.

Example:

    vikascloud.online

You can also include:

    *.vikascloud.online

if you want the certificate to cover subdomains.

For example:

    www.vikascloud.online
    app.vikascloud.online

A wildcard certificate can cover these subdomains.

---

# Step 4 - Select Validation Method

Select:

    DNS validation

DNS validation is recommended because it can be automated through Route 53.

Click:

    Request

---

# Step 5 - Validate the Certificate

Open the certificate details.

The certificate status may initially show:

    Pending validation

Expand the domain validation section.

If the domain is hosted in Route 53, ACM can provide an option to create the DNS validation record automatically.

Select:

    Create records in Route 53

Confirm the hosted zone.

Create the required validation record.

---

# Step 6 - Wait for Certificate Validation

After the DNS validation record is created, ACM verifies ownership of the domain.

The status should change:

    Pending validation

to:

    Issued

The validation time can vary.

Do not continue until the certificate is issued.

---

# Step 7 - Open the Application Load Balancer

Go to:

    EC2
      ↓
    Load Balancers
      ↓
    Select Blue-Green-ALB

Open:

    Listeners and rules

---

# Step 8 - Create HTTPS Listener

Click:

    Add listener

Configure:

    Protocol:
    HTTPS

    Port:
    443

---

# Step 9 - Select ACM Certificate

Under certificate selection:

    Certificate source:
    From ACM

Select the certificate created earlier.

Example:

    vikascloud.online

Click:

    Add listener

---

# Step 10 - Configure HTTPS Default Action

The HTTPS listener should forward traffic to the appropriate Target Group.

Example:

    HTTPS :443
          |
          v
    Blue-TG

Initially, Blue can be used as the production Target Group.

Later, traffic can be shifted to Green during the deployment process.

---

# Step 11 - Configure HTTP Redirect

Now configure the HTTP listener.

Open:

    ALB
      ↓
    Listeners and rules
      ↓
    HTTP :80
      ↓
    Edit listener

Change the default action to:

    Redirect to HTTPS

Configure:

    Protocol:
    HTTPS

    Port:
    443

    Status code:
    301 - Permanent Redirect

Save the changes.

---

# HTTP to HTTPS Flow

The final flow is:

    http://vikascloud.online
              |
              v
          HTTP :80
              |
              v
        301 Redirect
              |
              v
        HTTPS :443
              |
              v
             ALB
              |
              v
         Target Group
              |
              v
             EC2

---

# Step 12 - Configure Route 53 Alias Record

After the ALB and HTTPS listener are configured, make sure the domain points to the ALB.

Go to:

    Route 53
      ↓
    Hosted zones
      ↓
    Your Domain
      ↓
    Create record

Configure:

    Record type:
    A

    Alias:
    Yes

Select:

    Application Load Balancer

Choose:

    Blue-Green-ALB

Click:

    Create records

---

# Step 13 - Test HTTPS

Open the domain in a browser:

    https://vikascloud.online

The browser should establish a secure HTTPS connection.

Check that:

    ✓ Website loads
    ✓ HTTPS is enabled
    ✓ Certificate is valid
    ✓ Domain matches the certificate
    ✓ No certificate warning is displayed

---

# Step 14 - Test HTTP Redirect

Open:

    http://vikascloud.online

The browser should redirect to:

    https://vikascloud.online

The final URL should use:

    HTTPS

---

# Step 15 - Verify Certificate

Open:

    AWS Certificate Manager
      ↓
    Certificates

The certificate should show:

    Status:
    Issued

Check:

    Domain name
    Expiration date
    Validation status

---

# ACM Certificate Renewal

ACM-managed public certificates can be automatically renewed when the certificate is eligible for automatic renewal and the required validation configuration remains available.

For DNS validation, keep the ACM validation DNS record in place.

Do not delete the validation record if you want automatic renewal to continue.

---

# Important Difference: ACM Certificate vs Imported Certificate

## ACM-managed certificate

AWS manages the renewal process for eligible ACM certificates.

Example:

    Certificate
        |
        v
    ACM
        |
        v
    Automatic renewal

## Imported certificate

If a certificate is imported into ACM from an external Certificate Authority, AWS does not automatically renew the imported certificate.

The certificate must be renewed externally and imported again when required.

---

# Security Best Practices

Use:

    HTTPS :443

for application traffic.

Redirect:

    HTTP :80
        ↓
    HTTPS :443

Avoid sending sensitive application data over plain HTTP.

Use a valid certificate for the actual domain.

Keep DNS validation records required for ACM renewal.

---

# Troubleshooting

## Certificate is Pending Validation

Check:

    1. Domain name is correct
    2. DNS validation record exists
    3. Hosted Zone is correct
    4. Name servers are correctly configured
    5. Domain DNS has propagated

---

## HTTPS Listener Cannot Be Created

Check:

    1. ACM certificate status is Issued
    2. Certificate is in the same Region as the ALB
    3. Certificate domain matches the requested domain

---

## Website Does Not Open on HTTPS

Check:

    1. ALB Security Group allows port 443
    2. HTTPS listener exists
    3. ACM certificate is attached
    4. Target Group has healthy targets
    5. Route 53 points to the ALB

---

## HTTP Does Not Redirect

Check:

    1. HTTP listener is running on port 80
    2. Listener default action is Redirect
    3. Redirect destination is HTTPS
    4. Redirect port is 443

---

# Final HTTPS Architecture

    Internet
       |
       v
    Route 53
       |
       v
    Application Load Balancer
       |
       +-----------------------+
       |                       |
    HTTP :80               HTTPS :443
       |                       |
       |                       |
       +---- Redirect ----------+
                               |
                               v
                          ACM Certificate
                               |
                               v
                         Target Group
                         /           \
                        /             \
                       v               v
                    Blue             Green
                     |                 |
                 Server 1/2        Server 3/4

---

# Expected Result

After completing this configuration:

    http://your-domain.com
              |
              v
        Redirect to HTTPS
              |
              v
    https://your-domain.com
              |
              v
    Application Load Balancer
              |
              v
        Target Group
              |
              v
        EC2 Application

The application is now accessible securely using HTTPS.

---

# Next Step

After configuring HTTPS, configure the complete Blue-Green and Canary deployment process.

Next file:

    setup/08-blue-green-canary.md