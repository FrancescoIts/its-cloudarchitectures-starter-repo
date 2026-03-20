
# ITS Node Starter
Progetto per esercizi di Docker + CI/CD.


# Esercizio1 – Parte 1: Build

## 🎯 Obiettivo
Costruire l’immagine Docker dell’applicazione Node.js fornita e preparare la documentazione necessaria per eseguire il progetto in container.

---

## 📂 Struttura del progetto iniziale
```
/src
   index.js
   package.json
README.md
```

L’applicazione espone una semplice API HTTP su una porta (es. 3000).

---

## ✅ Attività da svolgere

### 1. Analisi del progetto
- Leggi `index.js` per capire:
  - su quale porta ascolta l’applicazione
  - quali dipendenze sono necessarie
  - quale comando avvia l’applicazione
- Controlla `package.json` e verifica che esista lo script:

```js
"start": "node index.js"
```

**Se non è presente, aggiungilo.**

---

### 2. Creazione del Dockerfile

Nella cartella principale crea un file chiamato: **Dockerfile**


**Contenuto del file**
```docker
FROM node:18-alpine

WORKDIR /app

COPY app/package.json ./
RUN npm install

COPY app/ .

EXPOSE 3000
CMD ["node", "server.js"]
```

Il Dockerfile include:
- un’immagine base ufficiale Node.js **FROM**
- la definizione della working directory **WORKDIR**
- copia di `package.json` + installazione dipendenze **COPY** + **RUN**
- copia dell’applicazione **COPY**
- esposizione della porta corretta **EXPOSE**
- comando di avvio tramite `CMD` **CMD**


---

### 3. Costruzione dell’immagine
Esegui Senza Tag:
```shell
docker build -t its-node-demo .
```

oppure Con Tag:
```shell
docker build -t its-node-demo:1.0.0 .
```

---

### 4. Avvio del container

Esegui Senza Tag:
```shell
docker run --name its-node-container -p 8181:3000 its-node-demo
```

oppure Con Tag:
```shell
docker run --name its-node-container -p 8181:3000 its-node-demo:1.0.0
```

Poi apri il browser su:

```
http://localhost:3000
```

**Verifica che l’app risponda correttamente.**