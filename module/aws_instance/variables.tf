variable "instance_type" {
  description = "Value of the EC2 instance type"
  type        = string
  default     = "t2.micro"
}

output "instance_id" {
  value = [for instance in aws_instance.app_server : instance.id]#resource.aws_instance.app_server[*].id
}