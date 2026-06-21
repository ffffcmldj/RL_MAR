FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;        (* Input for starting the desalination process *)
    StopButton : BOOL;         (* Input for stopping the desalination process *)
    SalinitySensor : REAL;     (* Input for salinity level measurement *)
END_VAR

VAR_OUTPUT
    SeawaterInletValve : BOOL;         (* Output for seawater inlet valve control *)
    FreshwaterOutletValve : BOOL;      (* Output for freshwater outlet valve control *)
    DesalinationInProgress : BOOL;     (* Indicator for an ongoing desalination process *)
END_VAR

VAR
    MaxSalinity : REAL := 35.0;        (* Maximum allowable salinity in ppm for freshwater *)
    SalinityControlSeconds : INT := 0; (* Timer for salinity control in seconds *)
    SalinityTimer : TON;               (* IEC 61131-3 timer for 10-second intervals *)
END_VAR

(* Salinity Timer Execution *)
SalinityTimer(IN := DesalinationInProgress, PT := T#10S);

(* Process Start/Stop Control *)
IF StopButton THEN
    DesalinationInProgress := FALSE;
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    SalinityControlSeconds := 0;
ELSIF StartButton AND NOT DesalinationInProgress THEN
    DesalinationInProgress := TRUE;
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
END_IF;

(* Salinity Monitoring and Control *)
IF SalinityTimer.Q THEN
    SalinityControlSeconds := SalinityControlSeconds + 10;
    
    IF DesalinationInProgress THEN
        IF SalinitySensor > MaxSalinity THEN
            FreshwaterOutletValve := FALSE;
        ELSE
            FreshwaterOutletValve := TRUE;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK