# 🏪 XLP Store Robbery - Store Robbery System

Complete 24/7 store robbery system for FiveM servers using Qbox Framework.

---

## 🎥 Showcase

### Video Demonstrations

**Cash Register #1**  
[![First Register](https://img.shields.io/badge/▶️-Watch_Video-red?style=for-the-badge)](https://medal.tv/pt/games/gta-v/clips/lxh8EYUWvshEuJ9RA?invite=cr-MSxpWG0sMzE5OTI1OTU1&v=21)

**Cash Register #2**  
[![Second Register](https://img.shields.io/badge/▶️-Watch_Video-red?style=for-the-badge)](https://medal.tv/pt/games/screen-capture/clips/lxhozEBf7IZdGB64y?invite=cr-MSw3VkksMzE5OTI1OTU1&v=22)

**Computer Hack 💻**  
[![Hack Computer](https://img.shields.io/badge/▶️-Watch_Video-blue?style=for-the-badge)](https://medal.tv/pt/games/screen-capture/clips/lxhcxGLiFFKepE322?invite=cr-MSwxNDQsMzE5OTI1OTU1&v=30)

**Safe Robbery 🔐**  
[![Safe Robbery](https://img.shields.io/badge/▶️-Watch_Video-yellow?style=for-the-badge)](https://medal.tv/pt/games/screen-capture/clips/lxhfuuqSTKcNHlDow?invite=cr-MSxrT0YsMzE5OTI1OTU1&v=30)

---

## 📋 Main Features

### 🎯 Three Types of Robberies
1. **Cash Registers** 💵
   - Lockpick minigame with skillcheck
   - Reward: Dirty money ($500-$1500)
   - Robbery time: 15 seconds
   - Animation: Taking money from register

2. **Safes** 🔐
   - More difficult lockpick minigame
   - Reward: Dirty money ($2000-$5000)
   - Robbery time: 25 seconds
   - Animation: Breaking into safe

3. **Computers** 💻
   - Hacking minigame
   - Reward: Clean money deposited to bank account ($1000-$3000)
   - 50% chance of successful transfer
   - Hack time: 20 seconds
   - Animation: Typing on laptop

### 🛡️ Security System
- **Police Required**: Requires minimum number of police online (configurable)
- **Automatic Alert**: On-duty police receive notification with location
- **Zone Cooldown**: Each register/safe/computer has independent cooldown
- **Reset Time**: 30 minutes by default (configurable)
- **Multi-Player Sync**: State synchronized between all clients

### 🎮 Interaction System
- **ox_target**: Precise interaction zones for each object
- **Visual Feedback**: Different icons and labels for each robbery type
- **State Validation**: Checks if already robbed or if another player is robbing

### 🔧 Required Items
- **Lockpick**: For cash registers and safes
- **Black USB**: To hack computers
- **Break Chance**: 40% chance to break item on failure (configurable)

### 📊 Logging System
- **Console Logs**: Colored prints with detailed information
- **Discord Logs**: Webhooks with elegant embeds
  - 🏪 Store Robbery (green)
  - 🔐 Safe Robbery (gold)
  - 💻 Successful Hack (blue)
  - ⚠️ Failed Hack (orange)
- **Information Included**: Player name, Citizen ID, store, reward, zone ID

### 🌍 Localization System
- **Multi-Language**: Support for Portuguese and English
- **Complete Translation**: All notifications in JSON
- **Simple Configuration**: Set language via convar in server.cfg

### 🏬 14 Pre-Configured Stores
All main 24/7 stores in Los Santos:
- Grove Street, Mirror Park, Clinton Avenue
- Palomino Freeway, Great Ocean Highway
- Grape Seed, Route 68, Senora Freeway
- And more...

Each store has:
- 2 Cash Registers
- 1 Safe
- 1 Computer

---

## 🔧 Installation

### 1. Requirements
- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)

### 2. Installation
1. Place the `xlp_storerob` folder in `resources/[testes]/`
2. Add to `server.cfg`:
```cfg
ensure xlp_storerob
setr ox:locale 'en'  # or 'pt' for Portuguese
```

### 3. Item Configuration
Add to `ox_inventory/data/items.lua`:
```lua
['lockpick'] = {
    label = 'Lockpick',
    weight = 160,
},
['usb_black'] = {
    label = 'Black USB',
    weight = 100,
},
['black_money'] = {
    label = 'Dirty Money',
    weight = 0,
},
```

### 4. Discord Logs (Optional)
1. Create a webhook in your Discord server
2. Open `config.lua`
3. Configure:
```lua
Config.EnableDiscordLogs = true
Config.DiscordWebhook = 'WEBHOOK_URL'
```

---

## ⚙️ Configuration

### config.lua - Main Options

#### Items
```lua
Config.RequiredItem = 'lockpick'        -- Item to rob
Config.HackRequiredItem = 'usb_black'   -- Item to hack
Config.RewardItem = 'black_money'       -- Reward item
```

#### Difficulty
```lua
Config.MinPolice = 0                    -- Required police
Config.LockpickBreakChance = 40         -- % break lockpick
Config.UsbBreakChance = 40              -- % break USB
Config.HackSuccessChance = 50           -- % hack success
```

#### Times
```lua
Config.ResetTime = 30                   -- Minutes to reset
Config.RobberyTime = 15000              -- ms to rob register
Config.SafeRobberyTime = 25000          -- ms to rob safe
Config.HackTime = 20000                 -- ms to hack
```

#### Rewards
```lua
Config.MinReward = 500                  -- Minimum register
Config.MaxReward = 1500                 -- Maximum register
Config.SafeMinReward = 2000             -- Minimum safe
Config.SafeMaxReward = 5000             -- Maximum safe
Config.HackMinReward = 1000             -- Minimum hack
Config.HackMaxReward = 3000             -- Maximum hack
```

#### Minigames
```lua
Config.Difficulty = {'easy', 'easy', 'medium'}
Config.SafeDifficulty = {'easy', 'easy', 'easy'}
Config.HackDifficulty = {'easy', 'easy', 'easy'}
```

#### Discord
```lua
Config.EnableDiscordLogs = true
Config.DiscordWebhook = 'URL_HERE'
Config.DiscordBotName = 'Store Robbery Logs'
Config.DiscordColor = 3447003
```

---

## 🎯 How It Works

### For Players

1. **Preparation**
   - Get a lockpick or black USB
   - Check if there are enough police online

2. **Execute the Robbery**
   - Go to a 24/7 store
   - Approach the register/safe/computer
   - See the ox_target icon appear
   - Click to start
   - Complete the minigame (skillcheck or hack)
   - Wait for the progress bar
   - Receive the reward!

3. **Risks**
   - Police are automatically alerted
   - Item may break if you fail (40% chance)
   - Other players can see you're robbing
   - Zone is blocked for 30 minutes after success

### For Police

- Receive automatic alert when someone robs
- Notification shows which store is being robbed
- Have time to respond during progress
- Can interrupt the robbery if you arrive in time

---

## 🔍 Debug / Troubleshooting

### Debug Logs
The script has detailed logs in F8 console:
```
[Store Robbery] Creating zone X for register Y of store: Name
[Store Robbery] Attempting to rob zone X
[Store Robbery] Zone X blocked - robbing: false, robbedStores[X]: true
[Store Robbery] Marked robbedStores[X] = true
```

### Common Issues

**Can't rob any store**
- Check if you have the required item (lockpick/USB)
- Confirm there are enough police online
- Check F8 console for error messages

**Second register doesn't work**
- This is normal! Each zone has independent cooldown
- Wait 30 minutes or restart the resource

**Translations don't appear in EN**
- Check if you added `setr ox:locale 'en'` in server.cfg
- Restart the server completely

**Discord logs don't work**
- Confirm the webhook is correct
- Check if `Config.EnableDiscordLogs = true`
- Test the webhook directly

---

## 📝 File Structure

```
xlp_storerob/
├── client.lua          # Client-side logic
├── server.lua          # Server-side logic and callbacks
├── config.lua          # All configurations
├── fxmanifest.lua      # Resource manifest
├── read.me             # This file
└── locales/
    ├── pt.json         # Portuguese translations
    └── en.json         # English translations
```

---

## 🆕 Changelog

### v1.0.0 - Initial Release
- ✅ Cash register robbery system
- ✅ Safe robbery system
- ✅ Computer hacking system
- ✅ ox_lib integration (notify, skillcheck, progressCircle)
- ✅ Police alert system
- ✅ Independent cooldown per zone
- ✅ Multi-player synchronization
- ✅ Discord logs with embeds
- ✅ Localization system (PT/EN)
- ✅ 14 pre-configured stores
- ✅ Complete debug logs

---

## 📞 Support

To report bugs or suggest improvements:
- Open a ticket on Discord
- Create an issue on GitHub

---

## 📜 License

This script is provided "as is" for use on FiveM servers.
Modifications are permitted for personal use.

---

## 👨‍💻 Credits

**Developed by:** XLP Development  
**Framework:** Qbox  
**Libraries:** ox_lib, ox_inventory, ox_target

---

**Version:** 1.0.0  
**Last Update:** November 2025
