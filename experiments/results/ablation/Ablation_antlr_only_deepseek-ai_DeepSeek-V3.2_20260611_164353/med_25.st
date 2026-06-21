FUNCTION_BLOCK WastewaterControl
VAR_INPUT
    InFlow : REAL;
    OutFlow : REAL;
    pH : REAL;
    TankLvl : REAL;
END_VAR

VAR_OUTPUT
    Pump1 : BOOL;
    Pump2 : BOOL;
    Valve1 : BOOL;
    Valve2 : BOOL;
END_VAR

VAR
    LowInFlow : REAL := 100.0;
    HighOutFlow : REAL := 90.0;
    DesiredPH : REAL := 7.0;
    HighTankLvl : REAL := 80.0;
END_VAR

// Control logic for Pump1: ON when inlet flow is below threshold
Pump1 := InFlow < LowInFlow;

// Control logic for Pump2: ON when outlet flow is above threshold
Pump2 := OutFlow > HighOutFlow;

// Control logic for Valve1: OPEN when pH is below desired level
Valve1 := pH < DesiredPH;

// Control logic for Valve2: OPEN when tank level is above threshold
Valve2 := TankLvl > HighTankLvl;

END_FUNCTION_BLOCK