# Use Node 20 Alpine as the base image
FROM node:20-alpine

# Install necessary packages
RUN apk add --no-cache nginx bash

# Install PM2 globally
RUN npm install -g pm2

# Create directories for apps and Nginx configuration
RUN mkdir -p /var/www/node-apps /etc/nginx/conf.d /etc/nginx/sites-enabled

# Set working directory
WORKDIR /var/www/node-apps

# Copy Nginx default configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy init script into the container
COPY init_app.sh /usr/local/bin/init_app
RUN chmod +x /usr/local/bin/init_app

# Set entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports (Nginx will listen on 80 and forward requests to the apps)
EXPOSE 80

# Set up entrypoint script to run Nginx and start the Node apps
ENTRYPOINT ["/entrypoint.sh"]
