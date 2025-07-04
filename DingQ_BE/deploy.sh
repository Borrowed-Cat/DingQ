#!/bin/bash

# DingQ Backend Deployment Script for GCP Cloud Run (CLIP Model Optimized)

set -e

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"
REGION="${GCP_REGION:-us-central1}"
SERVICE_NAME="dingq-backend"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "🚀 Starting DingQ Backend deployment..."
echo "📋 Project: $PROJECT_ID"
echo "🌍 Region: $REGION"

# Check if gcloud is configured
if ! gcloud config get-value project > /dev/null 2>&1; then
    echo "❌ gcloud not configured. Please run:"
    echo "   gcloud auth login"
    echo "   gcloud config set project $PROJECT_ID"
    exit 1
fi

# Set project
echo "📋 Setting project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build and push Docker image using Cloud Build (faster than local build)
echo "🏗️ Building image with Cloud Build..."
gcloud builds submit --tag $IMAGE_NAME .

# Deploy to Cloud Run with optimized settings for CLIP model
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --memory 4Gi \
    --cpu 2 \
    --timeout 300 \
    --concurrency 10 \
    --max-instances 5 \
    --min-instances 1 \
    --port 8000 \
    --set-env-vars "PYTHONPATH=/app,PYTHONUNBUFFERED=1"

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo ""
echo "✅ Deployment completed!"
echo "🌐 Service URL: $SERVICE_URL"
echo "📊 Health Check: $SERVICE_URL/health"
echo "📖 API Docs: $SERVICE_URL/docs"
echo ""
echo "🔍 Testing deployment..."

# Wait for service to be ready
sleep 10

# Test health endpoint
if curl -f "$SERVICE_URL/health" > /dev/null 2>&1; then
    echo "✅ Health check passed!"
else
    echo "⚠️ Health check failed. Check logs:"
    echo "   gcloud logs read --service=$SERVICE_NAME --region=$REGION --limit=50"
fi

echo ""
echo "📝 Useful commands:"
echo "   View logs: gcloud logs read --service=$SERVICE_NAME --region=$REGION --limit=50"
echo "   Update service: gcloud run services update $SERVICE_NAME --region=$REGION"
echo "   Delete service: gcloud run services delete $SERVICE_NAME --region=$REGION" 