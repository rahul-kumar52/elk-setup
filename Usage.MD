# Elasticsearch Cluster Setup

This project sets up an Elasticsearch cluster with secure communication using SSL certificates. The `ca.crt` file is automatically uploaded to an S3 bucket for secure sharing. The setup includes Elasticsearch nodes and Kibana for visualization.

---

## How to Run the Setup

1. **Start the Setup**:
   Run the `start.sh` script to start the Elasticsearch cluster and the S3 upload monitor:
   ```bash
   ./start.sh
   ```
2. **View the logs**:
    ```
    ./auto-s3-upload.sh -l
    ```