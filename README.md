
# Node Apps Docker Setup

This setup provides a Docker-based environment to host multiple Node.js Express TypeScript applications on a Raspberry Pi. The setup uses Nginx as a reverse proxy and PM2 to manage the Node.js processes.

## Prerequisites

- Docker and Docker Compose installed on your Raspberry Pi or Linux-based system.
- Node.js and npm (Node Package Manager) knowledge for managing your applications.
- `~/node-apps` directory on the host machine where you will store your project folders.

## Project Structure

The project directory structure on your Raspberry Pi should look like this:

```
~/node-apps
└── <project_name>
    ├── .env
    ├── package.json
    ├── src/
    └── ...
```

- Each `<project_name>` is a separate Node.js project.
- Each project must contain a `.env` file with an `APP_PORT` environment variable that defines the port on which the application will run.

## Docker Setup

The Docker container uses `node:20-alpine` as the base image and includes Nginx and PM2 for managing applications.

### Dockerfile

The Dockerfile sets up the environment with the necessary dependencies and configurations:

- Installs Node.js v20 and PM2.
- Configures Nginx to act as a reverse proxy for each application.
- Sets up entrypoints to initialize Nginx and PM2 processes.

### Entrypoint Script

The entrypoint script (`entrypoint.sh`) handles the following:

- Starts Nginx in the background.
- Restores PM2 processes on container startup using `pm2 resurrect`.
- Keeps the container alive by running Nginx in the foreground.

### init_app Script

The `init_app.sh` script is used to initialize new Node.js applications:

- Verifies the existence of `.env` file and `APP_PORT` variable.
- Generates Nginx configuration for each app.
- Starts or restarts the PM2 process for the app.

## Usage

### 1. Build the Docker Image

Run the following command to build the Docker image:

```bash
docker build -t node-apps-nginx .
```

### 2. Run the Docker Container

Run the Docker container with the `--restart unless-stopped` option to ensure it restarts automatically unless stopped manually:

```bash
docker run -d --name node-apps --restart unless-stopped -p 5001:80 -v ~/node-apps:/var/www/node-apps node-apps-nginx
```

### 3. Initialize a New Project

To initialize a new project, use the `init_app.sh` script. For example:

```bash
docker exec -it node-apps init_app <project_name> --domain <custom_domain>
```

Replace `<project_name>` with the name of your project folder and `<custom_domain>` with your desired domain.

## Nginx Configuration

Nginx configurations are automatically generated in `/etc/nginx/sites-enabled/` inside the Docker container. Each configuration proxies requests to the respective Node.js application's port.

## PM2 Process Management

- PM2 is used to manage Node.js applications. It automatically restarts processes and keeps them running.
- The process list is saved using `pm2 save` and restored with `pm2 resurrect` on container startup.

## Troubleshooting

- **Port 80 Already in Use**: Ensure no other services are running on port 80.
- **PM2 Process Not Restored**: Ensure the process list is saved properly using `pm2 save`.

## License

This project is licensed under the MIT License.

## Acknowledgments

Inspired by the need to efficiently manage multiple Node.js apps on a Raspberry Pi using Docker, Nginx, and PM2.
