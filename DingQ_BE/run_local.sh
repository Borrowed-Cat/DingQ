#!/bin/bash

# DingQ Backend Local Development Script

set -e

echo "🚀 DingQ Backend Local Development"
echo ""

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker Desktop."
        exit 1
    fi
}

# Function to run with Docker
run_docker() {
    echo "🐳 Running with Docker..."
    check_docker
    
    # Stop existing container if running
    docker-compose down 2>/dev/null || true
    
    # Build and run
    echo "📦 Building Docker image..."
    docker-compose build
    
    echo "🚀 Starting service..."
    docker-compose up
}

# Function to run directly with Python
run_python() {
    echo "🐍 Running with Python..."
    
    # Check if in virtual environment
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo "⚠️ Warning: Not in a virtual environment"
        echo "   Consider running: python -m venv venv && source venv/bin/activate"
    fi
    
    # Install dependencies
    echo "📦 Installing dependencies..."
    pip install -r requirements.txt
    
    # Run the server
    echo "🚀 Starting FastAPI server..."
    cd app
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
}

# Function to test the API
test_api() {
    echo "🧪 Testing API..."
    
    # Wait for server to start
    echo "⏳ Waiting for server to start..."
    sleep 5
    
    # Test health endpoint
    echo "🔍 Testing health endpoint..."
    if curl -f http://localhost:8000/health; then
        echo "✅ Health check passed!"
    else
        echo "❌ Health check failed!"
        return 1
    fi
    
    echo ""
    echo "📖 API Documentation: http://localhost:8000/docs"
    echo "🔍 Health Check: http://localhost:8000/health"
}

# Parse command line arguments
case "${1:-docker}" in
    "docker")
        run_docker
        ;;
    "python")
        run_python
        ;;
    "test")
        test_api
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [docker|python|test|help]"
        echo ""
        echo "Commands:"
        echo "  docker  - Run with Docker Compose (default)"
        echo "  python  - Run directly with Python"
        echo "  test    - Test the running API"
        echo "  help    - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 docker    # Run with Docker"
        echo "  $0 python    # Run with Python"
        echo "  $0 test      # Test API"
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run '$0 help' for usage information."
        exit 1
        ;;
esac 