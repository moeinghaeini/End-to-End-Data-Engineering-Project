# Use Python 3.13 slim image
FROM python:3.13-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV DAGSTER_HOME=/opt/dagster/dagster_home

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY setup.py .
COPY dagster_orchestration/ dagster_orchestration/
COPY dbt_transformation/ dbt_transformation/

# Install Python dependencies
RUN pip install --no-cache-dir -e ".[dev]"

# Create Dagster home directory
RUN mkdir -p /opt/dagster/dagster_home

# Copy DBT profiles for BigQuery (will be overridden by environment variables)
COPY dbt_transformation/config/profiles.yml /root/.dbt/profiles.yml

# Create a non-root user
RUN useradd --create-home --shell /bin/bash dagster
RUN chown -R dagster:dagster /app /opt/dagster
USER dagster

# Expose Dagster port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Default command
CMD ["dagster", "dev", "--host", "0.0.0.0", "--port", "3000"]
