# Optimized single-stage build for better resource management
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    cmake \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libpq-dev \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash app

# Set working directory
WORKDIR /app

# Copy requirements and install in stages to optimize Docker layer caching
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip

# Install all Python dependencies (CPU-only PyTorch wheel index)
ENV PIP_EXTRA_INDEX_URL=https://download.pytorch.org/whl/cpu
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Copy Google Cloud Service Account key
COPY gcs-service-account.json /app/gcs-service-account.json

# Set GCS environment variables
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/gcs-service-account.json
ENV GCS_BUCKET_NAME=dingq-generated-icons

# Set Gemini AI API key from environment variable (NO hardcoded values!)
# ENV GOOGLE_API_KEY will be set at runtime via docker run -e

# Create .env file from environment variables
RUN echo "Creating .env file from environment variables"

# Change ownership to app user
RUN chown -R app:app /app

# Switch to non-root user
USER app

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
