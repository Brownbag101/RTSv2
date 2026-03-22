# Operations Room - Development Branch

Hearts of Iron-style RTS interface for ARMA 3 Zeus.

## Quick Start

```
1. Run TEMP_COPY.bat (first time only - copies files)
2. Edit files in OpsRoom/ folder
3. Run ../SYNC_OpsRoom.bat
4. Select mission → Press A (Quick Sync)
5. Test in ARMA 3
```

## Documentation

- **QUICK_START.md** - 3-step workflow
- **EDITING_GUIDE.md** - How to edit things
- **BUTTON_GUIDE.md** - Button system reference
- **SYSTEM_REFERENCE.md** - Technical API
- **CHANGELOG.md** - Version history

## Files

- `description.ext` - Template for new missions
- `init.sqf` - Template for new missions
- `OpsRoom/` - The actual system (edit these)
  - `config.hpp` - Function registration
  - `init.sqf` - System initialization
  - `settings.sqf` - Default values
  - `gui/` - GUI system files
  - `zeus/` - Zeus integration
  - `data/` - Data files
  - `docs/` - Documentation

## Workflow

**Development:**
1. Edit OpsRoom/ files
2. Sync to mission
3. Test

**Deployment:**
- Quick Sync (A) - OpsRoom folder only (fast)
- Full Sync (B) - OpsRoom + mission files (setup)

## Features

✅ 10 side buttons (customizable)  
✅ Resource tracking (6 resources)  
✅ Unit information display  
✅ Regiment management  
✅ Group management  
✅ Unit roster system  
✅ Zeus integration  
✅ Auto-detach/reattach

## Current Status

**Working:** Everything  
**Ready:** Production deployment  
**Next:** Implement button functions

---

**See docs/ for details.**