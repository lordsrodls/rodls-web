# rodls.me

Site personnel — Astro statique servi via Nginx derrière Traefik.
Même architecture que boyebois.

## Développement local

```bash
npm install
npm run dev    # http://localhost:4321
```

## Build

```bash
npm run build  # génère ./dist/
```

## Déploiement sur le VPS

Architecture : on build localement, on push le `dist/` sur le VPS dans
`/opt/docker/rodls-site/site/`, puis Nginx (en conteneur) sert ces fichiers.
**Pas de build sur le VPS** — il ne fait que servir des fichiers statiques.

### Première installation

```bash
# Sur le VPS, créer le dossier
ssh rod@rodls.me
mkdir -p /opt/docker/rodls-site
exit

# Depuis ta machine locale, copier les fichiers de config
scp -P 2002 docker-compose.yml nginx.conf rod@rodls.me:/opt/docker/rodls-site/

# Build local
npm run build

# Push du site compilé
rsync -avz --delete -e "ssh -p 2002" dist/ rod@rodls.me:/opt/docker/rodls-site/site/
# ou en scp :
# scp -P 2002 -r dist/* rod@rodls.me:/opt/docker/rodls-site/site/

# Démarrer le conteneur
ssh rod@rodls.me
cd /opt/docker/rodls-site
docker compose up -d
docker logs -f rodls
```

### Mises à jour ultérieures

```bash
npm run build
rsync -avz --delete -e "ssh -p 2002" dist/ rod@rodls.me:/opt/docker/rodls-site/site/
# pas besoin de redémarrer Nginx, il sert direct les nouveaux fichiers
```

Si tu modifies `nginx.conf` :

```bash
scp -P 2002 nginx.conf rod@rodls.me:/opt/docker/rodls-site/
ssh rod@rodls.me 'docker exec rodls nginx -t && docker exec rodls nginx -s reload'
```

## Éditer les projets affichés

Ouvre `src/pages/index.astro`, la liste `projects` en haut du fichier.
Chaque item : `{ name, url, status: 'live' | 'soon' }`.

## Personnaliser la palette

Tout est dans `src/styles/global.css` — variables CSS `--moss-*` et `--paper*`.

## Prérequis sur le VPS

- Réseau Docker `web` créé (`docker network create web`)
- Traefik tourne et a accès aux middlewares :
  - `secure-headers-public@file`
  - `compress@file`
  - `redirect-www-to-apex@file` (défini par le compose ici, partagé)
- DNS : enregistrements A pour `rodls.me` et `www.rodls.me` → IP du VPS
