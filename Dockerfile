# Use Apache2 with Alpine Linux for smaller size - pin specific version
FROM httpd:2.4-alpine

# Install additional packages for security and functionality
RUN apk add --no-cache \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Copy the HTML files to Apache document root
COPY index.html /usr/local/apache2/htdocs/
COPY health.html /usr/local/apache2/htdocs/
COPY ldap-tutorial.html /usr/local/apache2/htdocs/
COPY features.html /usr/local/apache2/htdocs/

# Copy custom Apache config
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# No custom entrypoint needed - use standard httpd-foreground

# Set proper permissions for Apache directories (www-data already exists)
RUN chown -R www-data:www-data /usr/local/apache2/htdocs && \
    chown -R www-data:www-data /usr/local/apache2/logs && \
    chown -R www-data:www-data /usr/local/apache2/conf && \
    chmod -R 755 /usr/local/apache2/htdocs && \
    chmod -R 755 /usr/local/apache2/logs && \
    chmod 644 /usr/local/apache2/conf/httpd.conf && \
    find /usr/local/apache2/htdocs -name "*.html" -exec chmod 644 {} \;

# Create run directory and set permissions
RUN mkdir -p /usr/local/apache2/run && \
    chown -R www-data:www-data /usr/local/apache2/run && \
    chmod 755 /usr/local/apache2/run

# Remove unnecessary files and packages for security
RUN rm -rf /usr/local/apache2/htdocs/index.html.bak \
    /usr/local/apache2/cgi-bin \
    /usr/local/apache2/manual \
    /usr/local/apache2/error \
    /usr/local/apache2/icons \
    && find /usr/local/apache2 -name "*.default" -delete \
    && find /usr/local/apache2 -name "*.sample" -delete

# Switch to non-root user
USER www-data

# Expose port 80
EXPOSE 80

# Add comprehensive health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider --timeout=5 http://localhost/ || exit 1

# Start Apache in foreground with proper signal handling
CMD ["httpd-foreground"]
