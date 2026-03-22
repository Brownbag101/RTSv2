# 🎖️ RECRUITMENT SYSTEM - QUICK REFERENCE

## Testing Checklist

1. ✅ Run `SYNC_OpsRoom.bat`
2. ✅ Load mission in ARMA 3
3. ✅ Open Zeus (Y key)
4. ✅ Click "RECRUITMENT" button (#2 left side)
5. ✅ Select a recruit
6. ✅ Click "ENLIST RECRUIT"
7. ✅ Pick a group
8. ✅ Watch unit spawn near player

## What Changed

### Unit Detail Dialog
- Back button → Title bar
- DEMOTE → Removed
- TRANSFER → TRAINING
- Buttons → Centered

### Recruitment
- Pool size = Manpower
- 90% regular (1-3 skills)
- 10% good ★ (5-10 some skills)
- Refresh every 5 min
- British WW2 gear
- Costs 1 manpower

## Key Files
- Button: `fn_createButtonsOnZeus.sqf` line ~95
- Dialog: `dialog_recruitment.hpp`
- Spawn: `fn_spawnRecruit.sqf`
- Pool: `fn_initRecruitmentPool.sqf`

## Troubleshooting

**Buttons not showing?**
- Check Zeus open (findDisplay 312)
- Check RPT log for errors

**No recruits?**
- Check manpower > 0
- Use Refresh Pool button

**Can't assign?**
- Create a group first in REGIMENTS

## Settings (settings.sqf)
```sqf
RecruitmentRefreshInterval = 300  // 5 min
RecruitmentGoodChance = 0.10      // 10%
```

## Done! 🎉
All 18 files created/modified.
Ready to sync and test!
