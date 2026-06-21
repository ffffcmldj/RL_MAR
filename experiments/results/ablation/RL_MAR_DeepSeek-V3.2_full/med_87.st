FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL; (* Input for starting the desalination process *)
    StopButton : BOOL; (* Input for stopping the desalination process *)
    SalinitySensor : REAL; (* Input for salinity level measurement *)
END_VAR

VAR_OUTPUT
    SeawaterInletValve : BOOL; (* Output for seawater inlet valve control *)
    FreshwaterOutletValve : BOOL; (* Output for freshwater outlet valve control *)
    DesalinationInProgress : BOOL; (* Indicator for an ongoing desalination process *)
END_VAR

VAR
    MaxSalinity : REAL := 35.0; (* Maximum allowable salinity in ppm for freshwater *)
    SalinityControlSeconds : INT := 0; (* Timer for salinity control in seconds *)
END_VAR

(* Main logic body begins here *)
IF StartButton AND NOT DesalinationInProgress THEN
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
    DesalinationInProgress := TRUE;
    SalinityControlSeconds := 0;
ELSIF StopButton THEN
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    DesalinationInProgress := FALSE;
    SalinityControlSeconds := 0;
END_IF;

IF DesalinationInProgress THEN
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
END_FUNCTION_BLOCK;