#!/bin/bash

# Update the system
sudo yum update -y || { echo "System update failed"; exit 1; }

# Install Node.js 20 LTS, npm, git, and AWS CLI
curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash - || { echo "Node.js setup failed"; exit 1; }
sudo yum install -y nodejs git aws-cli || { echo "Failed to install Node.js, Git, or AWS CLI"; exit 1; }

# Clone the frontend app repository
cd /home/ec2-user
if [ ! -d "frontend-todo" ]; then
    sudo git clone <REPO_URL> || { echo "Failed to clone repository"; exit 1; }
fi
cd frontend-todo/

# Create the .env file and add VITE_API_URL
echo "VITE_API_URL=http://<BACKEND_SERVER_IP>:4000" | sudo tee .env > /dev/null || { echo "Failed to create .env file"; exit 1; }

# Install dependencies
sudo npm install || { echo "npm install failed"; exit 1; }

# Build the frontend app
sudo npm run build || { echo "Build failed"; exit 1; }

# Upload dist to S3 bucket
aws s3 sync dist/ s3://<BUCKET_NAME> --delete || { echo "Failed to upload files to S3"; exit 1; }

# Allow access
aws s3api put-public-access-block --bucket <BUCKET_NAME> --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false || { echo "Failed to set public access block"; exit 1; }

# Modify bucket policies to allow public read access
aws s3api put-bucket-policy --bucket <BUCKET_NAME> --policy '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<BUCKET_NAME>/*"
        }
    ]
}' || { echo "Failed to set bucket policy"; exit 1; }

# Enable static website hosting on S3 bucket
aws s3 website s3://<BUCKET_NAME>/ --index-document index.html --error-document index.html || { echo "Failed to configure static website hosting"; exit 1; }

# Verify website hosting configuration
echo "Website configuration:"
aws s3api get-bucket-website --bucket <BUCKET_NAME> || { echo "Failed to verify website hosting configuration"; exit 1; }
