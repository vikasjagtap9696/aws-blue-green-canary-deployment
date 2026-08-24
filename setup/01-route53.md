# Route 53 Domain Setup

## What is Amazon Route 53?

Amazon Route 53 is an AWS DNS service used to manage domain names and DNS records.

In this project, Route 53 is used to connect the domain with the Application Load Balancer.

## Domain

Example domain:

    vikascloud.online

Use your own domain if you are following this project yourself.

## Step 1 - Open Route 53

1. Login to AWS Management Console.
2. Search for Route 53.
3. Open Amazon Route 53.
4. Go to Hosted zones.

## Step 2 - Create a Public Hosted Zone

Go to:

    Route 53
        ↓
    Hosted zones
        ↓
    Create hosted zone

Enter your domain name.

Example:

    vikascloud.online

Select:

    Type: Public hosted zone

Click Create hosted zone.

## Step 3 - Route 53 Records

After creating the Hosted Zone, Route 53 creates default DNS records.

Common records:

    NS
    SOA

### NS Record

NS means Name Server.

Name servers tell the internet which DNS servers are responsible for the domain.

### SOA Record

SOA means Start of Authority.

It contains information about the DNS zone.

## Step 4 - Domain Purchased Outside AWS

If your domain was purchased from another provider:

1. Open your domain provider.
2. Go to DNS or Name Server settings.
3. Copy the Route 53 name servers from your Hosted Zone.
4. Replace the existing name servers with the Route 53 name servers.
5. Save the changes.

Example:

    ns-xxxx.awsdns-xx.com
    ns-xxxx.awsdns-xx.net
    ns-xxxx.awsdns-xx.org
    ns-xxxx.awsdns-xx.co.uk

If the domain was registered through Route 53, this step is normally handled by AWS.

## Step 5 - Connect Route 53 to Application Load Balancer

After creating the Application Load Balancer, create an A record in Route 53.

Go to:

    Route 53
        ↓
    Hosted zones
        ↓
    Your Domain
        ↓
    Create record

Configure:

    Record name: Leave empty
    Record type: A
    Alias: Yes

For the Alias target, select:

    Application Load Balancer

Select the correct AWS Region and your Application Load Balancer.

Click Create records.

## Step 6 - Final Traffic Flow

The final traffic flow will be:

    User
      ↓
    Domain
      ↓
    Route 53
      ↓
    Application Load Balancer
      ↓
    Target Group
      ↓
    EC2 Servers

## Step 7 - DNS Testing

### Windows

    nslookup vikascloud.online

### Linux

    nslookup vikascloud.online

or:

    dig vikascloud.online

You can also test the domain from a browser:

    http://vikascloud.online

After HTTPS configuration:

    https://vikascloud.online

## Important Note

The Application Load Balancer must be created before creating the final Route 53 Alias record pointing to the ALB.

The complete project flow is:

    Route 53
        ↓
    VPC
        ↓
    EC2
        ↓
    Target Groups
        ↓
    Application Load Balancer
        ↓
    ACM Certificate
        ↓
    Route 53 Alias Record
        ↓
    HTTPS Application

## Result

After completing the project, users can access the application using:

    https://your-domain.com

instead of directly using an EC2 public IP.

## Next Step

Next, configure the AWS VPC, subnets, Internet Gateway and Route Table.

File:

    setup/02-vpc.md