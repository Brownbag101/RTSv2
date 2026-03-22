# Regiment Badge Images

This folder contains badge images for regiments.

## Required Image Format
- **Format**: .paa (ARMA 3 texture format)
- **Dimensions**: 256x256 or 512x512 recommended
- **Naming**: Use lowercase with underscores, e.g., `essex.paa`

## Creating Placeholder Badge

For now, you'll need to create a placeholder badge. Here's how:

### Option 1: Use ImageToPAA Tool
1. Create a 256x256 PNG image with khaki green background
2. Add text "BADGE" in center
3. Use ARMA 3 Tools "ImageToPAA" converter to convert PNG to PAA
4. Name it `placeholder.paa`

### Option 2: Use Existing ARMA Asset
Temporarily use an ARMA icon as placeholder:
```sqf
// In your code, change:
"OpsRoom\images\badges\placeholder.paa"
// To:
"\A3\ui_f\data\gui\cfg\ranks\major_gs.paa"  // Uses built-in rank badge
```

## Current Regiment Images Needed
- essex.paa (The Essex Regiment)
- placeholder.paa (Generic placeholder for new regiments)

## Future: Custom Badges
Once you have proper cap badge images:
1. Convert to 256x256 PNG
2. Use ImageToPAA converter
3. Name appropriately (essex.paa, yorkshire.paa, etc.)
4. Update regiment data with correct image path
