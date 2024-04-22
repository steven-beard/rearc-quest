<p align="center">
  <img src="./assets/Logo.png" alt="Quest Logo">
</p>


# Quest Cloud Architecture Guide

## Table of Contents
- [Quest Cloud Architecture Guide](#quest-cloud-architecture-guide)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
    - [Purpose of the Document](#purpose-of-the-document)
    - [Intended Audience](#intended-audience)
  - [High-Level Overview](#high-level-overview)
  - [Architecture Overview](#architecture-overview)
    - [Two-tiered Virtual Private Cloud (VPC)](#two-tiered-virtual-private-cloud-vpc)
    - [Amazon ECS on AWS Fargate](#amazon-ecs-on-aws-fargate)
    - [Route 53 Hosted Zone](#route-53-hosted-zone)
    - [Elastic Container Registry (ECR)](#elastic-container-registry-ecr)
    - [ECS Services running Node.js](#ecs-services-running-nodejs)
    - [AWS Certificate Manager (ACM)](#aws-certificate-manager-acm)
  - [Security and Monitoring](#security-and-monitoring)
    - [Security Groups](#security-groups)
    - [Monitoring and Logging](#monitoring-and-logging)
  - [Suggested Imporvements](#suggested-imporvements)
  - [Appendix](#appendix)
    - [Additional Resources](#additional-resources)
  

## Introduction

### Purpose of the Document

This document aims to provide a comprehensive guide to the cloud architecture implemented for the Quest application. It details the components and security measures.

### Intended Audience

This document is intended for system administrators, developers, and IT management personnel who are involved in the maintenance, deployment, and scaling of the cloud infrastructure.

## High-Level Overview

The architecture described here leverages AWS services to create a robust, scalable, and secure environment for running our Node.js applications using Amazon ECS on AWS Fargate using Terraform.
## Architecture Overview

### Two-tiered Virtual Private Cloud (VPC)

- **Purpose**: Isolates resources in separate subnets for security and performance (public and private subnets).
- **Components**: Includes subnets, route tables, internet gateways, and  NAT gateways for outbound internet access from private subnets.  

### Amazon ECS on AWS Fargate

- **Purpose**: Runs containerized Node.js applications without the need to manage servers or clusters.
- **Components**: Task definitions, services, and clusters that manage the lifecycle of applications.

### Route 53 Hosted Zone

- **Purpose**: Manages DNS for the domain, improving routing and domain management.
- **Components**: DNS records including A, CNAME, and Alias records.

### Elastic Container Registry (ECR)

- **Purpose**: Stores, manages, and deploy Docker container images.
- **Components**: Repositories for each type of application component.

### ECS Services running Node.js

- **Purpose**: Handles the deployment and operation of Node.js applications.
- **Components**: ECS tasks that pull, nessacary secrets from Secrets manager, the current image from ECR and run as defined in the task definition.

### AWS Certificate Manager (ACM)

- **Purpose**: Manages SSL/TLS certificates for securely hosting your websites on AWS services like Elastic Load Balancer (ELB) and Amazon CloudFront.
- **Components**:
  - **ACM Certificates**: Handles the provision, management, and deployment of SSL/TLS certificates.
  - **Integration**: Seamlessly integrates with AWS services to enable HTTPS for a secure connection.
  - **Automatic Renewal**: Automatically renews managed certificates, reducing the manual overhead and risk of service interruption.


## Security and Monitoring

### Security Groups

- **VPC Security Group**: Current default security group is not utilized
- **ALB Security Group**: Controls inbound and outbound traffic to the Application Load Balancer, ensuring secure communication with ECS services on port 80 (redirect) and port 443.
- **ECS Security Group**: Restricts incoming traffic to the ECS instances, allowing only the necessary communication to the service on port 3000.
- **Other security measures**: IAM roles ensure that services have minimal permissions needed to perform their tasks securely.

### Monitoring and Logging

- AWS CloudWatch monitors and logs system operations, providing insights and alerts for operational issues.

## Suggested Imporvements
  - Remove NAT gateways and use vpc endpoints
  - Stand up a CloudFront Distribution with WAF and point that to the ALB. Point the A record to the CloudFront Distribution
  - Add Web Application Firewall
  - Enable Guard Duty
  - Create CI/CD utilizing one of the following
    - Terraform Cloud
    - Spacelift
    - GitHub Actions
  - Add versioning to the quest image
  - Create multiple ECS cluster for use in development, stage and so on. Preferably using a multi-account AWS Org.

## Appendix

### Additional Resources

- [Screenshot of running application](./assets/Screenshot.png)
- [Total Cost of Ownership](./assets/quest-tco.pdf)
- [Architecture Diagram](./assets/quest.png)
- [Running Application](https://rearc.sbeard.cloud/) **Will be terminated on 26 April 2024**
