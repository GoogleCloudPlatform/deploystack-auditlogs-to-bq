[![GC Start](gcp_banner.png)](https://cloud.google.com/?utm_source=github&utm_medium=referral&utm_campaign=GCP&utm_content=packages_repository_banner)
# Analyze Audit Logs for a GWS or Google Cloud Organization with Big Query

## Introduction

Google Cloud offers a wide range of services to help you build and run applications. Although external users can pose security risks, it's important to note that potential security threats may also originate from **within your own organization**. That's why it's important to monitor your Google Cloud environment for suspicious activity.

One way to do this is to collect and store Audit Logs.

Audit Logs record all activity in your Google Cloud environment, including **who** made changes, **when** they were made, and **what** resources were affected. 

This information can be invaluable for troubleshooting security incidents and identifying potential compliance violations and for internal audits and visibility.

**Time to complete**: About 10 minutes

Click the **Start** button to move to the next step.

## Prerequisites

### Google Workspace data sharing enabled

If you are interested to route Google Workspace audit logs to Google Cloud, this will require to enable data sharing between both environments.

To enable sharing Google Workspace data with Google Cloud from your Google Workspace, Cloud Identity, or Drive Enterprise account, follow the instructions in [Share data with Google Cloud services](https://support.google.com/a/answer/9320190).

### Setting up the project for the deployment

This example will deploy all its resources into the project defined by the `project_id` variable. Please note that we assume this project already exists. 

## Deployment

Before we deploy the architecture, you will at least need the following information (for more precise configuration see the Variables section):

* The project Id.
* The organization Id (as mentioned [here](https://cloud.google.com/sdk/gcloud/reference/projects/get-ancestors), the following command outputs the organization: `gcloud projects get-ancestors PROJECT_ID`)
* A dataset Id to export logs to (see [naming conventions](https://cloud.google.com/bigquery/docs/datasets#dataset-naming)). Note: this will create a new dataset (to use an existing dataset, see the following section below: "Use an already existing BigQuery dataset")
* A log filter which is a Cloud Logging log query (see [documentation](https://cloud.google.com/logging/docs/view/logging-query-language)) used to target specific audit logs to route to BigQuery. Note that you'll need to escape the quotes symbols.
For example filters, please see the next section in this ReadMe.
* Identity groups for both Owner and Reader role on the BigQuery dataset. 
* Granting the [Logging Admin IAM role](https://cloud.google.com/iam/docs/understanding-roles#logging.admin) to the person running this script is recommended. 


In case the deployment has not started, please run the following command:

``` bash
deploystack install
```


*In case this fails* for any reason during the process, please refer to the section below and manually delete the audit log sink before running the command again.

If a warning regarding an undeclared variable should appear, this can safely be ignored.

During the process, you will be asked for some user input. All necessary variables are explained in the full README sfile. In case of failure, you can simply click the button again or run the deploystack command

## Clean Up Your Environment

The easiest way to remove all the deployed resources is to run the following command in Cloud Shell:

``` {shell}
deploystack uninstall
```

The above command will delete the associated resources so there will be no billable charges made afterwards.
In order to remove all of the resources, you will need to delete the Logging Sink that it creates at an organisational level. To do this, please complete the following steps:

* Navigate to *Cloud Logging*
* Navigate to *Logs Router*
* In the menu at the top, please select your organisation
* Delete the entry of type BigQuery dataset named audit-log-org-sink

Note: This will also destroy the BigQuery dataset as the following option in `main.tf` is set to 

`true`: `delete_contents_on_destroy`.

## Customizing to Your Environment

In this section you will find different ways to customise the architecture to your needs.

### Example Log Filters

**GWS Audit Log Filter Example**
This filter filters all of the audit logs concerning Google Workspace into the BigQuery dataset. These logs will tell you who created, edited, and/or deleted any resource and when this was done. This is mainly useful for auditing purposes, or to find out when a critical change to a resource was made.
```
protoPayload.methodName:\"google.admin.\"
```

**Data Access Audit Log Filter Example**
This filter filters all of the logs concerning accessed data into the BigQuery dataset. 
```
logName=\"projects/PROJECT_ID/logs/cloudaudit.googleapis.com%2Fdata_access\"
```

**System Events Audit Log Filter Example**
This filter filters all of the logs related to system events into the BigQuery dataset.
```
logName=\"projects/PROJECT_ID/logs/cloudaudit.googleapis.com%2Fsystem_event\"
```

### Use A Pre-Existing BigQuery Dataset

In order to push the audit logs to a BigQuery dataset that already exists in a project, follow these steps:

1. Remove the `"bigquery-dataset"` module block at the end of the [`main.tf`](main.tf#L42) file.
2. Replace the following line in the `"google_logging_organization_sink"` resource block

```{terrafom}
  destination      = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${module.bigquery-dataset.dataset_id}"
```

with:

```{terrafom}
  destination      = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${var.dataset_id}"
```
