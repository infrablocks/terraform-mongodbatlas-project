variable "component" {
  description = "The component this project will contain."
  type        = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "organization_id" {
  type        = string
  description = "The ID of the organization within which to create the project."
}

variable "existing_teams" {
  type        = list(object({
    id: string,
    role_names: list(string)
  }))
  description = "A list of existing teams to be associated with the project with corresponding roles."
  default     = []
}
variable "dedicated_teams" {
  type        = list(object({
    name_suffix: string,
    usernames: list(string),
    role_names: list(string)
  }))
  description = "A list of dedicated teams to be created and associated with the project with corresponding roles."
  default     = []
}

variable "ip_access_list" {
  type        = list(object({
    type: string,
    value: string,
    comment: string
  }))
  description = "A list of IP access list entries to add to the project."
  default     = []
}

variable "database_users" {
  type        = list(object({
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
  description = "A list of database users to create for the project"
  default     = []
}

variable "labels" {
  description = "A map of labels to be applied to created resources, in addition to the defaults."
  type        = map(string)
  default     = {}
}
