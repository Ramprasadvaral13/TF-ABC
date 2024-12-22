resource "aws_autoscaling_group" "demo-asg" {
    desired_capacity = 2
    min_size = 1
    max_size = 3
    for_each = {for key, subnet in var.subnets : key => subnet if subnet.public == false }
    vpc_zone_identifier = aws_subnet.demo-subnets[each.key].id

    launch_template {
      id = aws_launch_template.demo-lt.id
      version = "$Latest"
    }

    health_check_type = "EC2"
    health_check_grace_period = "300"
    force_delete = true
  
}

resource "aws_cloudwatch_metric_alarm" "high-cpu-alarm" {
    alarm_name = "high-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 300
    statistic = "Average"
    threshold = 70
    alarm_description = "trigger when cpu exceeds 70%"

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.demo-asg.name
    }

    alarm_actions = [ aws_autoscaling_policy.scale_up_policy.arn ]
  
}

resource "aws_cloudwatch_metric_alarm" "kow-cpu-alarm" {
    alarm_name = "low-cpu-alarm"
    comparison_operator = "LessThanOrEqualTo"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 300
    statistic = "Average"
    threshold = 30
    alarm_description = "trigger when cpu exceeds 30"

    dimensions = {
      AutoScalingGroupName = aws_autoscaling_group.demo-asg.name
    }

    alarm_actions = [ aws_autoscaling_policy.scale_down_policy.arn ]
  
}

resource "aws_autoscaling_policy" "scale_up_policy" {
    name = "scale up policy"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    metric_aggregation_type = "Average"
    estimated_instance_warmup = 300
    autoscaling_group_name = aws_autoscaling_group.demo-asg.name
  
}

resource "aws_autoscaling_policy" "scale_down_policy" {
    name = "scale down policy"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    metric_aggregation_type = "Average"
    estimated_instance_warmup = 300
    autoscaling_group_name = aws_autoscaling_group.demo-asg.name
  
}