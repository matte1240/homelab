# 🚀 Homelab Setup Guide

## Quick Start - Interactive Setup

Per la configurazione iniziale del tuo homelab, usa il wizard interattivo:

```bash
./manage.sh setup
```

Il wizard ti guiderà attraverso la configurazione di:

### 🌍 Configurazione Generale
- **Timezone**: Imposta il fuso orario del sistema
- **Configurazione di rete**: Subnet Docker personalizzata

### ☁️ Cloudflare DDNS (Opzionale)
- **API Token**: Per aggiornamenti DNS dinamici
- **Dominio**: Il tuo dominio principale

### 🛡️ Pi-hole (DNS & Ad Blocking)
- **Password**: Password sicura per l'interfaccia web
- **IP Server**: IP locale del server Pi-hole (auto-rilevato)

### 📸 Immich (Gestione Foto)
- **Percorso Upload**: Dove salvare le foto
- **Password Database**: Password sicura per PostgreSQL
- **JWT Secret**: Generato automaticamente

### 📧 SMTP (Opzionale)
- **Server SMTP**: Per notifiche email
- **Credenziali**: Username e password
- **Configurazione**: Porta e sicurezza

## Funzionalità del Setup Wizard

### ✨ Auto-rilevamento
- **IP Locale**: Rileva automaticamente l'IP del server
- **Timezone**: Usa il timezone di sistema corrente
- **Validazione**: Controlla password e configurazioni

### 🔐 Sicurezza
- **Password Forti**: Richiede almeno 8 caratteri
- **JWT Random**: Genera token sicuri automaticamente
- **Password Nascoste**: Input sicuro per credenziali sensibili

### 📝 Configurazione Intelligente
- **Valori Default**: Propone configurazioni ragionevoli
- **Sovrascrittura**: Permette di riconfigurare installazioni esistenti
- **Validazione**: Verifica la correttezza dei dati inseriti

## Utilizzo Post-Setup

Dopo aver completato il setup:

```bash
# Avvia tutti i servizi
./manage.sh start

# Controlla lo stato
./manage.sh status

# Testa la connettività
./manage.sh test

# Visualizza i log
./manage.sh logs [servizio]
```

## URL di Accesso

Dopo l'installazione, i servizi saranno disponibili su:

| Servizio | URL | Descrizione |
|----------|-----|-------------|
| 🌐 Traefik | http://traefik.home | Reverse proxy dashboard |
| 🐳 Portainer | http://portainer.home | Gestione container |
| 🏠 Heimdall | http://heimdall.home | Dashboard principale |
| ⏱️ Uptime Kuma | http://uptime-kuma.home | Monitoraggio uptime |
| 🛡️ Pi-hole | http://pihole.home | DNS e ad-blocking |
| 🔐 Vaultwarden | http://vault.home | Password manager |
| 🎯 Homer | http://homer.home | Dashboard personalizzato |
| 📸 Immich | http://immich.home | Gestione foto |
| 🔧 Nginx PM | http://nginx.home | Nginx proxy manager |

## Risoluzione Problemi

### File .env già esistente
Il wizard rileva se esiste già un file `.env` e chiede se vuoi riconfigurare.

### Docker non installato
Lo script rileva automaticamente se Docker non è installato e offre l'installazione automatica.

### Configurazione manuale
Se preferisci configurare manualmente:

```bash
cp .env.example .env
nano .env
# Modifica le variabili necessarie
./manage.sh start
```

### Reset configurazione
Per ricominciare da capo:

```bash
rm .env
./manage.sh setup
```

## Backup e Ripristino

```bash
# Crea backup
./manage.sh backup

# I backup vengono salvati in ./backups/
```

## Aggiornamenti

```bash
# Aggiorna tutti i servizi
./manage.sh update
```

---

Per supporto e documentazione completa, consulta il [README.md](./README.md) principale.
