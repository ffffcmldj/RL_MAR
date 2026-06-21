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

// Control logic implementation
Pump1 := (InFlow < LowInFlow);
Pump2 := (OutFlow > HighOutFlow);
Valve1 := (pH < DesiredPH);
Valve2 := (TankLvl > HighTankLvl);

END_FUNCTION_BLOCK