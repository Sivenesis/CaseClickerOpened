# Case Clicker Opened

**Version:** 1.0.0  
**Platform:** Windows (PC) via [Solar2D](https://solar2d.com)

A native PC port and community restoration of the classic mobile game **Case Clicker** (v2.1.80). This project reconstructs the original game logic and assets to run seamlessly on modern Windows desktop systems without mobile dependencies or dead servers.

---

## How to Run

### Standalone (Recommended)
1. Download or clone this repository.
2. Launch **`CaseClickerOpened.exe`** (or open the folder in **Solar2D Simulator**).
3. The game starts in 1280x720 windowed mode with full mouse support.

### Running from Source
1. Install [Solar2D](https://solar2d.com).
2. Open Solar2D Simulator, press `Ctrl+O`, and select `main.lua` in the repository root.

---

## Changes & Implementation Overview

### 1. Preserved from the Original Game
- **Authentic Mechanics**: Complete case opening animations, wear conditions (Factory New to Battle-Scarred), StatTrak, Souvenirs, and drop probabilities.
- **Inventory & Skins**: Over 900 weapon skins, knives, gloves, and stickers with inspect, filtering, and Trade-Up contracts.
- **Casino Mini-Games**: Coinflip, Crash, Roulette, Minesweeper, Jackpot, Upgrader, and Scratch Cards.
- **Original Audio & Assets**: Original sound effects, UI themes, and textures intact.

### 2. PC Windowing & Modernization
- **Native Desktop Integration**: Custom border, title set to "Case Clicker Opened", original icon, stripped simulator menu bar, and mouse wheel table scrolling.
- **Developer / Debug Console**: Press `F1`, `F12`, or `~` to toggle debug tools, cash grants, rank controls, case generators, and cooldown overrides.

### 3. Offline NetHub & Bot Emulation
All defunct online services from 2016 have been replaced with a self-contained offline community simulation:
- **12 Trading Bots**: Trade items with simulated community traders (`CS_Trader_99`, `Karambit_God`, etc.) featuring valuation logic and real-time interactive trade chat.
- **CS Pro Match Betting**: Continuous schedule of rotating pro matches (Astralis, NaVi, Fnatic, Cloud9, Liquid, etc.) with dynamic odds, timers, and skin payouts.
- **Community Marketplace**: Browse revolving bot skin listings and post personal offers for bots to purchase.
- **Daily Raffles**: Convert points and unwanted items into daily lottery tickets.
- **Built-in Offline Promo Codes**: Redeem codes such as `COMMUNITY`, `FREEKNIFE`, `FREEGLOVES`, `CASES50`, `STATTRAK`, and `GLOBALELITE`.

### 4. Paid Bonuses & Cooldown Customization
- **No Ads / No In-App Purchases**: All microtransactions and ad SDKs are completely removed.
- **Ad-Style Free Claims**: Repeatable bonuses (Knives, Gloves, Cases, Cash) operate on a cooldown timer (default: **60 minutes**).
- **Customizable Cooldown**:
  - **In-Game**: Adjust presets (`0m Instant`, `15m`, `30m`, `60m`, `120m`) inside the Developer Console (`F1`).
  - **Config File**: Edit `"cooldown_minutes"` in `bonuses_config.json` next to the executable.

---

## AI Disclosure

This project was decompiled, reconstructed, ported to PC, modernized, and equipped with offline simulation systems with the assistance of **DeepMind Antigravity / Agentic AI**.

---

## Copyright & Intellectual Property Notice

- **Valve Corporation**: Counter-Strike, CS:GO, CS2, weapon designations, skin textures, and associated visual designs are registered trademarks and copyrights of **Valve Corporation**.
- **Hawk Games**: The original *Case Clicker* mobile application and game design were created by Bartosz Boryń / **Hawk Games**.
- This project is a non-commercial, non-profit community preservation and educational endeavor.

---

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
