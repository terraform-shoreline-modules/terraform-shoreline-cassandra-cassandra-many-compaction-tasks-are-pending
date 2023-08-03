terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "cassandra_many_compaction_tasks_are_pending" {
  source    = "./modules/cassandra_many_compaction_tasks_are_pending"

  providers = {
    shoreline = shoreline
  }
}