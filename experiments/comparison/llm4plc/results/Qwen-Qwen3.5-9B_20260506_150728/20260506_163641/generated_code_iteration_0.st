START_ST
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
    pump1State : BOOL := FALSE;
    pump2State : BOOL := FALSE;
    valve1State : BOOL := FALSE;
    valve2State : BOOL := FALSE;
END_VAR

END_FUNCTION_BLOCK
END_ST