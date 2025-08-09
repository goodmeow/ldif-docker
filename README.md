# LDIF Docker Converter - Agent Guide

## Build/Test Commands
- Build and start: `docker compose up --build`
- Start services: `docker compose up -d`
- Stop services: `docker compose down`
- View logs: `docker compose logs -f`
- Restart services: `docker compose restart`
- Health check: `curl http://localhost:8080/health`
- Setup script: `./setup.sh` (automated setup with Docker checks)
- Setup guide: [docs/setup.html](docs/setup.html)

## Architecture
- **Main App**: Apache2-based web server serving LDIF ↔ Excel converter
- **Port**: 8080 (mapped to container port 80)
- **Frontend**: Vanilla HTML/CSS/JavaScript with XLSX.js library
- **Container**: Alpine Linux with Apache2, non-root user (apache-user)
- **Health**: Built-in healthcheck via wget on http://localhost/

## Code Style & Conventions
- **HTML**: Modern semantic structure, responsive design, gradient styling
- **CSS**: CSS Grid/Flexbox layouts, CSS custom properties for colors
- **JavaScript**: ES6+ features, camelCase naming, no frameworks
- **Security**: CORS enabled, security headers, non-root container execution
- **File Structure**: Clean structure with Docker configs and web assets in root
