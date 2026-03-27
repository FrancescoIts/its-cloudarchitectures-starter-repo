FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install

COPY app/ .

EXPOSE 3000

# --interval=5s   → controlla ogni 5 secondi
# --timeout=3s    → aspetta max 3 secondi per la risposta
# --retries=5     → dopo 5 fallimenti consecutivi → "unhealthy"
HEALTHCHECK --interval=5s --timeout=3s --retries=5 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
