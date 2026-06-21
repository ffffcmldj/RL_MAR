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

// Control Logic Implementation
IF InFlow < LowInFlow THEN
    Pump1 := TRUE; // Turn on Pump1
ELSE
    Pump1 := FALSE; // Turn off Pump1
END_IF;

IF OutFlow > HighOutFlow THEN
    Pump2 := TRUE; // Turn on Pump2
ELSE
    Pump2 := FALSE; // Turn off Pump2
END_IF;

IF pH < DesiredPH THEN
    Valve1 := TRUE; // Open Valve1
ELSE
    Valve1 := FALSE; // Close Valve1
END_IF;

IF TankLvl > HighTankLvl THEN
    Valve2 := TRUE; // Open Valve2
ELSE
    Valve2 := FALSE; // Close Valve2
END_IF;

END_FUNCTION_BLOCK