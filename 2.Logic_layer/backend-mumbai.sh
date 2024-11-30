#!/bin/bash

# Update the system
sudo yum update -y || { echo "System update failed"; exit 1; }

# Install Node.js 20 LTS and npm
curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash - || { echo "Node.js setup failed"; exit 1; }
sudo yum install -y nodejs git || { echo "Failed to install Node.js or Git"; exit 1; }

# Clone the backend app repository
cd /home/ec2-user
if [ ! -d "backend-todo" ]; then
    sudo git clone <REPOSITORY_URL> || { echo "Failed to clone repository"; exit 1; }
fi
cd backend-todo/

# Create .env file
sudo bash -c 'cat <<EOT > .env
DB_USER=<YOUR_DB_USER>
DB_PASS=<YOUR_DB_PASS>
DB_HOST=<YOUR_DB_HOST>
DB_PORT=<YOUR_DB_PORT>
PORT=4000
JWT_SECRET=<YOUR_JWT_SECRET>
LOCATION="Mumbai"
EOT'

# Ensure ec2-user owns the directory
sudo chown -R ec2-user:ec2-user /home/ec2-user/backend-todo

# Kill any existing process using port 4000
PID=$(sudo lsof -t -i:4000)
if [ -n "$PID" ]; then
    echo "Killing process $PID using port 4000"
    sudo kill -9 $PID
else
    echo "No process found using port 4000"
fi

# Reinstall Node.js dependencies
sudo -u ec2-user rm -rf node_modules
sudo -u ec2-user npm install || { echo "npm install failed"; exit 1; }

# Get the full path of npm
NPM_PATH=$(which npm)

# Create and configure systemd service
sudo bash -c "cat <<EOT > /etc/systemd/system/backend-app.service
[Unit]
Description=Backend Node.js Application
After=network.target

[Service]
WorkingDirectory=/home/ec2-user/backend-todo
ExecStart=$NPM_PATH run start  # Alternatively, specify the entry file directly, e.g., 'node index.js'
Restart=always
User=ec2-user
EnvironmentFile=/home/ec2-user/backend-todo/.env
StandardOutput=journal
StandardError=journal
SyslogIdentifier=node-backend-app

ExecStartPre=/bin/sleep 10

[Install]
WantedBy=multi-user.target
EOT"

# Reload systemd and start the app service
sudo systemctl daemon-reload
sudo systemctl enable backend-app.service || { echo "Failed to enable backend-app.service"; exit 1; }
sudo systemctl start backend-app.service || { echo "Failed to start backend-app.service"; exit 1; }

# Verify service status with multiple retries
for i in {1..5}; do
    if sudo systemctl is-active --quiet backend-app.service; then
        echo "backend-app.service is running"
        exit 0
    else
        echo "Attempt $i: Waiting for backend-app.service to start..."
        sleep 5
    fi
done

# Final check and log status
echo "backend-app.service failed to start"
sudo journalctl -u backend-app.service | tail -n 20
exit 1
