locals {
  existing_teams = [
    {
      name: "${var.component}-${var.deployment_identifier}-support"
      usernames: ["toby+user1@go-atomic.io"]
      role_names: ["GROUP_DATA_ACCESS_READ_ONLY"]
    },
    {
      name: "${var.component}-${var.deployment_identifier}-billing"
      usernames: ["toby+user2@go-atomic.io"]
      role_names: ["GROUP_READ_ONLY"]
    }
  ]
  dedicated_teams = [
    {
      name_suffix: "developers"
      usernames: ["toby+user1@go-atomic.io", "toby+user2@go-atomic.io"]
      role_names: ["GROUP_DATA_ACCESS_ADMIN", "GROUP_CLUSTER_MANAGER"]
    },
    {
      name_suffix: "admins"
      usernames: ["toby+user3@go-atomic.io"]
      role_names: ["GROUP_OWNER"]
    }
  ]
  ip_access_list = [
    {
      type: "cidr-block"
      value: "10.0.0.0/8"
      comment: "Private network 1"
    },
    {
      type: "cidr-block"
      value: "192.168.0.0/16"
      comment: "Private network 2"
    },
    {
      type: "ip-address"
      value: "1.1.1.1"
      comment: "Public IP 1"
    },
    {
      type: "ip-address"
      value: "2.2.2.2"
      comment: "Public IP 2"
    }
  ]
  database_users = [
    {
      username: "user-1"
      password: "password-1"
      roles: [
        {
          role_name: "readAnyDatabase",
          database_name: "admin",
          collection_name: ""
        },
        {
          role_name: "readWrite",
          database_name: "specific",
          collection_name: "things"
        }
      ]
      labels: {
        important: "thing"
        something: "else"
      }
      scopes: []
    },
    {
      username: "user-2"
      password: "password-2"
      roles: [
        {
          role_name: "dbAdmin",
          database_name: "specific",
          collection_name: ""
        }
      ]
      labels: {}
      scopes: [
        {
          type: "CLUSTER",
          name: "some-cluster"
        }
      ]
    }
  ]
}

module "project" {
  source = "./../../"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  organization_id = var.organization_id

  existing_teams  = [
    for existing_team in local.existing_teams:
      {
        id: mongodbatlas_teams.team[existing_team.name].team_id,
        name: existing_team.name
        usernames: existing_team.usernames
        role_names: existing_team.role_names
      }
  ]
  dedicated_teams = local.dedicated_teams

  ip_access_list = local.ip_access_list

  database_users = local.database_users
}
