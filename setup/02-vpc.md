# 02 - VPC and Network Setup

## Overview

For this project, I used the **AWS Default VPC** instead of creating a new custom VPC.

The Default VPC already provides the basic networking required to launch EC2 instances.

It includes:

- VPC
- Subnets
- Route Table
- Internet Gateway
- Default Network ACL
- Default Security Group

This makes the setup simpler and is suitable for this learning project.

---

## Step 1 - Open VPC

Login to the AWS Management Console.

Go to:

    AWS Console
        ↓
    VPC
        ↓
    Your VPCs

Find the VPC marked as:

    Default VPC: Yes

Select the Default VPC.

---

## Step 2 - Check Default VPC CIDR

Open the Default VPC and check its IPv4 CIDR.

The AWS Default VPC commonly uses:

    172.31.0.0/16

However, always use the CIDR shown in your AWS Console because it may be different depending on the environment.

---

## Step 3 - Check Availability Zones

Go to:

    VPC
        ↓
    Subnets

The Default VPC already contains subnets in multiple Availability Zones.

For this project, EC2 instances are deployed across two Availability Zones.

Example:

    Availability Zone 1a
        |
        +-- Server 1
        +-- Server 2

    Availability Zone 1b
        |
        +-- Server 3
        +-- Server 4

The exact Availability Zone names depend on the AWS Region.

---

## Step 4 - Check Internet Gateway

The Default VPC already has an Internet Gateway attached.

Go to:

    VPC
        ↓
    Internet gateways

Find the Internet Gateway associated with the Default VPC.

The Internet Gateway provides internet connectivity when the subnet route table and Security Groups allow the traffic.

---

## Step 5 - Check Route Table

Go to:

    VPC
        ↓
    Route tables

Find the route table associated with the Default VPC subnets.

A public route normally contains:

    Destination: 0.0.0.0/0
    Target: Internet Gateway

This route allows internet-bound traffic through the Internet Gateway.

---

## Step 6 - Select Subnets for EC2

For this project, select subnets from two different Availability Zones.

Example:

    AZ 1a
    ├── Subnet 1 → Server 1
    └── Subnet 2 → Server 2

    AZ 1b
    ├── Subnet 3 → Server 3
    └── Subnet 4 → Server 4

The exact subnet CIDR ranges should be taken from the AWS Console.

---

## Step 7 - Public IPv4 Address

When launching the EC2 instances, enable:

    Auto-assign Public IP: Enable

This allows the EC2 instances to receive public IPv4 addresses.

Public IP addresses are useful for testing the websites directly during the project.

---

## Network Architecture

The project uses the AWS Default VPC:

    AWS Region
        |
        v
    Default VPC
        |
        +----------------------+
        |                      |
        v                      v
    Availability Zone 1a   Availability Zone 1b
        |                      |
        +-- Server 1           +-- Server 3
        +-- Server 2           +-- Server 4

The Application Load Balancer is also deployed across multiple Availability Zone subnets.

---

## Why Did I Use the Default VPC?

I used the Default VPC because this is a learning and practical project.

The Default VPC already provides:

- VPC
- Subnets
- Internet Gateway
- Route Tables
- Network ACL
- Basic networking configuration

Therefore, I did not need to manually create a new VPC for this project.

---

## Important

This project documentation describes the actual setup used in the project.

Therefore, no custom VPC or custom CIDR is created here.

Always verify the following values directly from the AWS Console:

    VPC ID
    VPC CIDR
    Subnet ID
    Subnet CIDR
    Availability Zone
    Route Table
    Internet Gateway

---

## Final Network Flow

    Internet
       |
       v
    Internet Gateway
       |
       v
    Default VPC
       |
       +----------------------+
       |                      |
       v                      v
    AZ 1a                  AZ 1b
       |                      |
       v                      v
    EC2 1                  EC2 3
    EC2 2                  EC2 4
       \                      /
        \                    /
         v                  v
          Application Load Balancer

---

## Next Step

After verifying the Default VPC and selecting the required subnets, configure the Security Groups.

Next file:

    setup/03-security-group.md