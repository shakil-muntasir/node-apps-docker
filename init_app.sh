#!/bin/bash

PROJECT_NAME=$1
DOMAIN=${2:-"$PROJECT_NAME.jotaro.dev"}

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: init_app <project_name> [--domain <custom_domain>]"
  exit 1
fi

APP_DIR="/var/www/node-apps/$PROJECT_NAME"
NGINX_CONFIG="/etc/nginx/sites-enabled/$PROJECT_NAME.conf"

# Check if the project directory exists
if [ ! -d "$APP_DIR" ]; then
  echo "Project directory $APP_DIR does not exist. Please create it and add your project files."
  exit 1
fi

# Check if .env file exists
if [ ! -f "$APP_DIR/.env" ]; then
  echo "Error: .env file not found in $APP_DIR."
  echo "Please create a .env file with proper values, including APP_PORT, and try again."
  exit 1
fi

# Read the APP_PORT value from the .env file
APP_PORT=$(grep -E "^APP_PORT=" "$APP_DIR/.env" | cut -d '=' -f2)

# Check if APP_PORT is set
if [ -z "$APP_PORT" ]; then
  echo "Error: APP_PORT is not defined in the .env file in $APP_DIR."
  echo "Please add a line like 'APP_PORT=3000' to your .env file and try again."
  exit 1
fi

# Generate Nginx configuration using the actual port value
cat <<EOF > "$NGINX_CONFIG"
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Reload Nginx configuration
nginx -s reload

echo "App $PROJECT_NAME initialized with domain $DOMAIN and Nginx configuration."

# Install dependencies and build the app
cd "$APP_DIR"
npm install
npm run build

# Check if the PM2 process already exists
if pm2 list | grep -q "$PROJECT_NAME"; then
  echo "PM2 process for $PROJECT_NAME already exists. Restarting the process..."
  pm2 restart "$PROJECT_NAME"
else
  echo "Starting a new PM2 process for $PROJECT_NAME..."
  pm2 start npm --name "$PROJECT_NAME" -- start --watch --env production -- -p $APP_PORT
fi

# Save PM2 process list to ensure it restarts on container reboot
pm2 save
