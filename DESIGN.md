# BoardMate design rules (2.0)

Mockups: design-2.0/ (1-welcome, 2-home, 3-map, 4-house, 5-room, 6-chat, 7-landlord, 8-roomform). Match them closely.

## Colors
- Background: #F3F5F4 · Cards: #FFFFFF
- Ink (main text + main buttons + tab bar): #0F1D20
- Gray text: #5B6664 · Borders/dividers: #DCE2E0 · Segment fill: #E3E8E6
- Lagoon (OPEN rooms, links, success): #0B6E5F · Lagoon dark: #08564A · Lagoon light: #DDEFEA
- Orange (tiny highlights only, never text on white): #E8692E · Warning icon: #B4501E
- Taken rooms: diagonal gray stripes (#D5DCD9 / #EEF1F0)
- Star: #F5A524

## Type
- Headings: Bricolage Grotesque, weight 800, tight letter-spacing (big titles 30–40px)
- Everything else: Inter (15–16px body, 12–13px small)

## Shapes
- Cards: radius 24–28, white, soft shadow
- Buttons: pill (fully rounded), height 52–56. Main = ink. Secondary = white with border.
- Chips/tags: pill, height 30–36
- Tab bar: floating dark ink pill, 20px from the sides, 28px from the bottom; active tab = white pill with icon + label
- Room details open as bottom sheets with a grab handle

## Signature parts (reuse everywhere)
- RoomMap: house drawn as rows by floor (GF, 2F, 3F). Tiles: open = lagoon with price, taken = gray stripes, shared spaces = dashed outline. Selected tile = orange ring.
- RoomDots: small squares, one per room (lagoon = open, gray = taken) + "2 of 5 rooms open"
- WalkPill: "6 min walk to PSU" (white pill on photos)
- FreshnessBadge: green dot + "Rooms checked 2d ago"
- CostCard: dark ink card listing rent + electricity + water + Wi-Fi = "About ₱X /mo" + move-in terms
- PricePin (map): white pill "₱3,500" + lagoon count bubble; selected = ink; full = gray "Full"

## Rules
- Touch targets at least 44px. Text contrast at least 4.5:1.
- Icons: Cupertino/line icons, no emoji.
- Always show loading, empty and error states in this style.
- Words: "landlord" = owner, "tenant"/"student" = renter. Rooms are "open" or "taken".
