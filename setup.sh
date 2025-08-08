#!/bin/bash

# LDIF Converter Docker Setup Script with Apache2
# Run this script in WSL2 to set up the application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker Desktop with WSL2 integration."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Check if Docker Compose is available
check_docker_compose() {
    print_status "Checking Docker Compose..."
    
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        print_error "Docker Compose is not available"
        exit 1
    fi
    
    print_success "Docker Compose is available: $COMPOSE_CMD"
}

# Verify project structure
setup_project() {
    print_status "Verifying project structure..."
    
    # Check for required files
    if [ ! -f "index.html" ]; then
        print_error "index.html not found. The LDIF converter requires this file."
        exit 1
    fi
    
    if [ ! -f "Dockerfile" ]; then
        print_error "Dockerfile not found. Please ensure you're in the correct directory."
        exit 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found. Please ensure you're in the correct directory."
        exit 1
    fi
    
    print_success "Project structure verified"
}

# Build and start the application
start_application() {
    print_status "Building and starting the LDIF Converter..."
    
    # Stop any existing containers
    if $COMPOSE_CMD ps | grep -q ldif-converter; then
        print_status "Stopping existing containers..."
        $COMPOSE_CMD down
    fi
    
    # Build and start
    $COMPOSE_CMD up --build -d
    
    if [ $? -eq 0 ]; then
        print_success "LDIF Converter is now running!"
        print_success "Access it at: http://localhost:8080"
    else
        print_error "Failed to start the application"
        exit 1
    fi
}

# Show application status
show_status() {
    print_status "Application status:"
    $COMPOSE_CMD ps
    
    echo ""
    print_status "To view logs: $COMPOSE_CMD logs -f"
    print_status "To stop: $COMPOSE_CMD down"
    print_status "To restart: $COMPOSE_CMD restart"
    
    # Check if port 8080 is accessible
    if curl -s http://localhost:8080 > /dev/null; then
        print_success "Application is responding at http://localhost:8080"
    else
        print_warning "Application may not be ready yet. Wait a moment and check http://localhost:8080"
    fi
}

# Main execution
main() {
    echo "==================================="
    echo "LDIF Converter Docker Setup"
    echo "==================================="
    
    check_docker
    check_docker_compose
    setup_project
    start_application
    show_status
    
    echo ""
    print_success "Setup complete! Your LDIF Converter is ready to use."
    echo ""
    echo "Quick commands:"
    echo "  View logs:    $COMPOSE_CMD logs -f"
    echo "  Stop app:     $COMPOSE_CMD down"
    echo "  Restart app:  $COMPOSE_CMD restart"
    echo "  Rebuild app:  $COMPOSE_CMD up --build"
}

# Run main function
main
