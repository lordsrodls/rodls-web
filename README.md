# rodls.me

Site personnel — [Astro](https://astro.build) statique servi par Nginx, déployé en continu via GitHub Actions.

## Stack

- **Framework** : Astro (output statique)
- **Runtime** : Nginx (image Docker custom)
- **Hébergement** : VPS auto-hébergé, derrière Traefik
- **Auth** : oauth2-proxy + Google (site privé)
- **Registry** : GitHub Container Registry (`ghcr.io/lordsrodls/rodls-web`)
- **CD** : Watchtower (pull-based)

## Développement local

```bash
npm install
npm run dev          # serveur de dev avec hot reload, http://localhost:4321
```

### Valider un build de production

```bash
npm run build        # génère ./dist/
npm run preview      # sert le build sur http://localhost:4321
```

### (Optionnel) Tester le conteneur complet

Reproduit exactement ce qui sera déployé (Nginx + config + cache headers) :

```bash
docker build -t rodls-web:test .
docker run --rm -p 8080:8080 rodls-web:test
# http://localhost:8080
```

## Workflow de contribution

Le repo suit le [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow) : `main` est protégée, toute modification passe par une Pull Request.

```bash
git checkout main && git pull
git checkout -b feat/nom-de-la-feature
# ... code, commit ...
git push origin feat/nom-de-la-feature
```

Ouvrir une PR sur GitHub, attendre que le job `validate` passe, puis **Squash and merge**.

Le merge sur `main` déclenche automatiquement :

1. Build de l'image Docker par le runner self-hosted
2. Push sur GHCR (`ghcr.io/lordsrodls/rodls-web:latest`)
3. Détection par Watchtower (~2 min) → pull + redémarrage du conteneur
4. Site à jour sur [rodls.me](https://rodls.me)

## Structure

```
.
├── src/
│   ├── layouts/Base.astro      # Layout principal
│   ├── pages/index.astro       # Page d'accueil + liste des projets
│   └── styles/global.css       # Palette et variables CSS
├── public/                     # Assets servis tels quels
├── Dockerfile                  # Build multi-stage (Node → Nginx)
├── nginx.conf                  # Config Nginx (port 8080, cache, headers)
└── .github/workflows/
    └── build-and-deploy.yml    # CI : validate sur PR, push GHCR sur main
```

### Éditer les projets affichés

`src/pages/index.astro`, tableau `projects` en haut du fichier.
Chaque item : `{ name, url, status: 'live' | 'soon' }`.

### Personnaliser la palette

`src/styles/global.css` — variables CSS `--moss-*` et `--paper-*`.

## Infrastructure (référence)

Le déploiement se fait sur un VPS perso. Le `docker-compose.yml` de production vit sur le serveur (`/opt/docker/rodls-site/`), pas dans ce repo.

**Prérequis VPS** :

- Réseau Docker `web` (`docker network create web`)
- Traefik avec accès aux middlewares :
  - `oauth-signin@docker` et `oauth-google@docker` (oauth2-proxy)
  - `secure-headers@docker`
- DNS Cloudflare : `rodls.me` et `www.rodls.me` → IP du VPS
- Watchtower configuré pour surveiller les conteneurs labellisés `com.centurylinklabs.watchtower.enable=true`

## Rollback

En cas de besoin, restaurer une version précédente depuis le VPS :

```bash
# Lister les versions disponibles
docker images ghcr.io/lordsrodls/rodls-web

# Pointer le compose sur un tag spécifique
cd /opt/docker/rodls-site
# Éditer docker-compose.yml : image: ghcr.io/lordsrodls/rodls-web:sha-abc1234
docker compose up -d
```

## Licence

Personnel — tout droit réservé.