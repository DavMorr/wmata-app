# Use Node.js 20 LTS
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install dependencies for better Docker layer caching
COPY package*.json ./
RUN npm ci

# Copy application source
COPY . .

# Create entrypoint script for development
RUN echo '#!/bin/sh\n\
set -e\n\
\n\
echo "Installing/updating dependencies..."\n\
npm ci\n\
\n\
echo "Starting Vite development server..."\n\
exec npm run dev -- --host 0.0.0.0 --port 5173' > /usr/local/bin/start-dev.sh

RUN chmod +x /usr/local/bin/start-dev.sh

# Expose Vite port
EXPOSE 5173

# Use development entrypoint by default
CMD ["/usr/local/bin/start-dev.sh"]