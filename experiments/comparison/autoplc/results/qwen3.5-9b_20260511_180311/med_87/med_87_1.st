FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    SalinitySensor : REAL;
END_VAR
VAR_OUTPUT
    SeawaterInletValve : BOOL;
    FreshwaterOutletValve : BOOL;
    DesalinationInProgress : BOOL;
END_VAR
VAR
    MaxSalinity : REAL := 35.0;
    SalinityControlSeconds : INT := 0;
    PreviousDesalinationInProgress : BOOL;
END_VAR

PreviousDesalinationInProgress := DesalinationInProgress;

IF StartButton = TRUE AND DesalinationInProgress = FALSE THEN
    DesalinationInProgress := TRUE;
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
ELSIF StopButton = TRUE THEN
    DesalinationInProgress := FALSE;
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    SalinityControlSeconds := 0;
ELSE
    IF DesalinationInProgress = TRUE THEN
        SalinityControlSeconds := SalinityControlSeconds + 1;
        
        IF SalinityControlSeconds >= 10 THEN
            IF SalinitySensor > MaxSalinity THEN
                FreshwaterOutletValve := FALSE;
            ELSE
                FreshwaterOutletValve := TRUE;
            END_IF;
            SalinityControlSeconds := 0;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK