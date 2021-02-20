variable "component" {}
variable "deployment_identifier" {}

variable "organization_id" {}

variable "existing_teams" {
  type = list(object({
    name: string,
    usernames: list(string)
    role_names: list(string)
  }))
}