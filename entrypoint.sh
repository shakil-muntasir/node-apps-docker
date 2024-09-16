#!/bin/sh

# Resurrect previously saved PM2 processes (if any)
pm2 resurrect || true

# Start Nginx in the foreground
nginx -g 'daemon off;'
