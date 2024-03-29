variable "component" {}
variable "deployment_identifier" {}

variable "organization_id" {}

variable "existing_teams" {
  type = list(object({
    id: string,
    name: string,
    usernames: list(string)
    role_names: list(string)
  }))
  default = null
}

variable "dedicated_teams" {
  type = list(object({
    name_suffix: string,
    usernames: list(string)
    role_names: list(string)
  }))
  default = null
}

variable "ip_access_list" {
  type = list(object({
    type: string,
    value: string,
    comment: string
  }))
  default = null
}

variable "database_users" {
  type = list(object({
    username: string,
    password: string,
    roles: list(object({
      role_name: string,
      database_name: string,
      collection_name: string
    })),
    labels: map(string),
    scopes: list(object({
      type: string,
      name: string
    }))
  }))
  default = null
}
