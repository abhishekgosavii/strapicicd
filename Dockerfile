# Use the official Node.js runtime as a parent image
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /strapiyml

# Copy package.json and package-lock.json first (optional but recommended for better caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code into the container
COPY . .

# Expose the port your app runs on (assuming your app uses port 3000)
EXPOSE 3000

# Run the application
CMD ["npm", "start"]
