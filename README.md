# FFmpeg SRT ReStreamer

Système de streaming vidéo en temps réel utilisant **FFmpeg**, **SRT** et **MediaMTX** sous Windows.

Capture une webcam et un microphone, encode avec NVENC (GPU NVIDIA) et redistribue le flux vers plusieurs clients simultanément via SRT, RTSP, HLS ou WebRTC.

## Fonctionnalités

- Capture webcam + microphone via DirectShow
- Encodage matériel H.264 avec NVIDIA NVENC (fallback CPU x264 disponible)
- Streaming SRT ultra-low latency (~100-200ms)
- Redistribution multi-clients via MediaMTX
- Support multi-protocoles : SRT, RTSP, RTMP, HLS, WebRTC
- Scripts .bat prêts à l'emploi et configurables

## Prérequis

- **Windows 10/11**
- **Carte graphique NVIDIA** avec support NVENC (GTX 600+ / RTX) - optionnel, fallback CPU disponible
- **Webcam** compatible DirectShow
- **Microphone** compatible DirectShow
- Connexion réseau local pour les tests multi-appareils

## Installation rapide

### 1. Cloner le dépôt

```cmd
git clone https://github.com/VOTRE_USERNAME/ffmpeg_ReStreamer.git
cd ffmpeg_ReStreamer
```

### 2. Lancer l'installation automatique

```cmd
install.bat
```

Ce script va :
- Télécharger FFmpeg (build complet de gyan.dev)
- Télécharger MediaMTX (serveur de redistribution)
- Configurer les fichiers nécessaires

### 3. Configurer vos périphériques

Lancez la détection des périphériques :

```cmd
list_devices.bat
```

Notez les noms exacts de votre webcam et microphone, puis éditez `config.bat` :

```bat
set WEBCAM_NAME=Votre Webcam
set MICRO_NAME=Votre Microphone
```

## Utilisation

### Mode simple (point-à-point)

**Terminal 1 - Récepteur :**
```cmd
receive_srt.bat
```

**Terminal 2 - Streamer :**
```cmd
stream_srt_server.bat
```

### Mode multi-clients (avec MediaMTX)

**Terminal 1 - Serveur MediaMTX :**
```cmd
start_mediamtx.bat
```

**Terminal 2 - Streamer :**
```cmd
stream_to_mediamtx.bat
```

**Clients (autant que vous voulez) :**

| Protocole | URL |
|-----------|-----|
| SRT | `srt://IP:8890?streamid=read:webcam` |
| RTSP | `rtsp://IP:8554/webcam` |
| HLS (navigateur) | `http://IP:8888/webcam` |
| WebRTC | `http://IP:8889/webcam` |

Remplacez `IP` par l'adresse de la machine streamer (ex: `192.168.1.159` ou `127.0.0.1` en local).

## Configuration

### Fichier `config.bat`

```bat
REM === PERIPHERIQUES ===
set WEBCAM_NAME=Logitech BRIO
set MICRO_NAME=Microphone (Logitech BRIO)

REM === RESEAU ===
set MY_IP=192.168.1.159
set SRT_PORT=9000
set MEDIAMTX_PORT=8890

REM === VIDEO ===
set VIDEO_ENCODER=h264_nvenc
set VIDEO_BITRATE=4000k
set VIDEO_RESOLUTION=1280x720
set VIDEO_FPS=30

REM === AUDIO ===
set AUDIO_BITRATE=128k
```

### Paramètres vidéo recommandés

| Usage | Résolution | Bitrate | FPS |
|-------|------------|---------|-----|
| Basse latence | 1280x720 | 3000k | 30 |
| Qualité standard | 1920x1080 | 6000k | 30 |
| Haute qualité | 1920x1080 | 8000k | 60 |

### Presets NVENC

| Preset | Qualité | Vitesse | Usage |
|--------|---------|---------|-------|
| p1 | Maximale | Lente | Enregistrement |
| p4 | Bonne | Moyenne | **Live (recommandé)** |
| p7 | Basse | Rapide | Très basse latence |

