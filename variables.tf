variable "prefix" {
  type    = string
  default = "prowler-scanner"
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