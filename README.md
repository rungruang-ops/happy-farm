# Happy Farm 🐷🌻

A touch-first preschool farm game prototype for children aged 2–5. Built as a dependency-free static web app so it can be tested locally without a build step or paid services.

## Run locally
Open `index.html` in a modern browser, or serve this folder with any static HTTP server. No npm install, API key, backend, or cloud service is required.

## Current MVP
- Home screen and five activity cards
- Three rounds per activity with touch-friendly large controls
- Activities: animal matching, colors, garden produce, feeding, and counting eggs
- Stars and completed activities saved locally in the browser
- Responsive layout, accessible labels, reduced-motion support, gentle feedback
- No deployment configured

## Important design note
Bryan is currently represented by an inline SVG concept illustration (yellow shirt, red overalls) and the farm uses CSS/vector scenery. These are implementation placeholders, **not yet approved final 3D character/environment assets**. The supplied reference design remains the acceptance source for final art. Replace the placeholder artwork only after comparing against the reference image and checking silhouette, proportions, face, clothing, palette, and scene composition.

## QA checklist
- [ ] Test on iPhone Safari and Android Chrome
- [ ] Verify all five activities can be completed by tapping
- [ ] Verify feed activity works with touch as well as mouse/drag
- [ ] Verify progress persists after refresh and can recover from malformed local storage
- [ ] Compare character and scenes against supplied design reference
- [ ] Add final approved 3D assets, sound, and caregiver-friendly audio controls
- [ ] Test reduced motion, contrast, and screen reader announcements

## Scope / safety
This prototype runs locally in the browser and stores progress only in localStorage. It has no analytics, login, network calls, or paid service integration. Not yet a production release.
