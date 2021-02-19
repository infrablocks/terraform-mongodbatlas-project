variable "component" {
  description = "The component this project will contain."
  type        = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "organization_id" {
  type = string
  description = "The ID of the organization within which to create the project."
}

variable "dedicated_teams" {
  type = list(object({
    name_suffix: string,
    usernames: list(string),
    roles: list(string)
  }))
  description = "A list of teams to be created and associated with the project with corresponding roles."
}
