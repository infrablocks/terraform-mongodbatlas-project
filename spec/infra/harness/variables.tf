variable "component" {}
variable "deployment_identifier" {}

variable "organization_id" {}

variable "existing_teams" {
  type = list(object({
    name: string,
    usernames: list(string)
    roles: list(string)
  }))
}

variable "dedicated_teams" {
  type = list(object({
    name_suffix: string,
    usernames: list(string)
    roles: list(string)
  }))
}

variable "ip_access_list" {
  type = list(object({
    type: string,
    value: string,
    comment: string
  }))
}
