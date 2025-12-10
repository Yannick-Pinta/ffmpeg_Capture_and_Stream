# Claude Context - FFmpeg Capture and Stream

## Project Overview

This is a Windows-based video streaming solution that captures webcam and microphone input, encodes with NVIDIA NVENC (hardware acceleration), and streams via SRT protocol. MediaMTX is used as a relay server to enable multi-client redistribution.

## Repository

- **GitHub**: https://github.com/Yannick-Pinta/ffmpeg_Capture_and_Stream
- **Local path**: `C:\Claude\ffmpeg_ReStreamer`

## Architecture

```
Webcam + Mic → FFmpeg (NVENC) → SRT → MediaMTX → Multiple Clients
                                         ↓
                              SRT / RTSP / HLS / WebRTC
```

## Key Components

### FFmpeg
- **Source**: https://www.gyan.dev/ffmpeg/builds/
- **Location**: `ffmpeg/bin/ffmpeg.exe`
- **Version**: Full build with NVENC, SRT, libx264 support

### MediaMTX
- **Source**: https://github.com/bluenviron/mediamtx
- **Location**: `mediamtx/mediamtx.exe`
- **Config**: `mediamtx/mediamtx.yml`
- **Purpose**: Multi-client redistribution server

## Hardware Setup (Current)

- **Webcam**: Logitech BRIO
- **Microphone**: Microphone (Logitech BRIO) - using webcam's built-in mic
- **Audio output**: Headset Earphone (HyperX 7.1 Audio)
- **GPU**: NVIDIA with NVENC support (h264_nvenc, hevc_nvenc, av1_nvenc)
- **IP**: 192.168.1.159

## Configuration

All settings are centralized in `config.bat`:
- Device names (webcam, microphone)
- Network settings (IP, ports)
- Video encoding (encoder, bitrate, resolution, fps)
- Audio encoding (bitrate)

## Main Scripts

| Script | Purpose |
|--------|---------|
| `install.bat` | Downloads FFmpeg and MediaMTX |
| `config.bat` | Central configuration file |
| `start_mediamtx.bat` | Starts MediaMTX relay server |
| `stream_to_mediamtx.bat` | Main streaming script (AAC audio for SRT/HLS/RTSP) |
| `stream_webrtc.bat` | Transcodes AAC→Opus for WebRTC with audio |
| `stream_srt_server.bat` | Point-to-point SRT streaming |
| `receive_srt.bat` | SRT receiver (ffplay) |
| `list_devices.bat` | Lists DirectShow devices |
| `check_nvenc.bat` | Verifies NVENC GPU support |

## Ports Used

| Port | Protocol | Service |
|------|----------|---------|
| 8554 | TCP | RTSP |
| 8888 | TCP | HLS (HTTP) |
| 8889 | TCP/UDP | WebRTC |
| 8890 | UDP | SRT (MediaMTX) |
| 9000 | UDP | SRT (point-to-point) |

## Client Connection URLs

Replace `192.168.1.159` with the streamer's IP address.

### SRT (lowest latency ~100-200ms)
```
srt://192.168.1.159:8890?streamid=read:webcam
```

### RTSP
```
rtsp://192.168.1.159:8554/webcam
```

### HLS (browser, ~10-15s latency)
```
http://192.168.1.159:8888/webcam
```

### WebRTC with audio (requires stream_webrtc.bat)
```
http://192.168.1.159:8889/webcam_webrtc
```

## Known Issues & Solutions

### YUV422 not supported by NVENC
- **Problem**: Webcam outputs YUV422, NVENC requires YUV420
- **Solution**: Add `-pix_fmt yuv420p` to FFmpeg command

### SRT listener mode crashes without client
- **Problem**: FFmpeg SRT in listener mode crashes when no client connected
- **Solution**: Use caller mode with auto-reconnect loop, or use MediaMTX as relay

### MediaMTX "path not configured"
- **Problem**: MediaMTX rejects streams with undefined paths
- **Solution**: Use `paths: all:` in mediamtx.yml to accept any path

### SRT streamid format for MediaMTX
- **Publish**: `streamid=publish:webcam`
- **Read**: `streamid=read:webcam`

### WebRTC no audio with AAC
- **Problem**: WebRTC doesn't support AAC codec, only Opus
- **Solution**: Use `stream_webrtc.bat` to transcode AAC→Opus and publish to `webcam_webrtc` path
- **Note**: MediaMTX will show HLS errors for webcam_webrtc (Opus not supported by MPEG-TS HLS) - these are harmless

### HLS errors "MPEG-TS variant supports MPEG-4 Audio only"
- **Problem**: MediaMTX creates HLS muxer for all paths, but Opus is not supported
- **Cause**: `stream_webrtc.bat` publishes Opus audio to `webcam_webrtc` path
- **Impact**: None - WebRTC works fine, only HLS fails for that path (which is expected)
- **Solution**: Cannot disable HLS per-path in MediaMTX - ignore the errors

## FFmpeg Command Structure

```cmd
ffmpeg ^
    -rtbufsize 50M ^
    -f dshow -video_size 1280x720 -framerate 30 -i video="WEBCAM":audio="MICROPHONE" ^
    -pix_fmt yuv420p ^
    -c:v h264_nvenc -preset p4 -tune ll -b:v 4000k -g 60 ^
    -c:a aac -b:a 128k ^
    -f mpegts "srt://HOST:PORT?streamid=publish:STREAM&pkt_size=1316"
```

## Mobile Apps for Viewing

- **Android**: VLC, Haivision Play Pro, Larix Player
- **iOS**: VLC, Larix Player

## Development Notes

- Scripts use `call "%~dp0config.bat"` to load configuration
- All scripts include `chcp 65001 >nul` for UTF-8 support
- Streaming scripts loop automatically on disconnect
- `.gitignore` excludes `ffmpeg/` and `mediamtx/*.exe` (downloaded during install)

## Audio Codec Compatibility

| Protocol | AAC | Opus | Notes |
|----------|-----|------|-------|
| SRT (MPEG-TS) | ✓ | ✗ | MPEG-TS only supports AAC |
| RTSP | ✓ | ✓ | Both supported |
| HLS (MPEG-TS) | ✓ | ✗ | MPEG-TS only supports AAC |
| HLS (fMP4) | ✓ | ✓ | But breaks SRT compatibility |
| WebRTC | ✗ | ✓ | Web standard requires Opus |

**Current solution**: Two separate streams
- `webcam` (AAC) → SRT, RTSP, HLS
- `webcam_webrtc` (Opus) → WebRTC

## Future Improvements Ideas

- Add recording to local file option
- Add text overlay (drawtext filter)
- Add multiple camera support
- Add audio mixer for multiple sources
- Add web interface for control
- Add automatic bitrate adjustment based on network
- UDP multicast support
