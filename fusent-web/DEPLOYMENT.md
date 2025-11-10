# Деплой Fusent Frontend на Production

## Проблема
`npm run dev` НЕ ДОЛЖЕН использоваться на production сервере! Он падает из-за:
- Утечек памяти в dev-режиме
- Отсутствия автоматического перезапуска
- Не оптимизирован для длительной работы

## Правильный Деплой

### 1. Установить PM2 (Process Manager)
```bash
npm install -g pm2
```

### 2. Настроить переменные окружения

На production сервере используется файл `.env.production`:
```bash
cd fusent-web

# Файл .env.production уже настроен для вашего сервера:
# NEXT_PUBLIC_API_URL=http://85.113.27.42:901/api/v1
# NEXT_PUBLIC_APP_URL=http://85.113.27.42:900
# NEXT_PUBLIC_MINIO_URL=http://85.113.27.42:9000

# Если нужно изменить - отредактируйте .env.production
```

⚠️ **Важно**: Файл `.env.production` используется при `npm run build`,
а `.env.local` - только для локальной разработки.

### 3. На сервере - сделать production build
```bash
cd fusent-web

# Установить зависимости
npm install

# Собрать production build (будет использован .env.production)
npm run build

# Запустить с PM2 (автоматический перезапуск)
pm2 start ecosystem.config.js

# Сохранить конфигурацию для автозапуска после перезагрузки сервера
pm2 save
pm2 startup
```

### 4. Управление процессом

```bash
# Проверить статус
pm2 status

# Посмотреть логи
pm2 logs fusent-web

# Перезапустить
pm2 restart fusent-web

# Остановить
pm2 stop fusent-web

# Мониторинг в реальном времени
pm2 monit
```

### 5. После изменений кода

```bash
cd fusent-web
git pull
npm install
npm run build
pm2 restart fusent-web
```

## Альтернатива - Docker (еще лучше)

Создать `Dockerfile` в `fusent-web/`:

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]
```

Затем в `next.config.js` добавить:
```js
output: 'standalone',
```

И запускать:
```bash
docker build -t fusent-web .
docker run -d -p 3000:3000 --name fusent-web --restart always fusent-web
```

## Проверка памяти

```bash
# Проверить использование памяти
pm2 monit

# Если процесс использует > 1GB, PM2 автоматически перезапустит
```

## Логи

Логи сохраняются в `fusent-web/logs/`:
- `err.log` - ошибки
- `out.log` - стандартный вывод
- `combined.log` - все вместе

```bash
# Посмотреть последние ошибки
tail -f logs/err.log

# Посмотреть все логи
pm2 logs fusent-web
```

## Важно!
**НИКОГДА не используйте `npm run dev` на production!**
Только `npm run build` + `npm start` (или PM2)
