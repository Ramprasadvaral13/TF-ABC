variable "vpc-cidr" {
    type = string
  
}

variable "az" {
    type = string
}

variable "subnets" {
    description = "subnets to create"
    type = map(object({
        cidr = string
        az = string
        public = bool

    }))
}

variable "route-cidr" {
    type = string
}

variable "instance" {
    type = string
  
}

variable "ami" {
    type = string
}

variable "region" {
    type = string
}