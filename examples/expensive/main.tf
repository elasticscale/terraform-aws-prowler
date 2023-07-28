// this module scans the accounts under account_ids you need to create a role named prowler-expensive-scanrole in every account
// the role needs to have a trust relationship with the security account
module "prowler" {
  source = "../../"
  security_account_id = "496492991232"
  account_ids         = ["496492991232", "496492991251"]
  schedule_expression = "rate(1 day)"
  use_nat_gateway = true
  prefix = "prowler-expensive"
}