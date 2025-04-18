FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app files
COPY . .

# Build admin panel
RUN npm run build

# Expose port
EXPOSE 1337

# Start Strapi
CMD ["npm", "run", "develop"]
