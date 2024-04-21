output "alb_arn" {
  description = "The Amazon Resource Name (ARN) of the ALB"
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer (ALB)"
  value       = module.alb.dns_name
}

output "alb_listener_arn" {
  description = "The ARN of the HTTPS listener for the ALB"
  value       = module.alb.listeners.https_listener.arn
}

output "alb_security_group_id" {
  description = "The ID of the security group associated with the ALB"
  value       = aws_security_group.alb.id
}

output "ecr_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = module.ecs.arn
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.name
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.this.arn
}

output "private_subnets" {
  description = "The IDs of the private subnets within the VPC"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The IDs of the public subnets within the VPC"
  value       = module.vpc.public_subnets
}

output "quest_acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = module.quest_acm.acm_certificate_arn
}

output "quest_repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.this.name
}

output "quest_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}