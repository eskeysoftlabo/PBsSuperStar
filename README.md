# PB’s SuperStar

Puts your character's equipment, detailed statistics, Champion Points and skills on one screen,
in the gamepad UI of **The Elder Scrolls Online** on console (PS5 / Xbox Series X|S).

- **Author:** PinkBanther
- **Version:** 0.2.2 (API 101050)
- **Libraries:** none

Open it from **ステータス超詳細** in the gamepad main menu, between **Character** and **Skills**.

> **The in-game text is Japanese.** The screen, the menu entry and every label are written in
> Japanese only; there is no English locale yet.

## Why this exists

The game already knows all of this — the quality of the ring you are wearing, how many points
sit unspent in Craft, what the second bar's passives are, what your Critical rating actually is.
It just never shows more than a slice of it at once, and on console there is no add-on window
you can leave open next to the one you are reading. Answering "is this set piece better than
that one" means walking between three menus and remembering numbers on the way.

This is those three menus on one screen, kept live while you look at it.

## What it shows

- **Header** — name, race, class, level, Champion Points, title.
- **Equipment** — armour, accessories, front and back bar weapons, poisons, costume. Select a
  piece and it shows quality, required level, trait, enchantment, durability, weapon power or
  armour value, charges, and its set with each bonus tier.
- **Statistics** — the three base attributes, attribute points, every detailed statistic
  category the API exposes, and the effects currently running on you (Mundus, food, and the
  rest).
- **Champion Points** — twelve slots, spent and unspent points per constellation, and per star
  the points invested, the cap and the description, distinguishing slotted, unslotted, passive
  and inactive.
- **Skills** — six slots on each bar plus whatever special bar is in use, your active,
  ultimate and passive abilities, line rank, skill rank and unspent points. Scribing skills are
  listed too.

The layout follows the original SuperStar: one translucent screen, character and the three
attribute bars top left, both skill bars and the combat numbers top centre, the fourteen
equipment slots bottom left, and on the right the constellations, slotted CP, active effects
and known skills. Traits and enchantments sit under the item name, set counts at the right
edge. Poisons and the costume are on the equipment list's second page.

## Controls

| action | PS / Xbox |
| --- | --- |
| choose an area, then an entry | D-pad left/right, up/down |
| page through the selected area | L1 / R1 — LB / RB |
| scroll the description at the bottom | L2 / R2 — LT / RT |
| refresh now | the 再取得 button on the screen |
| show unearned CP and skills too | the 取得済み / 全項目 button |
| back to the menu | ○ / B (follows your back-button setting) |

D-pad left and right move between the four areas — equipment, detailed statistics, CP and
skills. Everything but equipment lists its entries bottom right, so the attributes, equipment
and CP summaries stay on screen while you read them. Long lists and descriptions scroll in
place, and a name that had to be truncated is spelled out in the detail pane below.

CP colours follow the constellation; item name colours follow quality. **クリ値 in the combat
numbers is the Critical rating, not a percentage.**

While the screen is open it re-reads everything every 1.5 seconds, and stops when you close it.
The numbers reflect the bar you have drawn and the buffs you have now. It does not estimate the
back bar or simulate hypothetical builds, and CP shows confirmed investment only. "Passive"
describes the kind of star, not whether its condition is currently met — read the effect text
for that. A skill's earned state and its line's active state are shown separately.

## Setup

On PC, put `PBsSuperStar.addon`, `Data.lua`, `UI.lua` and `PBsSuperStar.lua` in
`AddOns/PBsSuperStar/`. The manifest is the same `.addon` format as the other PB add-ons; do
not ship the old `PBsSuperStar.txt` alongside it, and keep it out of the zip. `/pbss` opens the
screen on PC, for testing.

**Creating the files locally does not install anything on a console.** Console distribution
goes through Bethesda's developer Uploader — build a candidate with `python3 tools/package.py`,
then follow the console development environment and the Uploader's instructions. Nothing here
has been uploaded or published. See the
[official console Uploader notes](https://help.elderscrollsonline.com/app/answers/detail/a_id/69621/).

## 0.2.2: less work at load time

The screen is no longer built when the add-on loads. It is built the first time you open it, in
small pieces at 32 ms intervals: about a second of preparation on the first open, and the
already-built screen every time after. You can back out during preparation — closing pauses the
build, reopening resumes it.

The error in the reported screenshot is the per-frame add-on CPU limit (1000 ms) being reached.
Its stack is inside the game's own UI, so this add-on cannot be shown to be the sole cause.
This change removes this add-on's build-everything-at-load; **whether it clears the error on a
console has not been confirmed.**

## Files

| file | what is in it |
| --- | --- |
| `Data.lua` | reads the API |
| `UI.lua` | draws the screen and handles input |
| `PBsSuperStar.lua` | initialisation, the scene and the menu entry |
| `PBsSuperStar.addon` | the manifest |
| `tests/run.lua` | the offline test harness |
| `tools/package.py` | builds the upload candidate zip |
| `SuperStar/` | the original SuperStar, kept for reference only |

`SuperStar/` is reference material. None of that add-on's code or bundled libraries is loaded
or distributed here.

## Tests

```sh
luac -p Data.lua UI.lua PBsSuperStar.lua
lua tests/run.lua
python3 tools/package.py
```

The suite checks Lua syntax and, against API mocks, the data reads, the input handling, that
the menu entry is never added twice, and that polling stops when the screen closes.

**In-game rendering, behaviour on a real PS5 or Xbox, and conformance to the official Uploader
are untested.** A local test is not a substitute for the game client.

## What is verified, and what is not

Checked against the [public API definition](https://github.com/esoui/esoui/blob/f76cf16c4e5be7b234d15dc7f676febffa64c5bb/ESOUIDocumentation.txt)
and the [gamepad menu implementation](https://github.com/esoui/esoui/blob/f76cf16c4e5be7b234d15dc7f676febffa64c5bb/esoui/ingame/mainmenu/gamepad/zo_mainmenu_gamepad.lua)
for API 101050, at commit `f76cf16c4e5be7b234d15dc7f676febffa64c5bb`. The menu entry uses
`ZO_MENU_ENTRIES`, a data structure of the public UI implementation, so it needs re-checking
whenever the game updates.

On-device checklist, still to be completed:

- exactly one menu entry after a fresh login, a reload, and a character switch
- open, close, move between the four areas, page the 14 equipment rows and the 5 detail rows,
  and scroll a long set description — all on the controller alone
- 720p, 1080p and 4K, and changed UI scale: nothing clipped, keybind strip intact, Japanese
  legible
- the screen follows changes to equipment, weapon swap, food and Mundus, and confirmed skill
  and CP spending
- no errors with unearned CP, empty slots, unearned skills, Scribing, subclassing, or a
  transform bar
- equipment, attributes, CP and skills match the game's own screens
- back returns to the menu, and nothing keeps polling or capturing input after it closes

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
