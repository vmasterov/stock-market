FROM node:20.19.0-alpine AS builder

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV} \
    NODE_OPTIONS="--max_old_space_size=8192" \
    CI=true \
    HUSKY=0

ARG WORKDIR=/usr/src/app
WORKDIR $WORKDIR

# Копируем только package.json и lock-файл для кеширования слоёв
COPY package.json package-lock.json ./

RUN npm ci --ignore-scripts --include=dev

COPY . .

RUN npm run build

RUN npm prune --omit=dev

# =============================================================================
# Production stage - оптимизированный runtime образ
# =============================================================================

FROM nginx:1.27-alpine

RUN apk update && apk upgrade --no-cache

# Environment variables для nginx
ENV NGINX_SERVER_EXTRA_CONF_FILEPATH=extra.conf \
    NGINX_NO_DEFAULT_HEADERS=true

# Security headers конфигурация
ENV NGINX_REAL_IP_HEADER=X-Forwarded-For \
    NGINX_SET_REAL_IP_FROM="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

# Копируем nginx конфигурацию
COPY nginx.conf /etc/nginx/extra.conf

# Копируем статические файлы с правильными правами
COPY --chown=wodby:wodby --from=builder /usr/src/app/dist /usr/share/nginx/html

# Копируем шаблон конфигурации
COPY --chown=wodby:wodby --from=builder /usr/src/app/env-config.tpl.js /var/www/html/env-config.tpl.js

# Security: устанавливаем правильные права доступа
RUN find /var/www/html -type f -exec chmod 644 {} \; && \
    find /var/www/html -type d -exec chmod 755 {} \;

# Health check для мониторинга
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Expose порт (документационная цель)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# =============================================================================
# Примеры использования:
# =============================================================================

# Простая сборка:
# docker build -t frontend:latest .

# Сборка с параметрами:
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg PNPM_VERSION=10.11.1 \
#   -t frontend:v1.0.0 .

# Запуск контейнера на порту 3000:
# docker run -d \
#   --name frontend \
#   -p 3000:80 \
#   -e VITE_API_URL=https://api.example.com \
#   -e VITE_ENVIRONMENT=production \
#   frontend:latest

# Альтернативные варианты запуска:
# docker run -d --name frontend -p 3000:80 frontend:latest
# docker run -d --name frontend -p 8080:80 frontend:latest
# docker run -d --name frontend -p 80:80 frontend:latest
