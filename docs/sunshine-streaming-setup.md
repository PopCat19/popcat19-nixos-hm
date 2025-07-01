# Sunshine + Moonlight Streaming Setup Guide

## Overview

This guide covers the complete setup of Sunshine (game streaming server) with Moonlight (game streaming client) on your NixOS system with Hyprland.

## System Configuration

### Sunshine Server (NixOS Host)

Your system is configured with:
- **Host**: popcat19-nixos0 (192.168.50.172)
- **GPU**: AMD Radeon RX 7800 XT with hardware encoding (VAAPI)
- **Display**: Dual monitor setup (MSI MAG271VCR + Dell S2415H)
- **Desktop**: Hyprland with proper screen sharing support

### Available Encoders

✅ **H.264 (AVC)** - Best compatibility  
✅ **HEVC (H.265)** - Better compression  
✅ **AV1** - Latest codec with excellent compression

## Network Configuration

### Firewall Ports (Auto-configured)

- **TCP 47984** - HTTPS Web UI
- **TCP 47989** - HTTP Web UI  
- **TCP 47990** - HTTPS Web UI (primary)
- **TCP 48010** - RTSP streaming
- **UDP 47998-48000** - Game streaming data
- **UDP 8000-8010** - Additional streaming ports

## Setup Instructions

### 1. Access Sunshine Web Interface

Open your web browser and navigate to:
```
https://localhost:47990
```

**Note**: You may see a security warning - this is normal for self-signed certificates.

### 2. Initial Configuration

1. **Create Admin Account**
   - Set username and password on first visit
   - Save credentials securely

2. **Configure Applications**
   - Go to "Applications" tab
   - Add applications you want to stream:
     - Desktop (full desktop streaming)
     - Steam
     - Individual games
     - Other applications

3. **Streaming Settings** (Optional tweaks)
   - **Resolution**: Match your primary monitor (1920x1080)
   - **Bitrate**: Start with 20,000 Kbps for local network
   - **FPS**: 60 FPS for smooth gaming
   - **Encoder**: H.264 for best compatibility, HEVC for quality

### 3. Client Connection

#### Local Testing (Same Computer)
```bash
moonlight-qt
```
- Should auto-detect "popcat19-nixos0"
- Use for testing and configuration

#### Android Connection
1. **Install Moonlight**
   - F-Droid: `org.moonlight_stream.moonlight`
   - Google Play Store: "Moonlight Game Streaming"

2. **Add Host Manually**
   - Open Moonlight app
   - Tap "Add Host Manually"
   - Enter: `192.168.50.172:47989`

3. **Pairing Process**
   - Generate PIN in Sunshine web interface
   - Enter PIN in Moonlight when prompted
   - Complete pairing

## Service Management

### Control Sunshine Service
```bash
# Check status
systemctl --user status sunshine

# Start/stop service
systemctl --user start sunshine
systemctl --user stop sunshine

# View logs
journalctl --user -u sunshine -f
```

### Auto-Start Configuration
Sunshine is configured to start automatically when you log into Hyprland.

## Troubleshooting

### Common Issues

**1. Moonlight can't find host**
- Verify both devices on same network
- Try manual host addition: `192.168.50.172:47989`
- Check firewall settings

**2. Poor streaming quality**
- Lower bitrate in Sunshine settings
- Switch to H.264 encoder for compatibility
- Check network bandwidth

**3. Controller not working**
- Controllers should work through Sunshine's virtual input
- USB controllers may need to be connected to client device

**4. Audio issues**
- Ensure PipeWire is running: `systemctl --user status pipewire`
- Check audio output in Sunshine web interface

### Network Diagnostics
```bash
# Check if Sunshine ports are listening
sudo ss -tulpn | grep -E "(47984|47989|47990|48010)"

# Test web interface connectivity
curl -k https://localhost:47990

# Check network connectivity from Android
# ping 192.168.50.172
```

### Log Analysis
```bash
# Real-time Sunshine logs
journalctl --user -u sunshine -f

# Recent errors only
journalctl --user -u sunshine --since "5 minutes ago" -p err
```

## Performance Optimization

### For Local Network (WiFi/Ethernet)
- **Bitrate**: 15,000-30,000 Kbps
- **Resolution**: Native (1920x1080)
- **FPS**: 60
- **Encoder**: HEVC for quality, H.264 for compatibility

### For Remote Streaming
- **Bitrate**: 5,000-10,000 Kbps
- **Resolution**: 1080p or lower
- **FPS**: 30-60 depending on bandwidth
- **Encoder**: H.264 for best compatibility

## Security Considerations

1. **Local Network Only**: Sunshine is configured for local network use
2. **Web Interface**: Accessible only from localhost by default
3. **Pairing**: Required for each new client device
4. **Firewall**: Ports are only open for local network traffic

## Advanced Configuration

### Custom Applications
Add custom applications in Sunshine web interface:
```
Name: Steam Big Picture
Command: steam -gamepadui
Working Directory: /home/popcat19
```

### Monitor Selection
For multi-monitor setups, you can configure which monitor to stream in the Sunshine web interface under "Video" settings.

### Hardware Encoding Settings
Your AMD RX 7800 XT supports:
- **Quality**: Use HEVC for best quality/size ratio
- **Performance**: Use H.264 for lowest latency
- **Efficiency**: Use AV1 for best compression (if client supports)

## File Locations

- **Configuration**: `~/.config/sunshine/`
- **Logs**: `journalctl --user -u sunshine`
- **Web Interface**: https://localhost:47990
- **Service File**: `/etc/systemd/user/sunshine.service`

## Support Resources

- **NixOS Sunshine Wiki**: https://nixos.wiki/wiki/Sunshine
- **Sunshine Documentation**: https://docs.lizardbyte.dev/projects/sunshine/
- **Moonlight Documentation**: https://moonlight-stream.org/
- **This Configuration**: `/home/popcat19/nixos-config/`

---

## Quick Start Checklist

- [ ] Access https://localhost:47990
- [ ] Create admin account
- [ ] Add "Desktop" application
- [ ] Test with local Moonlight client
- [ ] Generate pairing PIN
- [ ] Connect Android device
- [ ] Test streaming quality
- [ ] Adjust settings as needed

Your Sunshine + Moonlight setup is now ready for high-quality game streaming! 🎮