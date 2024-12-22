resource "aws_autoscaling_group" "demo-asg" {
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 3
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  for_each = { for key, subnet in var.subnets : key => subnet if subnet.public == false }

  vpc_zone_identifier = [aws_subnet.demo-subnets[each.key].id]

  launch_template {
    id      = aws_launch_template.demo-lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  for_each                = aws_autoscaling_group.demo-asg
  name                    = "scale-up-policy-${each.key}"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  metric_aggregation_type = "Average"
  
  autoscaling_group_name  = each.value.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  for_each                = aws_autoscaling_group.demo-asg
  name                    = "scale-down-policy-${each.key}"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  metric_aggregation_type = "Average"
  
  autoscaling_group_name  = each.value.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  for_each = aws_autoscaling_group.demo-asg

  alarm_name          = "high-cpu-alarm-${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Trigger when CPU exceeds 70%"

  dimensions = {
    AutoScalingGroupName = each.value.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up_policy[each.key].arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  for_each = aws_autoscaling_group.demo-asg

  alarm_name          = "low-cpu-alarm-${each.key}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Trigger when CPU drops below 30%"

  dimensions = {
    AutoScalingGroupName = each.value.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down_policy[each.key].arn]
}
