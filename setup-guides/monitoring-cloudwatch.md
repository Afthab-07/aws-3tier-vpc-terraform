# CloudWatch Monitoring and Alarms Setup Guide

## CloudWatch Basics

### Enabled by Default Metrics

EC2 instances automatically send the following metrics to CloudWatch:
- CPU Utilization
- Network In/Out
- Disk Read/Write (if monitoring agent installed)
- Status Checks (System and Instance)

## Creating CloudWatch Dashboards

### Dashboard Setup

1. **Create Dashboard**
   - CloudWatch → Dashboards → Create dashboard
   - Name: `prod-architecture-dashboard`
   - Click "Create dashboard"

2. **Add Widgets**
   - Click "Add widget"
   - Select widget type: Line, Number, Gauge, etc.

### Essential Widgets

#### CPU Utilization
- **Metric**: EC2 → Average CPU Utilization
- **Dimensions**: Auto Scaling Group name
- **Statistics**: Average
- **Period**: 5 minutes
- **Threshold**: 70% (visual line for scaling)

#### Network Traffic
- **Metrics**: 
  - NetworkIn (bytes)
  - NetworkOut (bytes)
- **Dimensions**: Load Balancer name
- **Statistics**: Average
- **Period**: 1 minute

#### ALB Request Count
- **Metric**: Application ELB → RequestCount
- **Dimensions**: Load Balancer name
- **Statistics**: Sum
- **Period**: 1 minute

#### Target Group Health
- **Metrics**:
  - HealthyHostCount
  - UnHealthyHostCount
- **Dimensions**: Target Group name
- **Statistics**: Average
- **Period**: 1 minute

#### ASG Instance Count
- **Metrics**:
  - GroupInServiceInstances
  - GroupDesiredCapacity
  - GroupTerminatingInstances
- **Dimensions**: Auto Scaling Group name
- **Statistics**: Average
- **Period**: 1 minute

## Creating CloudWatch Alarms

### CPU Utilization High Alarm

1. CloudWatch → Alarms → Create alarm
2. Configuration:
   - Name: `High-CPU-Alarm`
   - Metric: EC2 Average CPU Utilization
   - Statistic: Average
   - Period: 5 minutes
   - Threshold: 80%
   - Comparison: Greater than or equal to
   - Datapoints to alarm: 2 (consecutive periods)
   - Treat missing data as: Missing
3. Actions:
   - Select SNS topic for notifications
   - Create new topic: `prod-alerts`
4. Click "Create alarm"

### Unhealthy Target Instances Alarm

1. CloudWatch → Alarms → Create alarm
2. Configuration:
   - Name: `UnhealthyHosts-Alarm`
   - Metric: Application ELB → UnHealthyHostCount
   - Statistic: Average
   - Period: 1 minute
   - Threshold: Greater than 0
   - Datapoints to alarm: 1
3. Actions:
   - SNS topic: `prod-alerts`
4. Click "Create alarm"

### ASG Scaling Activity Alarm

1. CloudWatch → Alarms → Create alarm
2. Configuration:
   - Name: `ASG-Scaling-Activity`
   - Metric: Auto Scaling → GroupTerminatingInstances
   - Statistic: Sum
   - Period: 5 minutes
   - Threshold: Greater than 0
3. Actions:
   - SNS topic: `prod-alerts`
4. Click "Create alarm"

### ALB Response Time Alarm

1. CloudWatch → Alarms → Create alarm
2. Configuration:
   - Name: `HighResponseTime-Alarm`
   - Metric: Application ELB → TargetResponseTime
   - Statistic: Average
   - Period: 5 minutes
   - Threshold: 1 second (1000ms)
3. Actions:
   - SNS topic: `prod-alerts`
4. Click "Create alarm"

## SNS Notifications

### Configure SNS Topic

1. SNS → Topics → Create topic
2. Name: `prod-alerts`
3. Click "Create topic"

4. Subscribe to topic:
   - Click "Create subscription"
   - Protocol: Email
   - Endpoint: Your email address
   - Confirm subscription via email link

## Log Groups (Optional but Recommended)

### Application Logs

1. CloudWatch Logs → Log groups → Create log group
2. Name: `/aws/ec2/prod-application`
3. Retention: 30 days (adjust as needed)

4. **Configure EC2 to send logs**
   - Install CloudWatch Logs agent on instances
   - Configure to send application logs
   - Useful for troubleshooting

## Log Insights Queries

### Common Queries

**Error Count by Hour**
```
fields @timestamp, @message | filter @message like /ERROR/ | stats count() by bin(5m)
```

**Request Latency
**
```
fields @duration | filter @duration > 1000 | stats avg(@duration), max(@duration), pct(@duration, 99)
```

## Monitoring Best Practices

1. **Alert Thresholds**
   - Set thresholds based on business requirements
   - Avoid alert fatigue with reasonable thresholds
   - Use multiple datapoints for confirmation

2. **Dashboard Organization**
   - Group related metrics together
   - Use consistent time ranges
   - Include context (thresholds, baselines)

3. **Alerting Strategy**
   - Alert on business metrics, not just infrastructure
   - Escalation policies for critical alerts
   - Regular review and tuning of thresholds

4. **Cost Optimization**
   - CloudWatch metrics are billed by custom metrics
   - Default EC2 metrics are free
   - Log storage incurs costs (set appropriate retention)

## Troubleshooting

### No Metrics Appearing
- Verify IAM role has CloudWatch permissions
- Check instance is running for at least 1 minute
- Verify security group allows CloudWatch API calls

### Alarms Not Triggering
- Check threshold value against actual metric values
- Verify datapoints configuration
- Ensure SNS topic is configured correctly

### High CloudWatch Costs
- Reduce custom metric frequency if possible
- Set log retention periods appropriately
- Review dashboard update frequency
