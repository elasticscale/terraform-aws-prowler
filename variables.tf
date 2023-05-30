variable "security_account_id" {
  type    = string
}
variable "account_ids" {
  type    = list(string)
}

variable "prefix" {
  type    = string
  default = "prowler-scanner"
}
variable "use_nat_gateway" {
  type    = bool
  default = false
}

variable "schedule_expression" {
  type    = string
  default = "cron(0 3 * * ? *)"
}