## Réception sur différents appareils

### PC Windows - VLC

```
srt://192.168.1.159:8890?streamid=read:webcam
```

ou RTSP :
```
rtsp://192.168.1.159:8554/webcam
```

### PC Windows - ffplay

```cmd
ffplay "srt://192.168.1.159:8890?streamid=read:webcam"
```

### Android - VLC

1. Ouvrir VLC → Menu → Flux réseau
2. Entrer : `rtsp://192.168.1.159:8554/webcam`

### Android - Haivision Play Pro

1. Ajouter source SRT
2. Mode: **Caller**
3. Address: `192.168.1.159`
4. Port: `8890`
5. Stream ID: `read:webcam`

### Navigateur web (HLS)

```
http://192.168.1.159:8888/webcam
```

Note : HLS a ~10-15 secondes de latence.

## Scripts disponibles

| Script | Description |
|--------|-------------|
| `install.bat` | Installation automatique de FFmpeg et MediaMTX |
| `list_devices.bat` | Liste les webcams et micros disponibles |
| `check_nvenc.bat` | Vérifie le support NVENC (GPU NVIDIA) |
| `stream_srt_server.bat` | Stream SRT point-à-point |
| `stream_to_mediamtx.bat` | Stream vers MediaMTX (multi-clients) |
| `start_mediamtx.bat` | Démarre le serveur MediaMTX |
| `receive_srt.bat` | Récepteur SRT (ffplay) |
| `stream_srt_x264.bat` | Stream avec encodage CPU (sans GPU) |

## Architecture

```
┌─────────────┐     SRT      ┌───────────┐     SRT/RTSP/HLS     ┌─────────────┐
│   Webcam    │──────────────│  MediaMTX │─────────────────────│   Client 1  │
│   + Micro   │   (publish)  │  Server   │                      └─────────────┘
└─────────────┘              │           │     SRT/RTSP/HLS     ┌─────────────┐
       │                     │           │─────────────────────│   Client 2  │
       │ FFmpeg              │           │                      └─────────────┘
       │ (NVENC)             │           │     SRT/RTSP/HLS     ┌─────────────┐
       ▼                     │           │─────────────────────│   Client N  │
┌─────────────┐              └───────────┘                      └─────────────┘
│  Encodage   │
│  H.264 AAC  │
└─────────────┘
```

## Dépannage

### "NVENC not available" ou "No capable devices found"

- Vérifiez que vous avez une carte NVIDIA compatible
- Mettez à jour vos drivers NVIDIA
- Utilisez `stream_srt_x264.bat` pour l'encodage CPU

### "Device not found" pour la webcam/micro

- Lancez `list_devices.bat` et copiez le nom **exact**
- Vérifiez qu'aucune autre application n'utilise la webcam

### Connexion SRT échoue

- Vérifiez que le récepteur/MediaMTX est lancé **avant** le streamer
- Vérifiez le pare-feu Windows (ports 8890, 8554, 8888)
- Vérifiez que les appareils sont sur le même réseau

### Buffer overflow / frames dropped

- Normal au démarrage, devrait se stabiliser
- Réduisez la résolution ou le bitrate si ça persiste

## Ports utilisés

| Port | Protocole | Usage |
|------|-----------|-------|
| 8554 | TCP | RTSP |
| 8888 | TCP | HLS (HTTP) |
| 8889 | TCP/UDP | WebRTC |
| 8890 | UDP | SRT (MediaMTX) |
| 9000 | UDP | SRT (point-à-point) |

## Licence

MIT License - Libre d'utilisation et de modification.

## Crédits

- [FFmpeg](https://ffmpeg.org/) - Encodage et streaming
- [MediaMTX](https://github.com/bluenviron/mediamtx) - Serveur de redistribution
- [SRT Protocol](https://github.com/Haivision/srt) - Protocole de streaming basse latence
- FFmpeg builds par [gyan.dev](https://www.gyan.dev/ffmpeg/builds/)
