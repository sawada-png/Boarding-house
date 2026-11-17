# BoardMate: boarding house app

> Updated from the Q&A with Claude (Nov 16, 2026)

## Words used in this note
- **Landlord / owner** = the person who lists the place (my old notes said "renter")
- **Tenant** = the person who rents the room
- (In English, "renter" usually means the tenant, so using "landlord" avoids confusion)

## One-line pitch
An app where students in my city can find boarding houses, see exactly which rooms are still available, and pay rent on time, and where landlords stop having to post in Facebook groups every day.

## The problem
- Boarding houses are mostly advertised in Facebook groups: posts get buried, photos are old, and you can't tell which rooms are still available
- Landlords have to post or comment every day just to say they have an available unit
- Students risk scams (paying a deposit for a room that doesn't exist)
- Landlords track who paid by hand / chat

## Who it's for (first)
- **Students** looking for a room near their school
- **Landlords** of boarding houses near schools in **my city**
- Later: other cities → whole PH

## Competitors (they exist)
- Dormy PH, Rentpad, Lookal, Carousell, Lamudi, plus many student capstone apps
- **My edge:**
  1. Room-by-room availability (Room 1 available, Room 2 taken), each with its own photos
  2. Rent reminders + in-app payment + payment history
  3. Reviews only from verified tenants (no review bombing)
  4. Focus on ONE city's students first, and be the best there

## Core features (MVP: build these first)
1. **Listing page**: property photos (hallway, look, vibe), price range ("est. ₱5k–10k/month"), location on map
2. **Room tabs**: each room shows photos (bed, CR, kitchen, what's included), shared vs private, available/taken
3. **Search**: near a school / workplace / location, with filters
4. **Student filters/tags**: distance to school, boys/girls only, curfew, visitors allowed, Wi-Fi, water/electric included or separate, study area, price
5. **Contact**: in-app chat + call button
6. **Reviews**:
   - Tenants rate the place + landlord (stars + comment)
   - Landlords rate tenants (pays on time? clean? respectful?)
   - Only people with a confirmed stay can review
   - Landlords can reply to a review

## Later features
- In-app rent payment (GCash, Maya) through a payment gateway (e.g. PayMongo / Xendit)
- Rent reminder notifications (e.g. started Nov 13 → reminder before Dec 13)
- "On-time payer" badge for tenants with good payment history
- Customer service / dispute system for unfair reviews
- Landlord dashboard: who paid, who's late, which rooms are available

## Keeping availability accurate
- Problem: if a room shows "available" but is already taken, students stop trusting the app
- Plan:
  - Weekly prompt to landlord: "Is Room 3 still available?" (one tap)
  - Listing auto-hidden if not confirmed in ~14 days
  - Tenants can report "room was already taken"
  - Repeated reports → warning → lower ranking in search (not instant bans early on; I need landlords)

## Trust & safety
- Landlord ID verification → "Verified" badge
- Warning in app: never pay a deposit before seeing the room
- Report button on listings
- Tenant ratings visible only to landlords, not public (Data Privacy Act / cyber libel risk)

## How it makes money (ideas, may change)
- Small commission on in-app rent payments
- Featured / boosted listings for landlords
- Optional landlord subscription for the dashboard
- Ads (small income with a student audience, so not the main plan)
- Make paying in the app **worth it** (receipts, reminders, on-time badge) instead of punishing people for paying cash, because punishment will push landlords back to Facebook

## Launch plan (my city)
1. Start in Puerto Princesa: PSU Tiniguiban, WPU PPC, Holy Trinity University (Rizal)
2. Visit landlords personally, help them list (and take photos if needed)
3. No fee for landlords at the start
4. Share in school FB groups / student orgs
5. Once that area works → next school → next city

## Open questions
- Payments need a registered business (DTI) + gateway approval: when do I do that?

## Decisions (Nov 17, 2026)
- **Type:** phone app (Android + iPhone)
- **Built with:** Flutter + Firebase, code written by Claude
- **Launch area:** Puerto Princesa City
  - Palawan State University (Tiniguiban)
  - Western Philippines University (PPC)
  - Holy Trinity University (Rizal)
- **Version 1 deadline:** 4 weeks
- **Goal:** 10 landlords + 50 students within 3 months of launch
- **Before building:** talk to 2–3 landlords and 2–3 students
- **Landlords:** same app, switch to "Landlord mode"
- **Sign up:** phone number (SMS code) or Google / Facebook login
- **Move out:** both tenant and landlord tap "moved out" (auto-confirmed after 3 days if one forgets)
- **Reviews:** tenant can review after 1 month of staying, and is asked again at move out

## Talk to people first (2–3 each)
**Landlords**
- How do you find tenants now?
- What's the most annoying part (posting, scams, late payments)?
- Would you list your rooms in an app if it was free? Why / why not?
- Would you update which rooms are available once a week?

**Students**
- How did you find your current boarding house?
- What went wrong or was annoying when searching?
- What do you check first: price, distance, curfew, Wi-Fi, CR?
- Would you leave a review of your boarding house?

Notes from talks:
- 

## Screens (draft)
**Tenant / student**
1. Sign up / log in
2. Home: list of boarding houses (photo, name, price range, stars, distance to school)
3. Search + filters (school, price, boys/girls only, curfew, Wi-Fi, etc.)
4. Map view
5. Listing page (property photos, description, tags, reviews)
6. Room tabs (each room's photos, price, available/taken)
7. Chat with landlord + call button
8. Leave a review
9. My profile (my ratings)
10. Saved (tap a heart to save a place)
11. Notifications (new message, review, reminders)
12. Report a listing (fake, or room already taken)
13. Settings (edit profile, log out)

**Landlord**
1. Landlord mode / dashboard
2. Add / edit property (photos, location, price range, tags)
3. Add / edit rooms (photos, price, available/taken)
4. Messages
5. My tenants (rate tenant, mark moved in / moved out)
6. Weekly "still available?" check

## User flows
**Student finds a room**
Open app → pick school → filter → open listing → check room tabs → chat/call landlord → visit → landlord marks "moved in"

**Landlord lists a place**
Sign up → switch to Landlord mode → add property + photos → add rooms → publish → answer messages

**Tenant moves out**
Tenant and landlord both tap "moved out" (auto after 3 days if one forgets) → room becomes available again → tenant asked to review the place → landlord asked to rate the tenant

## Data (what the database stores)
- **User:** name, phone, login type (phone / Google / Facebook), school, role (student / landlord), verified yes/no
- **Property:** landlord, name, location (map pin), photos, price range, tags, description
- **Room:** property, name (Room 1), type (bedspace for 2–6 / solo), photos, monthly price, what's included, private/shared CR, available/taken
- **Stay:** tenant, room, move-in date, move-out date, moved-out confirmed by tenant / landlord (proof for reviews)
- **Review:** who wrote it, about whom, stars, comment, landlord reply
- **Message:** from, to, text, time
- **Saved:** user, property
- **Report:** who reported, which listing, reason

## Version 1 plan (4 weeks)
- **Week 1:** set up Flutter + Firebase, login, landlord can add property + rooms with photos
- **Week 2:** home list, listing page, room tabs, search + filters, map
- **Week 3:** chat + call button, move in/out, reviews (verified stays only)
- **Week 4:** fix bugs, test with 2–3 real landlords, publish to Play Store

**Not doing in Version 1:** payments, rent reminders, ads, ID verification, customer service, iPhone release (Android first)

## Progress
Code: https://github.com/sawada-png/Boarding-house

**Week 1: done (Nov 17, 2026)**
- [x] Flutter + Firebase set up (project `boardmate-17cf9`, Firestore in Singapore)
- [x] Login: phone SMS code + Google (Facebook button is there, setup later)
- [x] Choose role: student or landlord ("Switch mode" in Profile)
- [x] Landlord adds / edits / deletes a boarding house (photos, map pin, price range, tags)
- [x] Landlord adds / edits / deletes rooms (photos, type, price, CR, what's included, available)
- [x] Landlord dashboard: available / taken / rooms count + "How students see your place"

**Changes from the plan (and why)**
- Photos are stored on **Cloudinary** (free), not Firebase Storage, because Firebase Storage needs the paid Blaze plan.
- Rooms got a **name** and **type** (bedspace for 2–6 people, or solo room).
- Built and tested on the web (localhost, phone-sized) first; Android build later.
- Popups and buttons use a BoardMate style, not plain iPhone defaults.

**To do before launch**
- [ ] Facebook login (needs a Meta developer app)
- [ ] Real SMS codes (needs Blaze plan; test number works now: +63 912 345 6789, code 123456)
- [ ] Deleting a photo doesn't remove it from Cloudinary yet

**Week 2: next**
- [ ] Home list with real boarding houses, sorted by distance to your school
- [ ] Pick your school (PSU Tiniguiban, WPU PPC, Holy Trinity)
- [ ] Listing page with photo gallery, map and room tabs
- [ ] Search + filters (price, girls/boys only, Wi-Fi, no curfew, has rooms available)
- [ ] Map tab with pins

**How to run the app**
1. Open the `Boarding-house` folder in Cursor, open a terminal
2. Type `flutter run -d web-server --web-port 8080`
3. Open http://localhost:8080 in Chrome

## Why I'm building this
- Learn app development using AI
- Portfolio project
- Potential money-making app

---

## Original notes

inspiration: airbnb

This boarding house app is just like airbnb but for boarding houses and apartments the goal here is to help renters rent boarding houses/apartments to people who are looking boarding houses/apartments. 

problem: i searched up boarding house in the app store or google play store but i havent seen an app made for that, i search how they hear about boarding houses here in the PH and all i see is a fb group posting what they are selling

how i want this to be build or how can i fix it: basically what i want is to the seller lists up the place lets say Nathan's boarding house, they show pictures of it at the home page. Then after clicking that the renter will see the pictures of the place like what it includes the hallway, aesthetic, how it looks etc( this isnt a mandatory pics but just a picture so what the play looks like) then after that the they can list what rooms are available and what are taken, each tabs showcasing different rooms that are available or not available, so lets say they press room 1 it shows pictures of that room(room,bed what it includes, comfort room, kitchen, etc) it might be just a room and the kitchen is shared and the comfort room. The place must have stars on it and how kind or bad the seller of the place, so basically people can leave a review about the page, also im planning to safeguard the reviewbombing for no reason like just random people who are spitting negative reviews about the place. the home tab or page must have a price range for example "est. 5k -10k pesos a month. Now for the people who are looking can search up boarding houses near at their desired location, lets say a work place, school or etc. the people also have a review rating for them so renters can see if this people are good people who pays on time or not.
