// this module scans the account its run in (you still need to create the scanrole manually in 564033685323)
module "prowler" {
  source = "../../"
  security_account_id = "496492991232"
  account_ids         = ["496492991232"]
  schedule_expression = "rate(1 day)"
  use_nat_gateway = false
  prefix = "prowler-cheap"
}