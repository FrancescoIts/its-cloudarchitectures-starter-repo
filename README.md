
### Pipeline 1 — CI Base (`ci.yml`)

**Obiettivo**: prima pipeline CI funzionante con build Docker.

| Trigger | Branch | Job |
|---|---|---|
| push | tutti | `build` |

**Steps**: checkout → setup Node 18 → install → test → build Docker image

```yaml
# Esegue build e test ad ogni push
# L'immagine Docker viene costruita ma NON pubblicata
```

---

### Pipeline 2 — CI + Docker Hub Delivery, senza artifact (`ci-delivery.yml`)

**Obiettivo**: separare CI e CD in due job distinti con `needs`.

| Trigger | Branch | Job 1 | Job 2 |
|---|---|---|---|
| push / pull_request | tutti (build) · main (deploy) | `build` | `deploy` |

**Novità rispetto alla precedente**:
- Job `deploy` separato che parte solo se `build` è verde (`needs: build`)
- Deploy attivo solo su `main` (`if: github.ref == 'refs/heads/main'`)
- Login Docker Hub via `docker/login-action@v3` con secrets
- Push immagine su Docker Hub con tag `latest`

```yaml
# Il job deploy parte SOLO se build è verde E il branch è main
if: github.ref == 'refs/heads/main'
```

---

### Pipeline 3 — CI + Docker Hub Delivery, con artifact (`ci-delivery-artifact.yml`)

**Obiettivo**: evitare di ricostruire l'immagine due volte usando gli artifact di GitHub Actions.

| Trigger | Branch | Job 1 | Job 2 |
|---|---|---|---|
| push / pull_request | tutti (build) · main (deploy) | `build` | `Load & Push to Docker Hub` |

**Novità rispetto alla precedente**:
- L'immagine viene costruita una sola volta nel job `build`
- Salvata come file `image.tar.gz` e caricata come artifact (`upload-artifact@v4`)
- Il job `deploy` scarica l'artifact (`download-artifact@v4`) e la ricarica con `docker load`
- Nessuna doppia build: stessa immagine testata e poi pubblicata

```yaml
# Build una volta, riusa ovunque
docker save its-node-demo:latest | gzip > image.tar.gz
# ...
gunzip -c image.tar.gz | docker load
```

---

### Pipeline 4 — CI Docker Build con tag SHA e run ID (`ci-docker-build.yml`)

**Obiettivo**: taggare le immagini in modo univoco e tracciabile.

| Trigger | Branch | Job |
|---|---|---|
| push | tutti | `docker-build` |

**Novità rispetto alle precedenti**:
- Due tag per ogni immagine: `SHA del commit` e `run_id-run_number`
- Nessun tag `latest` generico → ogni immagine è tracciabile al commit esatto
- Entrambi i tag vengono pushati su Docker Hub

```yaml
# Doppio tag per massima tracciabilità
docker build -t $IMAGE_NAME:${{ github.sha }} .
docker tag $IMAGE_NAME:${{ github.sha }} $IMAGE_NAME:${{ env.DATE_TAG }}
```

---

### Pipeline 5 — CI Scalare con Matrix (`ci-scalare-matrix.yml`)

**Obiettivo**: testare su più versioni di Node.js in parallelo e bloccare la build se anche solo un test fallisce.

| Trigger | Branch | Job 1 | Job 2 |
|---|---|---|---|
| push | main | `test-matrix` (×3 paralleli) | `build-image` |

**Novità rispetto alle precedenti**:
- `strategy.matrix` lancia 3 run parallele: Node 16, 18, 20
- `build-image` parte solo se **tutte e tre** le run della matrice sono verdi
- Tag immagine basato su `github.sha` per tracciabilità
- Push su Docker Hub con tag SHA

```yaml
strategy:
  matrix:
    node-version: [16, 18, 20]
```