# Variables for Server VPC in Mumbai
variable "server_mumbai_vpc_id" {
  description = "VPC ID for the Mumbai server"
  type        = string
}

variable "server_mumbai_subnet_ids" {
  description = "List of subnet IDs for the Mumbai server VPC"
  type        = list(string)
}

# Variables for Server VPC in Virginia
variable "server_virginia_vpc_id" {
  description = "VPC ID for the Virginia server"
  type        = string
}

variable "server_virginia_subnet_ids" {
  description = "List of subnet IDs for the Virginia server VPC"
  type        = list(string)
}

# Variables for Database VPC in Mumbai
variable "mumbai_db_vpc_id" {
  description = "VPC ID for the Mumbai database"
  type        = string
}

variable "mumbai_db_subnet_ids" {
  description = "List of subnet IDs for the Mumbai database VPC"
  type        = list(string)
}

# Variables for Database VPC in Virginia
variable "virginia_db_vpc_id" {
  description = "VPC ID for the Virginia database"
  type        = string
}

variable "virginia_db_subnet_ids" {
  description = "List of subnet IDs for the Virginia database VPC"
  type        = list(string)
}

# Variables for Mumbai Server Route Table
variable "server_mumbai_route_table_id" {
  description = "Route table ID for the Mumbai server VPC"
  type        = string
}

# Variables for Virginia Server Route Table
variable "server_virginia_route_table_id" {
  description = "Route table ID for the Virginia server VPC"
  type        = string
}

# Variables for Mumbai DB Route Table
variable "mumbai_db_route_table_id" {
  description = "Route table ID for the Mumbai database VPC"
  type        = string
}

# Variables for Virginia DB Route Table
variable "virginia_db_route_table_id" {
  description = "Route table ID for the Virginia database VPC"
  type        = string
}

# Variables for Mumbai Server Security Group
variable "server_mumbai_sg_id" {
  description = "Security group ID for the Mumbai server"
  type        = string
}

# Variables for Virginia Server Security Group
variable "server_virginia_sg_id" {
  description = "Security group ID for the Virginia server"
  type        = string
}

# Variables for Mumbai Database Security Group
variable "mumbai_db_sg_id" {
  description = "Security group ID for the Mumbai database"
  type        = string
}

# Variables for Virginia Database Security Group
variable "virginia_db_sg_id" {
  description = "Security group ID for the Virginia database"
  type        = string
}

