variable "prefix" {
  type    = string
  default = "prowler-scanner"
}

variable "security_account_id" {
  type    = string
  default = "564033685323"
}

variable "account_ids" {
  type    = list(string)
  default = ["564033685323", "881042394954", "894243019954"]
}
variable "use_nat_gateway" {
  type    = bool
  default = false
}

variable "schedule_expression" {
  type    = string
  default = "cron(0 3 * * ? *)"
}