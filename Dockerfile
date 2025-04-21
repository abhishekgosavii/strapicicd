# FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (optional but recommended for better caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files into the container
COPY . /app

# Expose the port your app will run on
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]
