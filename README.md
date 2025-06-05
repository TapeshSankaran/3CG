# Greek Slam (3CG)
 A greek-themed card game

**Programming Patterns** 

Greek Slam follows the Component pattern, where entities like "Medusa" or "Zeus" are represented as data objects with behaviors like onPlay attached as properties. This decouples the logic from a rigid class hierarchy, making it easy to extend or modify individual card behavior without touching a central Card class. By storing behaviors (like onPlay) as functions inside these objects, the design achieves flexibility and supports polymorphic execution at runtime.

Additionally, Greek Slam loosely implements the Event Queue pattern by waiting for user inputs (like pressing "Enter") or triggering actions during game phases such as onPlay. These hooks act as deferred execution points that let the game respond to changes or inputs in a predictable, decoupled way. Combined, these patterns allow for more maintainable, modular game logic where new cards or abilities can be introduced with minimal friction.

**Feedback**

- *Marcus Ochoa*: "The code is readable and consistently styled, with helpful comments and clean use of Lua, including explicit file requiring and appropriate use of metatables. Class and file responsibilities are well separated, and data is organized effectively—e.g., conf.lua neatly stores constants and utility functions. I only noticed minor nitpicks: the state at conf.lua:62 might be more robust as an enum instead of a string, and slot indexing could possibly be abstracted into general set logic, unless the index order is necessary for rendering or updates. The drag.lua file is quite long, combining dragging logic, states, and button handling; consider moving button logic into a separate class or manager, and managing states externally."(paraphrase). I was unable to fully fix drag.lua, but I made it cleaner by making the state variable into a component of the game object.

- I do not have any more reviewers for this project unfortunately.

**Postmortem**

The code I implemented is somewhat well-made. I did reuse some code from before, but it was integrated into this project. While some of the code isn't fully commented, my only conscern with messiness is in Drag.lua, which holds all input-related actions as well as the state changes. This was done to allow for time in between stages of battles. Some things I would do differently would be to implement a different game loop that avoids such a large amount of state changes in the update function. 

Overall, I am happy with how the game turned out and am looking forward to upgrading it in this future project. 

---

**Sources**
- Fonts(Indicators for rounds, win, mana, points, cards etc.): [Dafont](https://www.dafont.com/)
- Cards(Empty card and card back(cardback was heavily edited though)): [Elvgames](https://elvgames.itch.io/playing-cards-pixelart-asset-pack)
- Icons(All card Icons and end turn button): [Flaticon](https://www.flaticon.com/packs/search?word=greek%20mythology)
- Everything else was made by me.