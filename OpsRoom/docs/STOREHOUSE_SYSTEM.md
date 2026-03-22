# Storehouse System — Implementation Summary

## What Was Built

**12 new files** in `OpsRoom/gui/storehouse/`:

| File | Purpose |
|------|---------|
| `dialog_storehouse_grid.hpp` | Selection grid (idd 11006, 8 slots) |
| `dialog_storehouse_interior.hpp` | Interior view (idd 11007, 3 panels + bottom) |
| `fn_initStorehouses.sqf` | Scans markers, creates data structures |
| `fn_openStorehouseGrid.sqf` | Opens grid dialog |
| `fn_populateStorehouseGrid.sqf` | Populates grid with storehouse data |
| `fn_openStorehouseInterior.sqf` | Opens interior for a storehouse |
| `fn_populateStorehouseUnits.sqf` | Lists friendly units near storehouse |
| `fn_populateStorehouseUnitInv.sqf` | Shows selected unit's inventory |
| `fn_populateStorehouseInventory.sqf` | Shows storehouse virtual inventory |
| `fn_absorbCrates.sqf` | Scans + consumes physical crates |
| `fn_scanStorehouseCrates.sqf` | Reports crates in area (no absorption) |
| `fn_storehouseTransfer.sqf` | Transfer items unit ↔ storehouse |

## Modified Files

| File | Change |
|------|--------|
| `config.hpp` | Added Storehouse class (10 functions) |
| `init.sqf` | Added `initStorehouses` call |
| `displays.hpp` | Added 2x `#include` for storehouse dialogs |
| `fn_createButtonsOnZeus.sqf` | Renamed ECONOMY → STORES, wired 9207 button |
| `settings.sqf` | Added storehouse radius + max settings |
| `data/locationTypes.sqf` | Added "stores" location type |
| `data/equipmentDatabase.sqf` | Added Bedford MW (Ammo Truck) |

## IDC Ranges

- Storehouse Grid: 11600-11699
- Storehouse Interior: 11700-11899

## How to Set Up in Eden Editor

1. Place markers named `opsroom_stores_1`, `opsroom_stores_2` etc.
2. Optionally set marker text for custom names (e.g. "Forward Depot Alpha")
3. If no storehouse markers found, falls back to `OpsRoom_SupplyPoint` marker

## Gameplay Flow

```
STORES button → Grid (select storehouse) → Interior
    Left:   Units in area (click to select)
    Centre: Selected unit's inventory
    Right:  Storehouse virtual inventory
    Bottom: Crate scan + ABSORB button + transfer buttons
```

## Bedford MW (Ammo Truck)

- **ID:** `bedford_mw_ammo`
- **Class:** `JMSSA_veh_bedfordMW_E_ammo`
- **Research:** Tier 2, requires Willys Jeep, costs 2 RP, 8 min
- **Production:** 15 min, costs 6 Steel + 3 Rubber + 2 Oil
- **Batch:** 1 truck per cycle

## Next Steps (Cargo System)

The cargo load/unload system (from MASTER folder) needs porting to enable:
- Truck loads crate at Supply Point
- Truck drives to storehouse
- Truck unloads crate
- Player absorbs crate into storehouse database
