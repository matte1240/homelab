# 🏠 Base Services for Homelab

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/docker--compose-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Traefik](https://img.shields.io/badge/traefik-%2324ae68.svg?style=for-the-badge&logo=traefik&logoColor=white)](https://traefik.io/)
[![Linux](https://img.shields.io/badge/linux-%23FCC624.svg?style=for-the-badge&logo=linux&logoColor=black)](https://www.linux.org/)

> 🚀 Una suite completa di servizi essenziali per il tuo homelab, gestiti con Docker Compose

## 📑 Indice
- [🔧 Servizi Inclusi](#-servizi-inclusi)
- [⚙️ Prima del Deploy](#️-prima-del-deploy)
- [▶️ Avvio dei Servizi](#️-avvio-dei-servizi)
- [🔒 Sicurezza](#-sicurezza)
- [📝 Note](#-note)

## 🔧 Servizi Inclusi

### 🌐 Traefik 
- **Porte**: 80, 443, 8080
- **URL**: http://traefik.local
- **Funzionalità**:
  - ✨ Reverse proxy automatico
  - 🔄 Load balancing
  - 📊 Dashboard di monitoraggio

### 🎛️ Portainer 
- **Porta**: 9443
- **URL**: http://portainer.local
- **Funzionalità**:
  - 🐳 Gestione container Docker
  - 📱 Interfaccia web intuitiva
  - 📊 Monitoraggio risorse

### 🎯 Heimdall 
- **URL**: http://heimdall.local
- **Funzionalità**:
  - 🎨 Dashboard elegante
  - 🔍 Organizzazione servizi
  - 🎭 Supporto multi-tema

### ⏱️ Uptime Kuma 
- **URL**: http://uptime.local
- **Funzionalità**:
  - 📊 Monitoraggio uptime
  - 🔔 Sistema di notifiche
  - 📱 Interfaccia responsive

### 🔄 Watchtower
- **Funzionalità**:
  - 🔄 Aggiornamenti automatici
  - ⏰ Schedulazione personalizzabile
  - 🧹 Pulizia automatica

### 🛡️ Pi-hole 
- **Porta**: 53
- **URL**: http://pihole.local
- **Funzionalità**:
  - 🚫 Blocco pubblicità
  - 🌐 Server DNS
  - 📊 Statistiche dettagliate

### 🔐 Vaultwarden 
- **URL**: http://vault.local
- **Funzionalità**:
  - 🔒 Gestore password
  - 🔄 Sync multi-device
  - 🔑 2FA integrato

### 🏠 Homer 
- **URL**: http://home.local
- **Funzionalità**:
  - 🎨 Dashboard personalizzabile
  - 🎯 Accesso rapido ai servizi
  - 📱 Design responsive

## ⚙️ Prima del Deploy

### 1️⃣ Configurazione Domini Locali
```bash
sudo nano /etc/hosts
```

Aggiungi:
```
127.0.0.1 traefik.local
127.0.0.1 portainer.local
127.0.0.1 heimdall.local
127.0.0.1 uptime.local
127.0.0.1 pihole.local
127.0.0.1 vault.local
127.0.0.1 home.local
```

### 2️⃣ Creazione Directory
```bash
mkdir -p traefik/data heimdall uptime-kuma pihole/{etc-pihole,etc-dnsmasq.d} vaultwarden homer
```

### 3️⃣ Configurazione
Nel file `compose.yml`:
- 🔑 Modifica `WEBPASSWORD` per Pi-hole
- 🌐 Imposta `SERVERIP` con l'IP del server
- 🕒 Regola il fuso orario se necessario

## ▶️ Avvio dei Servizi

### 🟢 Avvio
```bash
docker compose up -d
```

### 🔴 Arresto
```bash
docker compose down
```

## 🔒 Sicurezza

- 🛡️ `no-new-privileges` attivo su tutti i container
- 📄 Volumi in sola lettura dove possibile
- 🔒 Isolamento di rete per ogni servizio
- 🌐 Routing sicuro tramite Traefik

## 📝 Note

- 💾 Persistenza dati in cartelle locali
- 🔄 Aggiornamenti automatici via Watchtower
- 🌐 Accesso tramite domini .local
- 🔐 Modifica password di default al primo accesso

## 📚 Documentazione Aggiuntiva

- [Traefik Docs](https://doc.traefik.io/traefik/)
- [Portainer Docs](https://docs.portainer.io/)
- [Pi-hole Docs](https://docs.pi-hole.net/)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)

## 🤝 Contribuire

Le pull request sono benvenute! Per modifiche importanti, apri prima un issue per discutere delle modifiche proposte.

## 📜 Licenza

[MIT](https://choosealicense.com/licenses/mit/)
