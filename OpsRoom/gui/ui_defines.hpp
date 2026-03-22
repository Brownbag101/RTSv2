/*
    Operations Room - UI Definitions
    
    Defines color schemes, fonts, and base control classes.
    British Army khaki green theme.
*/

// ========================================
// COLOR DEFINITIONS
// ========================================
#define COLOR_MAIN_BG {0.27, 0.22, 0.14, 0.9}
#define COLOR_ELEMENT_BG {0.33, 0.29, 0.20, 0.8}
#define COLOR_BORDER {0.20, 0.16, 0.10, 1.0}
#define COLOR_TEXT {0.85, 0.82, 0.74, 1.0}
#define COLOR_BUTTON_BG {0.40, 0.35, 0.25, 0.85}
#define COLOR_BUTTON_HOVER {0.45, 0.40, 0.30, 0.95}

// Dialog-specific colors
#define COLOR_BACKGROUND {0.26, 0.30, 0.21, 0.95}
#define COLOR_HEADER {0.20, 0.25, 0.18, 1.0}
#define COLOR_BUTTON {0.26, 0.30, 0.21, 1.0}
#define COLOR_BUTTON_ACTIVE {0.30, 0.35, 0.25, 1.0}

// ========================================
// FONT DEFINITIONS
// ========================================
#define FONT_MAIN "PuristaMedium"
#define FONT_BOLD "PuristaBold"
#define FONT_LIGHT "PuristaLight"

// ========================================
// BASE CONTROL CLASSES
// ========================================
class RscText {
    access = 0;
    type = 0;
    idc = -1;
    style = 0;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = COLOR_TEXT;
    font = FONT_MAIN;
    sizeEx = 0.03;
    fixedWidth = 0;
    shadow = 1;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.05;
    text = "";
};

class RscStructuredText {
    access = 0;
    type = 13;
    idc = -1;
    style = 0;
    colorText[] = COLOR_TEXT;
    class Attributes {
        font = FONT_MAIN;
        color = "#FFFFFF";
        align = "left";
        shadow = 1;
    };
    x = 0;
    y = 0;
    h = 0.035;
    w = 0.1;
    text = "";
    size = 0.03;
    shadow = 1;
};

class RscButton {
    access = 0;
    type = 1;
    style = 0;
    text = "";
    colorText[] = COLOR_TEXT;
    colorDisabled[] = {0.4, 0.4, 0.4, 1};
    colorBackground[] = COLOR_BUTTON_BG;
    colorBackgroundDisabled[] = {0.3, 0.3, 0.3, 1};
    colorBackgroundActive[] = COLOR_BUTTON_HOVER;
    colorFocused[] = COLOR_BUTTON_HOVER;
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = COLOR_BORDER;
    soundEnter[] = {"", 0.09, 1};
    soundPush[] = {"", 0.09, 1};
    soundClick[] = {"", 0.09, 1};
    soundEscape[] = {"", 0.09, 1};
    font = FONT_BOLD;
    sizeEx = 0.03;
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0.001;
    offsetPressedY = 0.001;
    borderSize = 0.002;
    shadow = 1;
    x = 0;
    y = 0;
    w = 0.095589;
    h = 0.039216;
};

class RscActiveText {
    access = 0;
    type = 11;
    idc = -1;
    style = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.05;
    text = "";
    font = FONT_BOLD;
    sizeEx = 0.03;
    color[] = COLOR_TEXT;
    colorActive[] = {1, 1, 1, 1};
    colorDisabled[] = {0.5, 0.5, 0.5, 0.5};
    soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
    soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
    action = "";
    default = 0;
};

class RscBackground {
    type = 0;
    idc = -1;
    style = 512;
    colorBackground[] = COLOR_MAIN_BG;
    colorText[] = {1, 1, 1, 1};
    font = FONT_MAIN;
    sizeEx = 0.023;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.3;
    h = 0.3;
    text = "";
};

class RscFrame {
    type = 0;
    idc = -1;
    style = 64;
    shadow = 2;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = COLOR_BORDER;
    font = FONT_MAIN;
    sizeEx = 0.02;
    text = "";
    x = 0;
    y = 0;
    w = 0.3;
    h = 0.3;
};

class RscPicture {
    access = 0;
    type = 0;
    idc = -1;
    style = 48;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {1, 1, 1, 1};
    font = FONT_MAIN;
    sizeEx = 0;
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.15;
};

