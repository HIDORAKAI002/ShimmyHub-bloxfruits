# Shimmy Hub Development Log

This file acts as a permanent record of all iterations, bug fixes, and future integration plans for the Shimmy Hub project.
**Rule:** No deleting or editing past written blocks. A new block is appended every session/iteration.

---

## Iteration 1: Custom UI & Core Automation (May 2, 2026)

### What we worked on:
- Replaced the external `Rayfield` UI library with a 100% custom-built `ShimmyUI` framework.
- Built a vertical left-sided sidebar for tab navigation.
- Implemented a flawlessly draggable minimize button (`💥`) that directly modifies `Visible` states instead of sending simulated keypresses.
- Integrated a Server-Side `CombatFramework` hook for "Fast Attack" to bypass the 2 CPS Roblox limit and animation delays.
- Built an autonomous Quest-driven AutoFarm that reads from the Compass and Quest UI.
- Built a PvP team filter to ensure we only target enemies.

### Issues Identified & Fixed:
- **Issue:** The `mouse1click()` fallback for Fast Attack locked the player's joystick and physical mouse.
- **Fix:** We completely removed hardware mouse manipulation and replaced it with `VirtualUser:CaptureController()` and `VirtualUser:ClickButton1(Vector2.new())`. This simulates clicks entirely in the engine background without hijacking hardware inputs.
- **Issue:** The UI was draggable from anywhere, intercepting slider inputs.
- **Fix:** Bound drag logic exclusively to the `Sidebar` and an invisible `DragArea` at the top.
- **Issue:** Sliders didn't work on mobile/tablets due to `GetMouseLocation()`.
- **Fix:** Switched slider input parsing to use `input.Position.X` which is cross-platform compatible.
- **Issue:** Tweening floated above the player (`CFrame.new(0, 10, 0)`).
- **Fix:** Enforced `CFrame.new(0, 0, 0)` so the player model phases directly into the target for maximum melee consistency.
- **Issue:** Auto Quest mob targeting required exact manual typing.
- **Fix:** Implemented a Dynamic NPC Dropdown that scans `workspace.Enemies` to generate a clickable list of valid mobs.

### Future Integrations:
- Advanced Pathfinding (`PathfindingService`) for complex geometry bypasses (maze/walls).
- Auto-Bounty hunting logic with server hopping.
- Complete Fruit Sniper & Auto-Store logic.
- Advanced combat dodging (reading enemy animation tracks and tweening dynamically).

---

## Iteration 2: Quality of Life & Combat Optimization

### What we worked on:
- **Native UI Dragging:** Reverted the limited DragArea. The entire MainFrame is now draggable natively. We achieved this without breaking sliders or buttons by setting Active = true on all interactive UI element frames, allowing them to block the drag event from bubbling up to the MainFrame.
- **Combat Tweening Reverted:** Mobs and AutoQuest targets now tween to CFrame.new(0, 8, 5) (above and behind) to avoid enemy attacks, while PvP targets still use point-blank CFrame.new(0, 0, 0) for direct hits.
- **Expanded Hitboxes:** Since we are floating above mobs again, we drastically increased the target's HumanoidRootPart.Size to Vector3.new(60, 60, 60) and disabled collision. This guarantees our melee strikes will hit them from anywhere in the vicinity while we stay safely out of their attack range.
- **Dynamic Auto-Refresh Dropdowns:** Removed the manual 'Refresh' buttons. Dropdowns now utilize an OnInteract hook that automatically scans workspace and repopulates the list the exact moment the user taps the dropdown menu.
- **Mobile Optimization:** Increased Dropdown List expansion height and made scrollbars drastically thicker (8px) so they can be easily grabbed on touch screens.
