# 🛡️ Web Log Intrusion Detector

![Linux](https://img.shields.io/badge/platform-linux-blue)
![Bash](https://img.shields.io/badge/language-bash-green)
![AWK](https://img.shields.io/badge/tool-awk-orange)

A lightweight security monitoring tool that analyzes web server logs to detect common web attacks and sends real-time alerts to Discord.

The project combines **AWK log analysis** with **Bash automation** to identify suspicious activity and notify administrators immediately.

---

# ✨ Features

* 🔍 **Real-time log analysis** using `awk`
* 🧠 **Detection of common web attacks**
* 🌍 **IP geolocation lookup** (country detection)
* 🔔 **Instant Discord alerts**
* ⚙️ **Automation via systemd service**
* 🚫 Optional **automatic IP blocking** via `iptables`

---

# 🚨 Detected Attack Types

The analyzer scans logs for patterns related to:

* SQL Injection
* Directory Traversal / LFI
* Command Injection / RCE
* WordPress Scanning
* CMS Enumeration
* SSRF (Server-Side Request Forgery)
* Brute Force login attempts

---

# ⚙️ Requirements

The following tools must be installed:

* `bash`
* `awk`
* `curl`
* `jq`

Example installation (Debian/Ubuntu):

```bash
sudo apt install curl jq
```

---

### Description

| File                          | Description                                       |
| ----------------------------- | ------------------------------------------------- |
| `log_analyzer.awk`            | Parses web logs and detects attack patterns       |
| `alert_handler.sh`            | Processes detected attacks and sends alerts       |
| `block_ip.sh`                 | Script that can automatically block malicious IPs |
| `web_attack_detector.service` | systemd service for continuous monitoring         |

---

# 🧠 How It Works

1. Web server logs are analyzed using an **AWK script**.
2. Suspicious patterns trigger an event.
3. The **Bash handler script** extracts the attacker IP.
4. The IP address is sent to a **geolocation API** to determine the country.
5. A formatted **alert message is sent to Discord** via webhook.

---

# 🚀 Usage

### Run manually

```bash
./alert_handler.sh
```

---

### Run automatically with systemd

Copy the service file:

```bash
sudo cp attack-monitor.service /etc/systemd/system/
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable the service:

```bash
sudo systemctl enable attack-monitor.service
```

Start the service:

```bash
sudo systemctl start attack-monitor.service
```

Check status:

```bash
sudo systemctl status attack-monitor.service
```