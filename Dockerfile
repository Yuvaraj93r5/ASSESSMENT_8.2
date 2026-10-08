# Use the official Nginx lightweight image
FROM nginx:alpine

# Copy the HTML file to the default Nginx web root directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to the outside world
EXPOSE 80
