# � HOMELAB MIGRATION GUIDE

## ✅ **Nuova Architettura Modulare**

L'homelab è stato completamente riorganizzato con un'architettura modulare per tipologia di servizio, sostituendo la struttura monolitica precedente.

## 📁 **Nuova Struttura Organizzata**

### ✅ Cartelle Aggiunte:
- ✅ `services/infrastructure/` - Traefik, Portainer, Watchtower
- ✅ `services/monitoring/` - Heimdall, Uptime Kuma, Homer  
- ✅ `services/networking/` - Pi-hole, Nginx PM, Cloudflare DDNS
- ✅ `services/security/` - Vaultwarden password manager
- ✅ `services/media/` - Stack Immich completo

### ❌ Cartelle Rimosse:
- ❌ `base-services/` - Sostituita dalla struttura modulare services/
- ❌ `dyndns/` - Cloudflare DDNS ora in services/networking/
- ❌ `nginx/` - Nginx Proxy Manager ora in services/networking/  
- ❌ `immich/` - Stack Immich ora in services/media/

## 🔄 **Cosa è Cambiato**

### ✅ **Vantaggi della Nuova Architettura Modulare**
- **Organizzazione per tipologia**: Ogni categoria di servizio ha la sua cartella
- **Configurazioni separate**: File di config dedicati per ogni servizio
- **Modularità**: Facile attivare/disattivare categorie di servizi
- **Manutenibilità**: Codice più pulito e facile da gestire
- **Scalabilità**: Semplice aggiungere nuovi servizi per categoria
- **Orchestrazione**: Un master compose.yml che coordina tutto

### 🆕 **Nuova Struttura di Comando**
```bash
# Avvia tutto l'homelab
./manage.sh start

# Avvia servizi per categoria  
docker compose --file services/infrastructure/compose.yml up -d
docker compose --file services/monitoring/compose.yml up -d

# Mostra stato completo
./manage.sh status

# Gestione centralizzata
cd /home/matteo/homelab
docker compose up -d  # Avvia tutto
docker compose down   # Ferma tutto
```
```

### 🌐 **Nuove URL di Accesso**
- **Immich**: http://immich.local (tramite Traefik)
- **Nginx PM**: http://nginx.local (tramite Traefik)
- **Tutti gli altri**: URL invariate

### 🔧 **Configurazione Environment**
Tutte le configurazioni ora in `.env`:
```bash
# Copia il template
cp .env.example .env

# Configura le tue variabili
nano .env
```

## 🚨 **Importante**

1. **Backup**: Assicurati di aver fatto backup dei dati prima di rimuovere le directory legacy
2. **Test**: Testa la nuova configurazione prima di rimuovere le directory vecchie
3. **Volumi**: I volumi Docker mantengono i dati, ma verifica che tutto sia montato correttamente

## 📞 **Supporto**

Se hai problemi con la migrazione:
1. Controlla `./manage.sh status`
2. Verifica i log con `./manage.sh logs service_name`
3. Consulta `TROUBLESHOOTING.md`
