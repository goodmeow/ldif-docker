# Use Apache2 with Alpine Linux for smaller size
FROM httpd:2.4-alpine

# Install additional packages for security and functionality
RUN apk add --no-cache \
    wget \
    curl \
    && rm -rf /var/cache/apk/*

# Copy the HTML files to Apache document root
COPY index.html /usr/local/apache2/htdocs/
COPY health.html /usr/local/apache2/htdocs/

# Copy custom Apache config
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Create a non-root user for security
RUN addgroup -g 1001 -S apache-user && \
    adduser -S -D -H -u 1001 -h /usr/local/apache2 -s /sbin/nologin -G apache-user -g apache-user apache-user

# Set proper permissions for Apache directories
RUN chown -R apache-user:apache-user /usr/local/apache2/htdocs && \
    chown -R apache-user:apache-user /usr/local/apache2/logs && \
    chown -R apache-user:apache-user /usr/local/apache2/conf && \
    chmod -R 755 /usr/local/apache2/htdocs && \
    chmod -R 755 /usr/local/apache2/logs

# Create run directory and set permissions
RUN mkdir -p /usr/local/apache2/run && \
    chown -R apache-user:apache-user /usr/local/apache2/run

# Switch to non-root user
USER apache-user

# Expose port 80
EXPOSE 80

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start Apache in foreground
CMD ["httpd-foreground"]
