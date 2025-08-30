#!/bin/bash

# User Data Script for Disaster Recovery Web Application
# This script sets up the EC2 instance with necessary software and configuration

# Update system packages
yum update -y

# Install required packages
yum install -y \
    httpd \
    mysql \
    php \
    php-mysqli \
    php-json \
    php-xml \
    aws-cli \
    amazon-cloudwatch-agent \
    htop \
    curl \
    wget \
    git \
    unzip

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Configure environment variables
export AWS_REGION="${region}"
export S3_BUCKET="${bucket_name}"
export DB_ENDPOINT="${db_endpoint}"

# Create application directory
mkdir -p /var/www/html/app
chown -R apache:apache /var/www/html/app

# Create basic health check endpoint
cat > /var/www/html/health <<EOF
<?php
header('Content-Type: application/json');

\$health_status = array(
    'status' => 'healthy',
    'timestamp' => date('c'),
    'region' => '${region}',
    'instance_id' => file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'),
    'availability_zone' => file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone')
);

// Test database connection
try {
    \$db_host = '${db_endpoint}';
    if (!empty(\$db_host)) {
        \$pdo = new PDO("mysql:host=\$db_host;port=3306", 'admin', getenv('DB_PASSWORD'));
        \$health_status['database'] = 'connected';
    } else {
        \$health_status['database'] = 'not_configured';
    }
} catch (Exception \$e) {
    \$health_status['database'] = 'error';
    \$health_status['database_error'] = \$e->getMessage();
}

// Test S3 connectivity
try {
    \$output = shell_exec('aws s3 ls s3://${bucket_name}/ --region ${region} 2>&1');
    if (strpos(\$output, 'Error') === false) {
        \$health_status['s3'] = 'accessible';
    } else {
        \$health_status['s3'] = 'error';
        \$health_status['s3_error'] = \$output;
    }
} catch (Exception \$e) {
    \$health_status['s3'] = 'error';
    \$health_status['s3_error'] = \$e->getMessage();
}

echo json_encode(\$health_status, JSON_PRETTY_PRINT);
?>
EOF

# Create basic index page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Disaster Recovery Web Application</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .status {
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .healthy {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .region-info {
            background-color: #e7f3ff;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Disaster Recovery Web Application</h1>
        <p>This is a sample web application deployed as part of the AWS Disaster Recovery solution.</p>
        
        <div class="region-info">
            <h3>📍 Region Information</h3>
            <p><strong>Region:</strong> ${region}</p>
            <p><strong>S3 Bucket:</strong> ${bucket_name}</p>
            <p><strong>Database Endpoint:</strong> ${db_endpoint}</p>
        </div>

        <div class="status healthy">
            <h3>✅ Application Status</h3>
            <p>The application is running successfully!</p>
        </div>

        <h3>🔗 Available Endpoints</h3>
        <ul>
            <li><a href="/health">Health Check</a> - JSON health status</li>
            <li><a href="/phpinfo.php">PHP Info</a> - PHP configuration details</li>
        </ul>

        <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 0.9em; color: #666;">
            <p>This application demonstrates a multi-region disaster recovery setup with automated failover capabilities.</p>
        </div>
    </div>
    
    <script>
        // Auto-refresh health status every 30 seconds
        setInterval(function() {
            fetch('/health')
                .then(response => response.json())
                .then(data => {
                    console.log('Health check:', data);
                })
                .catch(error => console.error('Health check failed:', error));
        }, 30000);
    </script>
</body>
</html>
EOF

# Create PHP info page for debugging
cat > /var/www/html/phpinfo.php <<EOF
<?php
phpinfo();
?>
EOF

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/web-app-dr",
                        "log_stream_name": "apache-access-{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/web-app-dr",
                        "log_stream_name": "apache-error-{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/web-app-dr",
                        "log_stream_name": "system-{instance_id}",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ],
                "totalcpu": false
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time",
                    "read_bytes",
                    "write_bytes",
                    "reads",
                    "writes"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Configure log rotation
cat > /etc/logrotate.d/custom-app <<EOF
/var/log/httpd/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 644 apache apache
    postrotate
        systemctl reload httpd
    endscript
}
EOF

# Create application deployment script
cat > /usr/local/bin/deploy-app.sh <<'EOF'
#!/bin/bash

# Application deployment script
LOG_FILE="/var/log/app-deployment.log"
S3_BUCKET="${S3_BUCKET}"
AWS_REGION="${AWS_REGION}"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "Starting application deployment..."

# Download latest application code from S3
if [ ! -z "$S3_BUCKET" ]; then
    log "Downloading application code from S3..."
    aws s3 sync s3://$S3_BUCKET/app/ /var/www/html/app/ --region $AWS_REGION --delete
    
    if [ $? -eq 0 ]; then
        log "Application code downloaded successfully"
    else
        log "Failed to download application code from S3"
        exit 1
    fi
fi

# Set proper permissions
chown -R apache:apache /var/www/html/app
chmod -R 644 /var/www/html/app
find /var/www/html/app -type d -exec chmod 755 {} \;

# Restart Apache to apply changes
systemctl restart httpd

log "Application deployment completed successfully"
EOF

chmod +x /usr/local/bin/deploy-app.sh

# Set up cron job for periodic health checks and deployments
cat > /etc/cron.d/app-maintenance <<EOF
# Application maintenance tasks
# Run health checks every 5 minutes
*/5 * * * * root curl -s http://localhost/health > /dev/null

# Check for application updates every hour
0 * * * * root /usr/local/bin/deploy-app.sh >> /var/log/app-deployment.log 2>&1

# Clean up old logs weekly
0 2 * * 0 root find /var/log -name "*.log" -type f -mtime +30 -delete
EOF

# Final system configuration
systemctl restart httpd
systemctl restart crond

# Create startup script
cat > /etc/rc.d/rc.local <<'EOF'
#!/bin/bash

# Ensure all services are running on startup
systemctl start httpd
systemctl start amazon-cloudwatch-agent

# Run initial deployment
/usr/local/bin/deploy-app.sh

exit 0
EOF

chmod +x /etc/rc.d/rc.local

# Log completion
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log

# Signal completion to CloudFormation/Terraform if needed
# aws cloudformation signal-resource --stack-name $STACK_NAME --logical-resource-id $LOGICAL_ID --unique-id $INSTANCE_ID --status SUCCESS --region $AWS_REGION