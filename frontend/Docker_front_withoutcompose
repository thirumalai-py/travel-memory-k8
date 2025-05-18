# Use a specific Node version (e.g., 18 or 20; 22 is quite new and might have compatibility issues)
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and lock file first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the code
COPY . .

# Expose the port (React dev server default is 3000)
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
