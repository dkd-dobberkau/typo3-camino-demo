# TYPO3 Camino Demo auf Elestio installieren

Diese Anleitung beschreibt, wie du das TYPO3 v14 Camino Demo auf [Elestio](https://elest.io) deployst.

## Voraussetzungen

- Elestio Account ([Registrierung](https://dash.elest.io/register))
- API Token (Dashboard > Profile > API Tokens)

## Option 1: Terraform + manueller Schritt

Terraform erstellt die Infrastruktur, die Pipeline wird manuell konfiguriert.

### 1. Terraform konfigurieren

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Bearbeite `terraform.tfvars`:

```hcl
elestio_email     = "deine-email@example.com"
elestio_api_token = "dein-api-token"
project_name      = "typo3-camino-demo"
admin_email       = "admin@example.com"
software_password = "SicheresPasswort123!"
```

### 2. Infrastruktur erstellen

```bash
terraform init
terraform apply
```

Terraform erstellt:
- Elestio-Projekt
- CI/CD Target (Server mit Docker)
- SSL-Zertifikat

### 3. Pipeline konfigurieren (manuell)

Nach `terraform apply` erscheint eine Anleitung mit den nächsten Schritten:

1. Gehe zu `https://dash.elest.io/projects/<project-id>`
2. Klicke auf den CI/CD Target "typo3-camino"
3. **Add Pipeline** > **Docker Compose**
4. Kopiere den Inhalt von `elestio/docker-compose.yml`
5. Setze Umgebungsvariablen:
   - `DOMAIN` = `<cname aus terraform output>`
   - `SOFTWARE_PASSWORD` = dein gewähltes Passwort
6. Klicke **Deploy**

### 4. Zugriff

Nach ca. 2-3 Minuten:

- **Frontend:** `https://<cname>.vm.elestio.app`
- **Backend:** `https://<cname>.vm.elestio.app/typo3`
- **Login:** `admin` / `<SOFTWARE_PASSWORD>`

---

## Option 2: Manuell über Dashboard

### 1. Projekt erstellen

1. Gehe zu https://dash.elest.io
2. **New Project** > Name eingeben (z.B. "typo3-demo")

### 2. CI/CD Service hinzufügen

1. Im Projekt: **Add Service** > **CI/CD Pipelines**
2. Wähle Provider und Datacenter:
   - **Hetzner** (EU): `fsn1`, `nbg1`, `hel1`
   - **DigitalOcean** (US/EU): `nyc1`, `ams3`, `fra1`
3. Server-Typ: `SMALL-1C-2G` (ausreichend für Demo)
4. **Create Service**

### 3. Pipeline konfigurieren

1. Klicke auf den erstellten Service
2. **Pipelines** > **Add Pipeline** > **Docker Compose**
3. Füge folgende `docker-compose.yml` ein:

```yaml
services:
  typo3:
    image: ghcr.io/dkd-dobberkau/typo3-camino-demo:latest
    restart: always
    ports:
      - "172.17.0.1:80:80"
    volumes:
      - ./typo3_fileadmin:/var/www/html/public/fileadmin
      - ./typo3_var:/var/www/html/var
      - ./typo3_config:/var/www/html/config
    environment:
      TYPO3_DB_HOST: db
      TYPO3_DB_PORT: 3306
      TYPO3_DB_NAME: typo3
      TYPO3_DB_USERNAME: typo3
      TYPO3_DB_PASSWORD: ${SOFTWARE_PASSWORD:-CaminoDemo123!}
      TYPO3_ADMIN_USERNAME: admin
      TYPO3_ADMIN_PASSWORD: ${SOFTWARE_PASSWORD:-CaminoDemo123!}
      TYPO3_ADMIN_EMAIL: ${ADMIN_EMAIL:-admin@example.com}
      TYPO3_PROJECT_NAME: TYPO3 v14 Camino Demo
      TYPO3_BASE_URL: https://${DOMAIN:-localhost}/
      TYPO3_REVERSE_PROXY_IP: 172.18.0.1
    depends_on:
      db:
        condition: service_healthy

  db:
    image: mariadb:11
    restart: always
    volumes:
      - ./db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${SOFTWARE_PASSWORD:-CaminoDemo123!}
      MYSQL_DATABASE: typo3
      MYSQL_USER: typo3
      MYSQL_PASSWORD: ${SOFTWARE_PASSWORD:-CaminoDemo123!}
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      start_period: 10s
      interval: 10s
      timeout: 5s
      retries: 3
```

### 4. Umgebungsvariablen setzen

Im Pipeline-Editor unter **Environment Variables**:

| Variable | Wert |
|----------|------|
| `DOMAIN` | `<dein-service>.vm.elestio.app` (aus Service-Details) |
| `SOFTWARE_PASSWORD` | Ein sicheres Passwort (min. 10 Zeichen, Groß/Klein/Zahl) |

### 5. Deployen

Klicke **Deploy** und warte ca. 2 Minuten.

---

## Troubleshooting

### "Invalid referrer" Fehler im Backend

**Ursache:** TYPO3 erkennt nicht, dass es hinter einem SSL-Proxy läuft.

**Lösung:** Stelle sicher, dass `TYPO3_REVERSE_PROXY_IP: 172.18.0.1` in der docker-compose.yml gesetzt ist.

Falls der Fehler bei einer bestehenden Installation auftritt:

```bash
# SSH zum Server
docker exec <typo3-container> php -r '
$settings = include "/var/www/html/config/system/settings.php";
$settings["SYS"]["reverseProxyIP"] = "172.18.0.1";
file_put_contents(
    "/var/www/html/config/system/settings.php",
    "<?php\nreturn " . var_export($settings, true) . ";\n"
);
'
docker exec <typo3-container> ./vendor/bin/typo3 cache:flush
```

### Container startet nicht

Prüfe die Logs:

```bash
docker-compose logs typo3
docker-compose logs db
```

### Datenbank-Verbindungsfehler

Warte 30 Sekunden nach dem ersten Start - die Datenbank muss initialisiert werden.

---

## Ressourcen

- [TYPO3 Dokumentation](https://docs.typo3.org/)
- [Camino Theme](https://github.com/TYPO3/theme-camino)
- [Elestio Dokumentation](https://docs.elest.io/)
- [GitHub Repository](https://github.com/dkd-dobberkau/typo3-camino-demo)
