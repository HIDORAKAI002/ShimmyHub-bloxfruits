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
