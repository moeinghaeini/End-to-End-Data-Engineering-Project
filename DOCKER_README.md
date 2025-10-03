# Docker Setup for End-to-End Data Engineering Project

This guide explains how to run the End-to-End Data Engineering Project using Docker.

## Prerequisites

- Docker and Docker Compose installed
- Google Cloud Platform credentials (for BigQuery integration)

## Quick Start

### 1. Environment Setup

Copy the environment template and configure your settings:

```bash
cp env.example .env
```

Edit `.env` with your actual values:

```bash
# Required: Update these with your actual values
DBT_BIGQUERY_PROJECT=your-actual-gcp-project-id
DBT_BIGQUERY_DATASET=your_actual_dataset_name
DBT_BIGQUERY_LOCATION=US
DBT_BIGQUERY_KEYFILE_PATH=/app/credentials/gcp-key.json
```

### 2. GCP Credentials Setup

Create a credentials directory and add your GCP service account key:

```bash
mkdir -p credentials
# Copy your GCP service account JSON key to credentials/gcp-key.json
```

### 3. Build and Run

```bash
# Build the Docker image
docker-compose build

# Start the services
docker-compose up -d

# View logs
docker-compose logs -f dagster
```

### 4. Access the Application

- **Dagster UI**: http://localhost:3000
- **Health Check**: http://localhost:3000/health

## Docker Commands

### Basic Operations

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Rebuild and restart
docker-compose up --build -d
```

### Development Mode

```bash
# Run with live code reloading
docker-compose up -d
# Edit your code - changes will be reflected automatically
```

### DBT Operations

```bash
# Run DBT commands inside the container
docker-compose exec dagster dbt run
docker-compose exec dagster dbt test
docker-compose exec dagster dbt docs generate

# Or use the dedicated DBT service
docker-compose --profile dbt-only up -d dbt
docker-compose exec dbt dbt run
```

### Debugging

```bash
# Access container shell
docker-compose exec dagster bash

# Check container status
docker-compose ps

# View container logs
docker-compose logs dagster
```

## Services

### Main Services

- **dagster**: Main orchestration service with Dagster UI
- **dbt**: Standalone DBT service (optional, use with `--profile dbt-only`)

### Volumes

- **dagster_storage**: Persistent storage for Dagster metadata
- **./dagster_orchestration**: Live code mounting for development
- **./dbt_transformation**: Live DBT code mounting
- **./credentials**: GCP credentials (read-only)

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DBT_BIGQUERY_PROJECT` | GCP Project ID | Required |
| `DBT_BIGQUERY_DATASET` | BigQuery Dataset | Required |
| `DBT_BIGQUERY_LOCATION` | BigQuery Location | US |
| `DBT_BIGQUERY_KEYFILE_PATH` | Path to GCP key file | /app/credentials/gcp-key.json |
| `DAGSTER_HOME` | Dagster home directory | /opt/dagster/dagster_home |

### Ports

- **3000**: Dagster UI
- **8000**: Airbyte (if configured)

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure Docker has access to your credentials directory
2. **BigQuery Connection Failed**: Verify your GCP credentials and project settings
3. **Port Already in Use**: Change the port mapping in docker-compose.yml

### Health Checks

```bash
# Check if Dagster is running
curl http://localhost:3000/health

# Check container health
docker-compose ps
```

### Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs dagster
docker-compose logs dbt

# Follow logs in real-time
docker-compose logs -f dagster
```

## Production Considerations

For production deployment:

1. Use environment-specific configuration files
2. Set up proper secrets management
3. Configure persistent volumes for data
4. Set up monitoring and logging
5. Use Docker secrets for sensitive data

## Development Workflow

1. **Code Changes**: Edit files locally - changes are reflected in the container
2. **Dependency Updates**: Rebuild the image when requirements change
3. **Database Changes**: Use DBT migrations and version control
4. **Testing**: Run tests inside the container environment

## Cleanup

```bash
# Stop and remove containers
docker-compose down

# Remove volumes (WARNING: This will delete all data)
docker-compose down -v

# Remove images
docker-compose down --rmi all
```
