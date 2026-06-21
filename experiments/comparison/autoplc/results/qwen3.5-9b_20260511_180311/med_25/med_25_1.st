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

Pump1 := FALSE;
Pump2 := FALSE;
Valve1 := FALSE;
Valve2 := FALSE;

IF InFlow < LowInFlow THEN
    Pump1 := TRUE;
END_IF;

IF OutFlow > HighOutFlow THEN
    Pump2 := TRUE;
END_IF;

IF pH < DesiredPH THEN
    Valve1 := TRUE;
END_IF;

IF TankLvl > HighTankLvl THEN
    Valve2 := TRUE;
END_IF;

END_FUNCTION_BLOCK