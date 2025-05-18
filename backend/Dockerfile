# Stage 1: Build dependencies
FROM node:22-alpine AS builder
WORKDIR /app

# Only copy package files first to optimize caching
COPY package*.json ./
RUN npm install --production

# Copy only required app files
COPY . .

# Stage 2: Create minimal image
FROM node:22-alpine AS runner
WORKDIR /app

# Copy only the necessary files from the builder
COPY --from=builder /app /app

EXPOSE 3001

CMD ["node", "index.js"]
