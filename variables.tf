variable "prefix" {
  type    = string
  default = "prowler-scanner"
}

variable "security_account_id" {
  type = string
  default = "564033685323"
}

variable "account_ids" {
  type    = list(string)
  default = ["564033685323"]
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "use_nat_gateway" {
  type = bool
  default = false
}