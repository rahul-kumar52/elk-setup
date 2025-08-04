#!/bin/bash

# Simple automated S3 upload script for Elasticsearch ca.crt
# This script monitors for ca.crt file and uploads it to S3 automatically

set -e

# Log file
LOG_FILE="s3-upload.log"

# Function to log messages
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check AWS CLI
check_aws() {
    if ! command -v aws &> /dev/null; then
        log_message "ERROR: AWS CLI not found. Please install it first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_message "ERROR: AWS CLI not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    log_message "AWS CLI configured successfully"
}

# Function to get S3 bucket
get_bucket() {
    if [ -f .env ] && grep -q "S3_BUCKET_NAME" .env; then
        S3_BUCKET=$(grep "S3_BUCKET_NAME" .env | cut -d'=' -f2)
        log_message "Using S3 bucket from .env: $S3_BUCKET"
    else
        echo -n "Enter S3 bucket name: "
        read S3_BUCKET
        if [ -z "$S3_BUCKET" ]; then
            log_message "ERROR: S3 bucket name required"
            exit 1
        fi
    fi
}

# Function to upload to S3
upload_to_s3() {
    log_message "Uploading ca.crt to s3://$S3_BUCKET/ca.crt"
    
    if aws s3 cp ca.crt "s3://$S3_BUCKET/ca.crt" --quiet; then
        log_message "SUCCESS: ca.crt uploaded to S3"
        return 0
    else
        log_message "ERROR: Failed to upload to S3"
        return 1
    fi
}

# Function to monitor and upload
monitor_and_upload() {
    log_message "Starting automated S3 upload monitor..."
    log_message "Monitoring for ca.crt file..."
    
    # Check AWS and get bucket
    check_aws
    get_bucket
    
    log_message "AWS Account: $(aws sts get-caller-identity --query 'Account' --output text)"
    log_message "AWS Region: $(aws configure get region)"
    
    # Check if file already exists
    if [ -f "ca.crt" ]; then
        log_message "ca.crt found, uploading immediately..."
        upload_to_s3
        exit 0
    fi
    
    # Monitor for file creation
    log_message "Waiting for ca.crt to be generated..."
    while true; do
        if [ -f "ca.crt" ]; then
            log_message "ca.crt detected! Uploading to S3..."
            upload_to_s3
            break
        fi
        sleep 10
    done
    
    log_message "Upload process completed"
}

# Function to show logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "Recent logs:"
        echo "============"
        tail -20 "$LOG_FILE"
    else
        echo "No logs found"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help"
    echo "  -m, --monitor  Start monitoring (default)"
    echo "  -u, --upload   Upload existing ca.crt"
    echo "  -l, --logs     Show logs"
    echo ""
    echo "Examples:"
    echo "  $0              # Start monitoring"
    echo "  $0 -u           # Upload existing ca.crt"
    echo "  $0 -l           # Show logs"
}

# Parse arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -u|--upload)
        if [ -f "ca.crt" ]; then
            check_aws
            get_bucket
            upload_to_s3
        else
            log_message "ERROR: ca.crt not found"
            exit 1
        fi
        ;;
    -l|--logs)
        show_logs
        ;;
    -m|--monitor|"")
        monitor_and_upload
        ;;
    *)
        echo "Unknown option: $1"
        show_usage
        exit 1
        ;;
esac 