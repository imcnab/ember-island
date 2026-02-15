# Ember Island

A farming simulation game inspired by Stardew Valley, built with Godot 4.6.

## Project Overview

**Genre**: Farming Simulation  
**Engine**: Godot 4.6  
**Language**: GDScript  
**Art Style**: Starting with pixel art (Sprout Lands), architected for eventual high-res assets (Coral Island style)  
**Target Platform**: Linux (development), Windows/Mac (future export)

## Development Philosophy

This project follows a **learning-first** approach with emphasis on:
- Deep understanding of game architecture
- Data-driven design patterns
- Resolution-independent systems
- Best practices from day one
- Comprehensive documentation

## Architecture Overview

### Core Design Patterns

**Resolution Independence**:
- Logical grid size (16x16) separated from visual tile size
- Enables art style changes without code refactoring
- All game logic uses `Constants.TILE_SIZE` for calculations

**Data-Driven State**:
- Game state stored in data structures (Dictionaries/Arrays), not scene nodes
- Enables save/load, chunk loading, and time-delta catchup
- Rendering layer separate from data layer

**Continuous Time System**:
- Game time independent of OS clock (exploit prevention)
- Time scaling support (1 real second = 1 game minute)
- Time-delta catchup for entities (crops grow while offline)

### Autoload Singletons

Three global manager scripts provide foundational systems:

**Constants** (`scripts/autoload/constants.gd`):
- Grid coordinate conversion utilities
- Resolution-independent spatial calculations
- Defines `TILE_SIZE = 16` as immutable logical grid

**GameTime** (`scripts/autoload/game_time.gd`):
- In-game time progression (independent of real time)
- Time scaling (default 60x = 1 real second = 1 game minute)
- Pause/resume support for menus and dialogue

**WorldState** (`scripts/autoload/world_state.gd`):
- Central game state storage (crops, NPCs, objects)
- Data-driven architecture (state in dictionaries, not nodes)
- Future: Save/load serialization, chunk management

## Project Structure

```
EmberIsland/
├── project.godot          # Godot project configuration
├── icon.svg               # Project icon
├── README.md              # This file
├── .gitignore             # Version control exclusions
│
├── scenes/                # Scene files (.tscn)
│   ├── player/            # Player character scenes
│   ├── world/             # World/map scenes
│   ├── npcs/              # NPC character scenes
│   ├── ui/                # User interface scenes
│   └── items/             # Item/object scenes
│
├── scripts/               # Script files (.gd)
│   ├── autoload/          # Global singleton scripts (Constants, GameTime, WorldState)
│   ├── player/            # Player behavior scripts
│   ├── world/             # World management scripts
│   ├── npcs/              # NPC AI and behavior
│   ├── ui/                # UI controllers
│   ├── items/             # Item definitions and logic
│   └── data/              # Data resource classes (CropData, ItemData, etc.)
│
├── assets/                # Game assets
│   ├── sprites/           # Visual assets
│   │   ├── characters/    # Character spritesheets
│   │   ├── tilesets/      # Tile textures (terrain, objects)
│   │   ├── items/         # Item icons and sprites
│   │   └── objects/       # Object sprites (trees, rocks, etc.)
│   ├── audio/             # Sound effects and music
│   └── fonts/             # UI fonts
│
└── tests/                 # Unit tests (future)
```

## Getting Started

### Prerequisites

- Godot 4.6 installed
- Git configured
- GitHub account (for remote repository)

### Setup (Already Complete)

This project has been initialized with:
- ✅ Git repository
- ✅ Proper `.gitignore` for Godot
- ✅ Project configuration (`project.godot`)
- ✅ Folder structure
- ✅ Core autoload scripts (Constants, GameTime, WorldState)

### Next Steps (Session 1 Goals)

1. **Create Player Character**:
   - Scene: `scenes/player/player.tscn`
   - Script: `scripts/player/player.gd`
   - Implement 4-directional movement with WASD/Arrow keys

2. **Setup Player Animation**:
   - Import Sprout Lands character spritesheet
   - Configure AnimationPlayer for walk cycles
   - Animate idle and walking states

3. **Create Basic World**:
   - Scene: `scenes/world/world.tscn`
   - Import Sprout Lands tileset
   - Setup TileMap for ground layer
   - (Time permitting) Add collision layer

## Asset Attribution

**Sprout Lands**: Premium asset pack by [credit here]  
Located in: `assets/sprites/`

## Development Workflow

### Adding New Features

1. **Theory First**: Understand the architectural pattern
2. **Plan**: How does this fit into existing systems?
3. **Implement**: Write documented, type-hinted code
4. **Test**: Verify behavior in editor
5. **Commit**: Atomic commits with descriptive messages

### Git Workflow

```bash
# Make changes
git add .
git commit -m "feat: add player movement system"
git push

# Feature branches (for larger work)
git checkout -b feature/crop-system
# ... work ...
git commit -m "feat: implement crop planting logic"
git push -u origin feature/crop-system
```

### Commit Message Convention

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code restructuring (no behavior change)
- `test:` Adding/modifying tests
- `chore:` Tooling, config changes

## Learning Resources

**Official Docs**: https://docs.godotengine.org  
**GDScript Reference**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript  
**Community**: r/godot, Godot Discord

## Architectural Decision Records

For detailed architectural rationale, see:
- `docs/architectural_decisions.md` (comprehensive design patterns)
- `docs/learning_roadmap.md` (30-session curriculum)

## Current Status

**Session**: 1 - Foundation Setup  
**Tier**: 1 - Foundation (Sessions 1-5)  
**Completed**:
- ✅ Project initialization
- ✅ Git repository with proper .gitignore
- ✅ Folder structure
- ✅ Core autoload scripts
- ⬜ Player movement system (next)
- ⬜ Player animation (next)
- ⬜ Basic tilemap world (next)

## License

[To be determined]

## Contact

GitHub: https://github.com/imcnab
