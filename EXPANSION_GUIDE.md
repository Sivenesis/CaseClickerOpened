# Case Clicker - Content Expansion & Modding Guide

This document explains the data-driven architecture of **Case Clicker** and provides step-by-step instructions for adding new weapons, skins, cases, gloves, stickers, and upgrades.

---

## Architecture Overview

All game items are defined declaratively in Lua tables inside the `data/` directory:

| Component | Primary File | Description |
| :--- | :--- | :--- |
| **Skins Registration** | `data/skins.lua` | Associates skin constants (`Skin.KEY`) with CSGOStash IDs (`stashId`). |
| **Skin Metadata** | `data/skindata.lua` | Detailed skin attributes (display name, rarity, 5 condition prices, StatTrak, Souvenir). |
| **Cases** | `data/cases.lua` | Case definitions, unlock upgrade requirements, open cost, drop chances, and skin list. |
| **Keys** | `data/keys.lua` | Key definitions and purchase prices. |
| **Gloves** | `data/gloves.lua` & `data/glovedata.lua` | Glove models, rarities, and prices. |
| **Stickers & Capsules** | `data/stickers.lua` & `data/capsules.lua` | Sticker definitions and capsule drop tables. |
| **Upgrades** | `data/upgrades.lua` | Clicker multiplier upgrades, case chance upgrades, and rank unlocks. |
| **Constants** | `constants.lua` | Enums for `Skin`, `Case`, `Key`, `Rarity`, `Quality`, and `KnifeGroup`. |

---

## 1. Adding a New Weapon Skin

Adding a skin requires three steps: registering the constant, defining its metadata, and adding the texture.

### Step 1: Register Constant in `constants.lua`
Open `constants.lua` and locate the `Skin = { ... }` table. Add a unique identifier:

```lua
Skin.AK47_revolution = 899,
```

### Step 2: Register Mapping in `data/skins.lua`
Open `data/skins.lua` and bind the skin to its Stash ID (you can use the real CSGOStash/CS2Stash ID or any unique integer):

```lua
[Skin.AK47_revolution] = {
    stashId = 1500,
    -- Optional: disable qualities that don't exist in CS (e.g. Factory New only)
    -- disabledQualities = { Quality.battlescarred }
},
```

### Step 3: Add Metadata to `data/skindata.lua`
Open `data/skindata.lua` and add the item record indexed by `stashId`:

```lua
[1500] = {
    id = 1500,
    name = "AK-47 | Revolution",
    rarity = Rarity.covert,             -- Rarity.milSpec, Rarity.restricted, Rarity.classified, Rarity.covert
    statTrakAvailable = true,
    souvenirAvailable = false,
    isKnife = false,
    prices = {
        normal = {
            [1] = 120.00,  -- Factory New
            [2] = 85.00,   -- Minimal Wear
            [3] = 45.00,   -- Field-Tested
            [4] = 30.00,   -- Well-Worn
            [5] = 20.00    -- Battle-Scarred
        },
        statTrak = {
            [1] = 280.00,
            [2] = 190.00,
            [3] = 110.00,
            [4] = 75.00,
            [5] = 50.00
        }
    }
},
```

### Step 4: Add Image Texture
Place the weapon render PNG into:
```
images/skins/1500.png
```
*Recommended dimensions: 512x384 (transparent PNG).*

---

## 2. Adding a New Case

### Step 1: Register Case and Key in `constants.lua`
In `constants.lua`:

```lua
Case.revolution = 27,
Key.revolution = 27,
```

### Step 2: Define Key in `data/keys.lua`

```lua
[Key.revolution] = {
    id = Key.revolution,
    name = "Revolution Case Key",
    image = "revolution.png",
    price = 2.49
},
```

### Step 3: Define Case in `data/cases.lua`

```lua
[Case.revolution] = {
    id = Case.revolution,
    keyId = Key.revolution,
    name = "Revolution Case",
    image = "revolution.png",
    unlockingUpgrade = "Revolution Cases", -- Must match upgrade name in data/upgrades.lua
    rarity = Rarity.covert,
    price = 3.50,
    chance = 15,                          -- Drop weight from clicking
    sellPrice = 1.75,
    skins = {
        Skin.M4A4_temukau,
        Skin.AK47_revolution,
        Skin.AWP_doodlelore,
        -- Mil-Spec, Restricted, Classified, and Covert skins...
    },
    gloves = Gloves.clutch               -- or knifes = KnifeGroup.revolutionCase
},
```

### Step 4: Add Case Texture
Place the case icon into:
```
images/cases/revolution.png
images/keys/revolution.png
```

---

## 3. Adding an Unlock Upgrade

To unlock your new case in the shop or drop rotation, define an upgrade in `data/upgrades.lua`:

```lua
["Revolution Cases"] = {
    id = "Revolution Cases",
    name = "Revolution Cases",
    category = "cases",
    image = "upgrades/revolution.png",
    cost = 100000,
    multiplier = 1,
    description = "Unlocks the Revolution Case in the shop and drop pool."
},
```

---

## 4. Validating Your Changes

Run the built-in validator tool to check for missing textures, broken references, or pricing errors:

```bash
python tools/expansion_validator.py
```

The script will report:
- Any skins missing from `skindata.lua`
- Missing PNG image files
- Broken case skin references
