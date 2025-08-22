# 🏠 Homelab Infrastructure

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/docker--compose-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Traefik](https://img.shields.io/badge/traefik-%2324ae68.svg?style=for-the-badge&logo=traefik&logoColor=white)](https://traefik.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> 🚀 Una completa infrastruttura homelab con servizi essenziali gestiti tramite Docker Compose

## 📋 Sommario

- [🎯 Panoramica](#-panoramica)
- [🏗️ Architettura](#️-architettura)
- [🔧 Servizi Disponibili](#-servizi-disponibili)
- [🚀 Quick Start](#-quick-start)
- [📂 Struttura del Progetto](#-struttura-del-progetto)
- [⚙️ Configurazione](#️-configurazione)
- [🔒 Sicurezza](#-sicurezza)
- [📊 Monitoraggio](#-monitoraggio)
- [🛠️ Manutenzione](#️-manutenzione)

## 🎯 Panoramica

Questo repository contiene una completa configurazione homelab basata su Docker Compose, progettata per fornire una suite di servizi essenziali per la gestione dell'infrastruttura domestica. Il setup include reverse proxy, gestione container, monitoraggio, backup delle foto e molto altro.

### ✨ Caratteristiche Principali

- 🐳 **Containerizzazione completa** con Docker Compose
- 🌐 **Reverse proxy automatico** con Traefik
- 📊 **Monitoraggio e gestione** dei servizi
- 🔒 **Sicurezza integrata** con configurazioni hardened
- 🔄 **Aggiornamenti automatici** dei container
- 📱 **Interfacce web intuitive** per tutti i servizi
- 🌍 **DNS dinamico** per accesso remoto
- 📸 **Backup fotografico** self-hosted

## 🏗️ Architettura

```
┌─────────────────────────────────────────────────────────┐
│                    Internet                             │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│              Cloudflare DDNS                            │
│            (Dynamic DNS Update)                         │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────┐
│                Traefik                                  │
│         (Reverse Proxy + Load Balancer)                │
└─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────────┘
      │     │     │     │     │     │     │     │
      ▼     ▼     ▼     ▼     ▼     ▼     ▼     ▼
   ┌────┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌─────┐
   │Port│ │Him│ │Upt│ │Pih│ │Hom│ │Vau│ │Imm│ │Nginx│
   │ner │ │dal│ │ime│ │ole│ │er │ │lt │ │ich│ │ PM  │
   └────┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └─────┘
```

## 🔧 Servizi Disponibili

### 🔄 Tutti i Servizi (Unificati in `base-services/`)

Tutti i servizi sono ora consolidati in un unico file Docker Compose per una gestione semplificata:

| Servizio | Porta | URL | Descrizione |
|----------|-------|-----|-------------|
| **Traefik** | 80, 443, 8080 | `traefik.local` | 🌐 Reverse proxy e load balancer |
| **Portainer** | 9443 | `portainer.local` | 🎛️ Gestione container Docker |
| **Heimdall** | - | `heimdall.local` | 🎯 Dashboard servizi |
| **Uptime Kuma** | - | `uptime.local` | ⏱️ Monitoraggio uptime |
| **Watchtower** | - | - | 🔄 Aggiornamenti automatici |
| **Pi-hole** | 53 | `pihole.local` | 🛡️ DNS e ad-blocking |
| **Vaultwarden** | - | `vault.local` | 🔐 Password manager |
| **Homer** | - | `home.local` | 🏠 Dashboard personalizzabile |

#### 🌍 Dynamic DNS
| **Cloudflare DDNS** | - | - | 🌐 Aggiornamento automatico DNS |

#### 📸 Media Services (Immich)
| **Immich Server** | - | `immich.local` | 📱 Server backup foto e video |
| **PostgreSQL** | - | - | 🗄️ Database per Immich |
| **Redis** | - | - | ⚡ Cache in-memory |
| **Machine Learning** | - | - | 🤖 AI per riconoscimento foto |

#### 🌐 Proxy Management
| **Nginx Proxy Manager** | 8080, 8443, 8181 | `nginx.local` | 🔧 Gestione proxy con UI web |

## 🚀 Quick Start

### Prerequisiti

- 🐳 [Docker](https://docs.docker.com/get-docker/) installato
- 🐙 [Docker Compose](https://docs.docker.com/compose/install/) installato
- 🖥️ Server Linux (Ubuntu/Debian raccomandato)
- 🌐 Dominio configurato (per DNS dinamico)

### Installazione Rapida

1. **Clona il repository:**
   ```bash
   git clone https://github.com/matte1240/homelab.git
   cd homelab
   ```

2. **Configura le variabili di ambiente:**
   ```bash
   # Copia il file di esempio
   cp .env.example .env
   
   # Modifica con i tuoi valori
   nano .env
   ```

3. **Rendi eseguibile lo script di gestione:**
   ```bash
   chmod +x manage.sh
   ```

4. **Avvia tutti i servizi:**
   ```bash
   ./manage.sh start
   ```

5. **Verifica lo stato:**
   ```bash
   ./manage.sh status
   ```

### Accesso ai Servizi

Dopo l'avvio, i servizi saranno disponibili ai seguenti indirizzi:

- 🎛️ **Portainer**: http://portainer.local (gestione container)
- 🎯 **Heimdall**: http://heimdall.local (dashboard servizi)
- ⏱️ **Uptime Kuma**: http://uptime.local (monitoraggio)
- 🛡️ **Pi-hole**: http://pihole.local (DNS admin)
- 🔐 **Vaultwarden**: http://vault.local (password manager)
- 🏠 **Homer**: http://home.local (dashboard personalizzato)
- 📸 **Immich**: http://localhost:2283 (backup foto)
- 🌐 **Traefik Dashboard**: http://traefik.local (reverse proxy)

## 📂 Struttura del Progetto

```
homelab/
├── 📁 base-services/          # Servizi essenziali
│   ├── 🐳 compose.yml         # Stack principale Docker Compose
│   ├── � compose.override.yml # Override per sviluppo
│   ├── �📄 README.md           # Documentazione servizi base
│   └── 📁 traefik/            # Configurazione Traefik
│       ├── ⚙️ traefik.yml      # Configurazione statica
│       └── ⚙️ dynamic.yml     # Configurazione dinamica
├── 📁 dyndns/                 # DNS dinamico
│   └── 🐳 compose.yml         # Cloudflare DDNS
├── 📁 immich/                 # Backup foto/video
│   ├── 🐳 compose.yml         # Stack Immich
│   ├── 🔧 setup.sh            # Script di configurazione
│   ├── 📄 .env.example        # Template variabili ambiente
│   ├── 🚫 .gitignore          # File da escludere
│   └── 📁 library/            # Directory foto (creata automaticamente)
├── 📁 nginx/                  # Nginx Proxy Manager
│   └── 🐳 compose.yml         # Configurazione NPM
├── 🔧 manage.sh               # Script di gestione principale
├── 📄 .env.example            # Template variabili ambiente globali
├── 🚫 .gitignore              # File da escludere da Git
├── 📄 README.md               # Questo file
├── 🛠️ TROUBLESHOOTING.md      # Guida risoluzione problemi
└── 📋 CHANGELOG.md            # Changelog del progetto
```

## 🛠️ Gestione con Script

Il progetto include script di gestione per semplificare le operazioni:

### 🐧 Linux/Mac (Bash)
```bash
# Rendi eseguibile lo script
chmod +x manage.sh

# Avvia tutti i servizi
./manage.sh start

# Avvia un servizio specifico
./manage.sh start base-services

# Mostra lo stato di tutti i servizi
./manage.sh status

# Visualizza i log
./manage.sh logs immich-server 100

# Aggiorna tutti i servizi
./manage.sh update

# Ferma tutti i servizi
./manage.sh stop

# Crea backup delle configurazioni
./manage.sh backup

# Pulizia del sistema Docker
./manage.sh cleanup

# Mostra aiuto
./manage.sh help
```

### 🪟 Windows (PowerShell)
```powershell
# Abilita esecuzione script (una sola volta)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Avvia tutti i servizi
.\manage.ps1 start

# Avvia un servizio specifico
.\manage.ps1 start traefik

# Mostra lo stato di tutti i servizi
.\manage.ps1 status

# Visualizza i log
.\manage.ps1 logs immich-server 100

# Aggiorna tutti i servizi
.\manage.ps1 update

# Ferma tutti i servizi
.\manage.ps1 stop

# Crea backup delle configurazioni
.\manage.ps1 backup

# Pulizia del sistema Docker
.\manage.ps1 cleanup

# Mostra aiuto
.\manage.ps1 help
```

### 📋 Gestione Manuale (Docker Compose)
Se preferisci usare Docker Compose direttamente:
```bash
cd base-services

# Avvia tutti i servizi
docker-compose --env-file ../.env up -d

# Mostra stato
docker-compose ps

# Visualizza log
docker-compose logs -f traefik

# Ferma tutti i servizi
docker-compose down
```

## ⚙️ Configurazione

### 🔧 Configurazione Base Services

1. **Configura le variabili di ambiente nel file `.env`:**
   ```bash
   # Copia il template
   cp .env.example .env
   
   # Modifica i valori richiesti:
   # - CLOUDFLARE_API_TOKEN
   # - DOMAINS  
   # - PIHOLE_WEBPASSWORD
   # - PIHOLE_SERVERIP
   # - TZ (timezone)
   ```

2. **Configura Traefik (opzionale):**
   ```bash
   # I file di configurazione sono già pronti in:
   # - base-services/traefik/traefik.yml
   # - base-services/traefik/dynamic.yml
   
   # Modifica l'email per Let's Encrypt
   nano base-services/traefik/traefik.yml
   ```

### 🌍 Configurazione DNS Dinamico

1. **Ottieni un token API Cloudflare:**
   - Vai su [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
   - Crea un token API con permessi DNS

2. **Configura nel file `.env`:**
   ```bash
   CLOUDFLARE_API_TOKEN=your_token_here
   DOMAINS=your-domain.com
   ```

### 📸 Configurazione Immich

1. **Esegui lo script di setup:**
   ```bash
   cd immich
   ./setup.sh
   ```

2. **Personalizza la configurazione:**
   - Modifica `.env` per configurazioni avanzate
   - Configura SMTP per notifiche email (opzionale)

## 🔒 Sicurezza

### 🛡️ Misure di Sicurezza Implementate

- ✅ **Container non-privilegiati** con `security_opt: no-new-privileges:true`
- ✅ **Filesystem read-only** dove possibile
- ✅ **User/Group ID specifici** per evitare root
- ✅ **Dropped capabilities** Linux per sicurezza aggiuntiva
- ✅ **Network isolation** con reti Docker dedicate
- ✅ **Aggiornamenti automatici** con Watchtower

### 🔐 Raccomandazioni Aggiuntive

1. **Cambia le password predefinite:**
   - Pi-hole admin password
   - Vaultwarden master password

2. **Configura SSL/TLS:**
   - Usa certificati Let's Encrypt
   - Abilita HTTPS redirect

3. **Firewall:**
   - Chiudi porte non necessarie
   - Configura fail2ban (opzionale)

4. **Backup:**
   - Backup regolari delle configurazioni
   - Backup dei volumi Docker importanti

## 📊 Monitoraggio

### 📈 Strumenti di Monitoraggio Inclusi

1. **Uptime Kuma** - Monitoraggio servizi e uptime
2. **Traefik Dashboard** - Metriche reverse proxy
3. **Portainer** - Statistiche container e risorse
4. **Watchtower** - Log aggiornamenti automatici

### 📋 Controlli Raccomandati

- ✅ Status dei container: `docker ps`
- ✅ Log dei servizi: `docker-compose logs [service]`
- ✅ Utilizzo risorse: `docker stats`
- ✅ Spazio disco: `df -h`

## 🛠️ Manutenzione

### 🔄 Operazioni di Routine

1. **Aggiornamento servizi:**
   ```bash
   # Watchtower si occupa degli aggiornamenti automatici
   # Per aggiornamenti manuali:
   docker-compose pull
   docker-compose up -d
   ```

2. **Backup delle configurazioni:**
   ```bash
   # Backup volumi importanti
   docker run --rm -v base-services_portainer_data:/data -v $(pwd):/backup alpine tar czf /backup/portainer_backup.tar.gz -C /data .
   ```

3. **Pulizia sistema:**
   ```bash
   # Rimuovi immagini inutilizzate
   docker system prune -a
   
   # Rimuovi volumi orfani
   docker volume prune
   ```

### 🚨 Troubleshooting

Per problemi comuni e soluzioni dettagliate, consulta la [Guida Troubleshooting](./TROUBLESHOOTING.md).

#### Comandi di Diagnostica Rapida

```bash
# Verifica stato servizi
./manage.sh status

# Controlla log di un servizio
./manage.sh logs service_name 100

# Verifica risorse Docker
docker system df

# Controlla container in esecuzione
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

#### Problemi Comuni

1. **Servizio non raggiungibile:**
   - Verifica che il container sia in esecuzione: `docker ps`
   - Controlla i log: `./manage.sh logs service_name`
   - Verifica la configurazione DNS locale

2. **Errori di permessi:**
   - Controlla ownership delle directory: `ls -la`
   - Verifica PUID/PGID nei compose file

3. **Problemi di rete:**
   - Verifica le reti Docker: `docker network ls`
   - Controlla conflitti di porte: `netstat -tulpn`

#### Log Importanti

```bash
# Log servizi principali
./manage.sh logs traefik 50

# Log Pi-hole
./manage.sh logs pihole 50

# Log Immich
./manage.sh logs immich-server 50
```

---

## 📝 Note

- **Timezone**: Configurato per `Europe/Rome` - modifica se necessario
- **DNS locale**: Configura `*.local` nel tuo router o file hosts
- **Cloudflare**: Token API richiesto per DNS dinamico
- **Backup**: Implementa una strategia di backup per i dati critici

## 🤝 Contributi

Contributi, issue e feature request sono benvenuti! Sentiti libero di:

1. 🍴 Fork del progetto
2. 🔧 Crea un feature branch
3. 💡 Commit delle modifiche
4. 📤 Push del branch
5. 🔄 Apri una Pull Request

## 📄 Licenza

Questo progetto è rilasciato sotto licenza MIT. Vedi il file `LICENSE` per i dettagli.

---

**⭐ Se questo progetto ti è stato utile, lascia una stella!**