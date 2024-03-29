/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "dataset_id" {
  description = "Dataset id to store the routed logs"
  type        = string
}

variable "exclusions" {
  description = "Logging exclusions for the sink in the form {NAME -> FILTER}."
  type        = map(string)
  default     = {}
}

variable "filter" {
  description = "The filter to apply when exporting logs"
  type        = string
}

variable "location" {
  description = "Dataset location"
  type        = string
  default     = "EU"
}

variable "org_id" {
  description = "Organization Id"
  type        = string
}

variable "owners_group_email" {
  description = "Email IDs for identity groups of users who own the dataset."
  type        = string
}

variable "project_id" {
  description = "Project id."
  type        = string
}

variable "readers_group_email" {
  description = "Email IDs for identity groups of users who can read the dataset."
  type        = string
}

variable "prefix" {
  description = "Unique prefix used for resource names. Not used for project if 'project_create' is null."
  type        = string
}

variable "project_create" {
  description = "Provide values if project creation is needed, uses existing project if null. Parent is in 'folders/nnn' or 'organizations/nnn' format."
  type = object({
    billing_account_id = string
    parent             = string
  })
  default = null
}
