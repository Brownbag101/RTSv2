/*
    Update Active Shipments Display (Convoy v2)
    
    Shows active convoy status in the bottom panel.
    New convoy structure: [id, codename, ships, laneId, portLocId, orderTime, spawnDelay, status, shipsAlive]
    
    Usage:
        [] call OpsRoom_fnc_updateActiveShipments;
*/

private _display = findDisplay 11005;
if (isNull _display) exitWith {};

private _convoysCtrl = _display displayCtrl 11460;

if (count OpsRoom_ActiveConvoys == 0) then {
    _convoysCtrl ctrlSetStructuredText parseText "<t color='#666666' size='0.9'>No active convoys.</t>";
} else {
    private _text = "";
    
    {
        private _convoy = _x;
        private _convoyId = _convoy select 0;
        private _codename = _convoy select 1;
        private _ships = _convoy select 2;
        private _seaLaneId = _convoy select 3;
        private _portLocId = _convoy select 4;
        private _orderTime = _convoy select 5;
        private _spawnDelay = _convoy select 6;
        private _status = _convoy select 7;
        private _shipsAlive = _convoy select 8;
        
        private _laneData = OpsRoom_SeaLanes getOrDefault [_seaLaneId, createHashMap];
        private _laneName = _laneData getOrDefault ["name", "Unknown"];
        private _portData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
        private _portName = if (count _portData > 0) then { _portData get "name" } else { "Unknown" };
        
        private _statusColor = switch (_status) do {
            case "ordered":   { "#FFD966" };
            case "sailing":   { "#80CCFF" };
            case "unloading": { "#FFD966" };
            case "returning": { "#8888CC" };
            case "complete":  { "#80FF80" };
            case "destroyed": { "#FF6666" };
            default           { "#AAAAAA" };
        };
        
        private _statusText = switch (_status) do {
            case "ordered": {
                private _orderDate = _orderTime select 1;
                private _orderNum = dateToNumber _orderDate;
                private _nowNum = dateToNumber date;
                private _elapsedHours = (_nowNum - _orderNum) * 365 * 24;
                private _remaining = (_spawnDelay - _elapsedHours) max 0;
                private _remainMins = ceil (_remaining * 60);
                format ["AWAITING DEPARTURE — %1 min", _remainMins]
            };
            case "sailing":   { format ["EN ROUTE TO %1 — %2 ships", _portName, _shipsAlive] };
            case "unloading": { format ["UNLOADING AT %1", _portName] };
            case "returning": { "SHIPS RETURNING" };
            case "complete":  { "COMPLETE" };
            case "destroyed": { "ALL SHIPS LOST" };
            default           { toUpper _status };
        };
        
        _text = _text + format [
            "<t color='%1' font='PuristaBold' size='0.95'>Convoy %2</t> <t size='0.85' color='#AAAAAA'>via %3 → %4</t><br/><t size='0.85' color='%1'>  %5</t><br/>",
            _statusColor, _codename, _laneName, _portName, _statusText
        ];
        
        // Per-ship status
        {
            _x params ["_manifest", "_shipObj"];
            private _state = if (count _x > 2) then { _x select 2 } else { createHashMap };
            if (isNil "_state" || {typeName _state != "HASHMAP"}) then { _state = createHashMap };
            
            private _shipStatus = _state getOrDefault ["status", "pending"];
            private _currentItem = _state getOrDefault ["currentItem", ""];
            private _unloaded = _state getOrDefault ["unloadedCount", 0];
            private _total = _state getOrDefault ["totalItems", count _manifest];
            
            private _sLabel = switch (_shipStatus) do {
                case "sailing":   { "En Route" };
                case "unloading": { if (_currentItem != "") then { format ["Unloading %1 (%2/%3)", _currentItem, _unloaded + 1, _total] } else { "Unloading" } };
                case "waiting":   { format ["Waiting: %1", _currentItem] };
                case "returning": { "Returning" };
                case "arrived":   { "Returned" };
                default           { "Pending" };
            };
            
            if (isNull _shipObj && _shipStatus != "arrived") then { _sLabel = "SUNK" };
            
            private _sColor = switch (_shipStatus) do {
                case "sailing":   { "#80CCFF" };
                case "unloading": { "#FFD966" };
                case "waiting":   { "#FF8844" };
                case "returning": { "#8888CC" };
                case "arrived":   { "#80FF80" };
                default           { "#888888" };
            };
            if (isNull _shipObj && _shipStatus != "arrived") then { _sColor = "#FF6666" };
            
            _text = _text + format ["<t size='0.8' color='%1'>    Ship %2: %3</t><br/>", _sColor, _forEachIndex + 1, _sLabel];
        } forEach _ships;
        
        _text = _text + "<br/>";
    } forEach OpsRoom_ActiveConvoys;
    
    _convoysCtrl ctrlSetStructuredText parseText _text;
};
