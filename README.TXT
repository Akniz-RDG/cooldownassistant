# 🧠 Cooldown Assistant (WoW Addon)

**Cooldown Assistant** is an addon for *World of Warcraft* (Classic/Vanilla/SoM/HC) that allows you to set custom visual alerts based on:

- **Enemy's remaining health percentage**
- **Elapsed time since combat started**

These alerts appear on-screen to help you optimize the use of your offensive and defensive cooldowns.

---

## ⚙️ Features

- 🔔 **Health-based alerts**: trigger messages when a target reaches a specific health % (e.g., 35%).
- ⏱️ **Time-based alerts**: trigger messages after X seconds since combat begins.
- ✅ Supports multiple bosses (alerts are saved per boss name).
- 💾 Alerts are **persisted between sessions**.
- 🧹 One-click button to delete all alerts for a boss.
- 📋 In-game UI for managing alerts (accessible with `/cooldown`).

---

## 🧪 How to Use

1. Type `/cooldown` in chat to open the addon interface.
2. Enter the **boss name** (can be any target's name).
3. Add an alert:
   - For health: enter a % and a message.
   - For time: enter a number of **seconds** and a message.
4. Click **"Add % Alert"** or **"Add Time Alert"**.
5. When you fight that target, alerts will trigger automatically.

---

## 📦 Installation

1. Copy the `CooldownAssistant` folder into:
2. Enable the addon from the **"AddOns"** button on the character select screen.
3. Use `/reload` if needed after changes.

---

## 🛠️ Files Included

- `CooldownAssistant.lua` – Addon logic
- `CooldownAssistant.xml` – UI layout
- `CooldownAssistant.toc` – Metadata and load order

---

## 🧠 Examples

- `"20% - Use Execute"`  
- `"60s - Use Death Wish"`  
- `"35% - Pop Defensive"`

---

## 🙋 FAQ

**Can I use it on normal mobs or only bosses?**  
Yes, it works on any enemy by name.

**Can I configure alerts for multiple targets?**  
Yes, alerts are saved per boss name and loaded when typed in.

**Will my alerts be lost when I log out?**  
No, alerts are saved via `SavedVariables` and reloaded automatically.

---

## 👨‍💻 Author

Developed by Akniz-RDG
Inspired by the need to manage cooldowns with precision in WoW Classic.

---
