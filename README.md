# Terraform-aws-cloudwatch-alarms


## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Examples](#examples)
- [License](#license)
- [Author](#Author)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Introduction
Terraform module for creating alarms for tracking important changes and occurances from cloudtrail.

## Usage
To use this module, you should have Terraform installed and configured for AWS. This module provides the necessary Terraform configuration for creating AWS resources, and you can customize the inputs as needed. Below is an example of how to use this module:

# Examples

### Basic Example
```hcl
module "alarm" {
  source      = "git::https://github.com/shanav-tech/terraform-aws-cloudwatch-alarms.git?ref=v1.0.0"

  name        = "alarm"
  environment = "test"
  label_order = ["name", "environment"]

  alarm_name                = "cpu-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 40
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = []
  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  dimensions = {
    instance_id = module.ec2.instance_id[0]
  }
}
```

### Anomaly Example
```hcl
module "alarm" {
  source      = "git::https://github.com/shanav-tech/terraform-aws-cloudwatch-alarms.git?ref=v1.0.0"

  name        = "alarm"
  environment = "test"
  label_order = ["name", "environment"]

  alarm_name          = "cpu-alarm"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "e1"
  query_expressions = [{
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "CPUUtilization (Expected)"
    return_data = "true"
  }]
  query_metrics = [{
    id          = "m1"
    return_data = "true"
    metric_name = "CPUUtilization"
    namespace   = "AWS/EC2"
    period      = "120"
    stat        = "Average"
    unit        = "Count"
    dimensions = {
      InstanceId = module.ec2.instance_id[0]
    }
  }]
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = []
  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
}
```

### Epression Example
```hcl
module "alarm" {
  source      = "git::https://github.com/shanav-tech/terraform-aws-cloudwatch-alarms.git?ref=v1.0.0"
  name        = "alarm"
  environment = "test"
  label_order = ["name", "environment"]

  expression_enabled  = true
  alarm_name          = "cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 40
  query_expressions = [{
    id          = "e1"
    expression  = "m2/m1*100"
    label       = "Error Rate"
    return_data = "true"
  }]
  query_metrics = [
    {
      id          = "m1"
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"
      return_data = null
      dimensions = {
        LoadBalancer = "app/web"
      }
    }, {
      id          = "m2"
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "120"
      stat        = "Sum"
      unit        = "Count"
      return_data = null
      dimensions = {
        LoadBalancer = "app/web"
      }
    }]
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = []
  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
}
```

## Examples
For detailed examples on how to use this module, please refer to the [examples](https://github.com/shanav-tech/terraform-aws-cloudwatch-alarms/tree/master/_example) directory within this repository.

## License
This Terraform module is provided under the **MIT** License. Please see the [LICENSE](https://github.com/shanav-tech/terraform-aws-cloudwatch-alarms/blob/master/LICENSE) file for more details.

## Author
Your Name
Replace **MIT** and **shanav-tech** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.99.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.99.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | git::https://github.com/shanav-tech/terraform-aws-labels.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.anomaly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.expression](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actions_enabled"></a> [actions\_enabled](#input\_actions\_enabled) | Indicates whether or not actions should be executed during any changes to the alarm's state. | `bool` | `true` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | The list of actions to execute when this alarm transitions into an ALARM state from any other state. | `list(any)` | `[]` | no |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description) | The description for the alarm. | `string` | `""` | no |
| <a name="input_alarm_name"></a> [alarm\_name](#input\_alarm\_name) | The descriptive name for the alarm. | `string` | n/a | yes |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | The arithmetic operation to use when comparing the specified Statistic and Threshold. | `string` | n/a | yes |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | Dimensions for metrics. | `map(any)` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Enable alarm. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold. | `number` | n/a | yes |
| <a name="input_expression_enabled"></a> [expression\_enabled](#input\_expression\_enabled) | Enable alarm with expression. | `bool` | `false` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. | `list(any)` | `[]` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'shanav-tech'. | `string` | `"shanav-tech"` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | The name for the alarm's associated metric. | `string` | `"CPUUtilization"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for the alarm's associated metric. | `string` | `"AWS/EC2"` | no |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | The list of actions to execute when this alarm transitions into an OK state from any other state. | `list(any)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the specified statistic is applied. | `number` | `120` | no |
| <a name="input_query_expressions"></a> [query\_expressions](#input\_query\_expressions) | values for metric query expression. | `list(any)` | <pre>[<br>  {<br>    "expression": "ANOMALY_DETECTION_BAND(m1)",<br>    "id": "e1",<br>    "label": "CPUUtilization (Expected)",<br>    "return_data": "true"<br>  }<br>]</pre> | no |
| <a name="input_query_metrics"></a> [query\_metrics](#input\_query\_metrics) | values for metric query metrics. | `list(any)` | <pre>[<br>  {<br>    "dimensions": {<br>      "InstanceId": "i-abc123"<br>    },<br>    "id": "m1",<br>    "metric_name": "CPUUtilization",<br>    "namespace": "AWS/EC2",<br>    "period": "120",<br>    "return_data": "true",<br>    "stat": "Average",<br>    "unit": "Count"<br>  }<br>]</pre> | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `""` | no |
| <a name="input_statistic"></a> [statistic](#input\_statistic) | The statistic to apply to the alarm's associated metric. | `string` | `"Average"` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | The value against which the specified statistic is compared. | `number` | `40` | no |
| <a name="input_threshold_metric_id"></a> [threshold\_metric\_id](#input\_threshold\_metric\_id) | If this is an alarm based on an anomaly detection model, make this value match the ID of the ANOMALY\_DETECTION\_BAND function. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the cloudwatch metric alarm. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the health check. |
| <a name="output_tags"></a> [tags](#output\_tags) | A mapping of tags to assign to the resource. |
<!-- END_TF_DOCS -->