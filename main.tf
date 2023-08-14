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

resource "google_logging_organization_sink" "audit_log_org_sink" {
  name             = "audit-log-org-sink"
  org_id           = var.org_id
  include_children = true
  destination      = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${module.bigquery-dataset.dataset_id}"
  filter           = var.filter
  dynamic "exclusions" {
    for_each = var.exclusions
    iterator = exclusion
    content {
      name   = exclusion.key
      filter = exclusion.value
    }
  }
  bigquery_options {
    use_partitioned_tables = true
  }
}

# Either create a project or set up the given one
module "project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v23.0.0"
  name            = var.project_id
  parent          = try(var.project_create.parent, null)
  billing_account = try(var.project_create.billing_account_id, null)
  project_create  = var.project_create != null
  prefix          = var.project_create == null ? null : var.prefix
  services = [
    "bigquery.googleapis.com",
    "logging.googleapis.com"
  ]
}

resource "google_project_iam_member" "org_sa_bq_role" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_organization_sink.audit_log_org_sink.writer_identity
}

module "bigquery-dataset" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset?ref=v25.0.0"
  project_id = var.project_id
  id         = var.dataset_id
  location   = var.location
  access = {
    reader-group = { role = "READER", type = "group" }
    owner        = { role = "OWNER", type = "group" }
  }
  access_identities = {
    reader-group = "${var.readers_group_email}"
    owner        = "${var.owners_group_email}"
  }
  options = {
    default_table_expiration_ms     = null
    default_partition_expiration_ms = null
    delete_contents_on_destroy      = true
  }
}
