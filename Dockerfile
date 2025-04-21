# Base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy the full app
COPY . .

# Expose default Strapi port
EXPOSE 1337

# Start the app
CMD ["npm", "start"]
