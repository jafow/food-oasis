variable vpc_name {}
variable region {}
variable tags {
  default = {}
  type    = map
}
variable stage {}
variable namespace {}
variable cidr_block {}
variable availability_zones {
  type    = list(string)
  default = []
}

variable cluster_name {}

variable container_cpu {
  type    = number
  default = 256
}

variable container_memory {
  type    = number
  default = 512
}

variable task_name {}

variable app_domain_name {}
variable subject_alternative_names {
  default = []
  type    = list(string)
}

variable ttl {
  default = 60
}

variable hosted_zone_name {}
variable hosted_zone_id {}

variable enable_tls {
  default = false
}

variable desired_count {}

variable container_name {}
variable container_port {}

variable db_instance_class {
  default = "db.t2.small"
}
variable db_username {}
variable db_password {}
variable account_id {}

variable ssh_public_key_names {
  type    = list(string)
  default = []
}

variable bastion_instance_type {
  default = "t2.micro"
}

variable public_key {}

variable key_name {
  default = "bastion"
}

variable use_external_dns_hosted_zone {
  default = false
}
