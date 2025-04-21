FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy the rest of your app
COPY . .

# Expose port and set command
EXPOSE 1337
CMD ["npm", "start"]
