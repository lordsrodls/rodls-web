# ===== Stage 1 : build Astro =====
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ===== Stage 2 : nginx servant le dist =====
FROM nginx:alpine AS runner

# Ton nginx.conf existant
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Le build Astro (dist/) dans le webroot
COPY --from=builder /app/dist /usr/share/nginx/html

# Le port doit matcher ton nginx.conf (listen 8080)
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1