class RscMapControl {
    access = 0;
    type = 101;
    idc = -1;
    style = 48;
    colorBackground[] = {0.969, 0.957, 0.949, 1.0};
    colorOutside[] = {0, 0, 0, 1};
    colorText[] = {0, 0, 0, 1};
    font = "TahomaB";
    sizeEx = 0.04;
    colorSea[] = {0.467, 0.631, 0.851, 0.5};
    colorForest[] = {0.624, 0.78, 0.388, 0.5};
    colorRocks[] = {0, 0, 0, 0.3};
    colorCountlines[] = {0.572, 0.354, 0.188, 0.25};
    colorMainCountlines[] = {0.572, 0.354, 0.188, 0.5};
    colorCountlinesWater[] = {0.491, 0.577, 0.702, 0.3};
    colorMainCountlinesWater[] = {0.491, 0.577, 0.702, 0.6};
    colorForestBorder[] = {0, 0, 0, 0};
    colorRocksBorder[] = {0, 0, 0, 0};
    colorPowerLines[] = {0.1, 0.1, 0.1, 1};
    colorRailWay[] = {0.8, 0.2, 0, 1};
    colorNames[] = {0.1, 0.1, 0.1, 0.9};
    colorInactive[] = {1, 1, 1, 0.5};
    colorLevels[] = {0.286, 0.177, 0.094, 0.5};
    colorGrid[] = {0.1, 0.1, 0.1, 0.6};
    colorGridMap[] = {0.1, 0.1, 0.1, 0.4};
    colorTracks[] = {0.84, 0.76, 0.65, 0.15};
    colorTracksFill[] = {0.84, 0.76, 0.65, 1};
    colorRoads[] = {0.7, 0.7, 0.7, 1};
    colorRoadsFill[] = {1, 1, 1, 1};
    colorMainRoads[] = {0.9, 0.5, 0.3, 1};
    colorMainRoadsFill[] = {1, 0.6, 0.4, 1};
    widthRailWay = 1;
    maxSatelliteAlpha = 0.85;
    alphaFadeStartScale = 0.35;
    alphaFadeEndScale = 0.4;
    ptsPerSquareSea = 5;
    ptsPerSquareTxt = 20;
    ptsPerSquareCLn = 10;
    ptsPerSquareExp = 10;
    ptsPerSquareCost = 10;
    ptsPerSquareFor = 9;
    ptsPerSquareForEdge = 9;
    ptsPerSquareRoad = 6;
    ptsPerSquareObj = 9;
    showCountourInterval = 0;
    scaleMin = 0.001;
    scaleMax = 1.0;
    scaleDefault = 0.16;
    onMouseButtonClick = "";
    onMouseButtonDblClick = "";
    moveOnEdges = 0;
    x = 0;
    y = 0;
    w = 0.4;
    h = 0.4;
    text = "#(argb,8,8,3)color(1,1,1,1)";
    class Legend {
        x = 0;
        y = 0;
        w = 0;
        h = 0;
        font = "TahomaB";
        sizeEx = 0;
        colorBackground[] = {1, 1, 1, 0};
        color[] = {0, 0, 0, 0};
    };
    class ActiveMarker {
        color[] = {0.3, 0.1, 0.9, 1};
        size = 50;
    };
    class Command {
        icon = "#(argb,8,8,3)color(1,1,1,1)";
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
        color[] = {1, 1, 1, 1};
    };
    class Task {
        icon = "#(argb,8,8,3)color(1,1,1,1)";
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
        color[] = {1, 1, 1, 1};
        iconCreated = "#(argb,8,8,3)color(1,1,1,1)";
        iconCanceled = "#(argb,8,8,3)color(1,1,1,1)";
        iconDone = "#(argb,8,8,3)color(1,1,1,1)";
        iconFailed = "#(argb,8,8,3)color(1,1,1,1)";
        colorCreated[] = {1, 1, 1, 1};
        colorCanceled[] = {1, 1, 1, 1};
        colorDone[] = {1, 1, 1, 1};
        colorFailed[] = {1, 1, 1, 1};
    };
    class CustomMark {
        icon = "#(argb,8,8,3)color(1,1,1,1)";
        size = 18;
        importance = 1;
        coefMin = 1;
        coefMax = 1;
        color[] = {1, 1, 1, 1};
    };
    class Tree {
        icon = "";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 12;
        importance = 0.9;
        coefMin = 0.25;
        coefMax = 4;
    };
    class SmallTree {
        icon = "";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 12;
        importance = 0.6;
        coefMin = 0.25;
        coefMax = 4;
    };
    class Bush {
        icon = "";
        color[] = {0.45, 0.64, 0.33, 0.4};
        size = 14;
        importance = 0.2;
        coefMin = 0.25;
        coefMax = 4;
    };
    class Church {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Chapel {
        icon = "";
        color[] = {0, 0, 0, 1};
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Cross {
        icon = "";
        color[] = {0, 0, 0, 1};
        size = 24;
        importance = 1;
        coefMin = 0.85;
        coefMax = 1;
    };
    class Rock {
        icon = "";
        color[] = {0.1, 0.1, 0.1, 0.8};
        size = 12;
        importance = 0.5;
        coefMin = 0.25;
        coefMax = 4;
    };
    class Fountain {
        icon = "";
        color[] = {0, 0, 0, 1};
        size = 11;
        importance = 1;
        coefMin = 0.25;
        coefMax = 4;
    };
    class ViewTower {
        icon = "";
        color[] = {0, 0, 0, 1};
        size = 16;
        importance = 2.5;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Lighthouse {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 20;
        importance = 2;
        coefMin = 0.25;
        coefMax = 4;
    };
    class Quay {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 2;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Fuelstation {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 20;
        importance = 2;
        coefMin = 0.75;
        coefMax = 4;
    };
    class Hospital {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 22;
        importance = 2;
        coefMin = 0.75;
        coefMax = 4;
    };
    class BusStop {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 10;
        importance = 1;
        coefMin = 0.25;
        coefMax = 4;
    };
    class Transmitter {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 20;
        importance = 2;
        coefMin = 0.5;
        coefMax = 4;
    };
    class Stack {
        icon = "";
        color[] = {0, 0, 0, 1};
        size = 20;
        importance = 2;
        coefMin = 0.9;
        coefMax = 4;
    };
    class Ruin {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1.2;
        coefMin = 1;
        coefMax = 4;
    };
    class Tourism {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 16;
        importance = 1;
        coefMin = 0.7;
        coefMax = 4;
    };
    class Watertower {
        icon = "";
        color[] = {1, 1, 1, 1};
        size = 18;
        importance = 1.2;
        coefMin = 0.9;
        coefMax = 4;
    };
};

class RscCombo {
    access = 0;
    type = 4;
    style = 0;
    idc = -1;
    x = 0;
    y = 0;
    w = 0.12;
    h = 0.035;
    font = FONT_MAIN;
    sizeEx = 0.03;
    colorText[] = COLOR_TEXT;
    colorBackground[] = {0.2, 0.2, 0.15, 0.9};
    colorSelect[] = {0, 0, 0, 1};
    colorSelectBackground[] = COLOR_BUTTON;
    colorScrollbar[] = {1, 1, 1, 0.6};
    colorDisabled[] = {0.4, 0.4, 0.4, 1};
    colorActive[] = COLOR_BUTTON_ACTIVE;
    wholeHeight = 0.3;
    maxHistoryDelay = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    soundSelect[] = {"", 0.1, 1};
    soundExpand[] = {"", 0.1, 1};
    soundCollapse[] = {"", 0.1, 1};
    arrowEmpty = "";
    arrowFull = "";
    shadow = 0;
    class ComboScrollBar {
        color[] = {1, 1, 1, 0.6};
        colorActive[] = {1, 1, 1, 1};
        colorDisabled[] = {1, 1, 1, 0.3};
        thumb = "";
        arrowEmpty = "";
        arrowFull = "";
        border = "";
    };
};

class RscEdit {
    access = 0;
    type = 2;
    idc = -1;
    style = 0;
    colorBackground[] = {0.12, 0.14, 0.10, 0.9};
    colorText[] = {0.9, 0.9, 0.8, 1.0};
    colorSelection[] = {0.35, 0.40, 0.30, 1.0};
    colorDisabled[] = {0.4, 0.4, 0.4, 1};
    font = "PuristaLight";
    sizeEx = 0.035;
    autocomplete = "";
    canModify = 1;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.04;
    text = "";
};

class RscListbox {
    access = 0;
    type = 5;
    style = 16;
    w = 0.4;
    h = 0.4;
    font = FONT_MAIN;
    sizeEx = 0.03;
    rowHeight = 0;
    colorText[] = COLOR_TEXT;
    colorDisabled[] = {1, 1, 1, 0.25};
    colorScrollbar[] = {1, 1, 1, 0};
    colorSelect[] = {0, 0, 0, 1};
    colorSelect2[] = {0, 0, 0, 1};
    colorSelectBackground[] = COLOR_BUTTON;
    colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
    colorBackground[] = {0, 0, 0, 0.3};
    maxHistoryDelay = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    soundSelect[] = {"", 0.1, 1};
    period = 1;
    shadow = 0;
    arrowEmpty = "";
    arrowFull = "";
    border = "";
    class ListScrollBar {
        color[] = {1, 1, 1, 0.6};
        colorActive[] = {1, 1, 1, 1};
        colorDisabled[] = {1, 1, 1, 0.3};
        thumb = "";
        arrowEmpty = "";
        arrowFull = "";
        border = "";
    };
};
