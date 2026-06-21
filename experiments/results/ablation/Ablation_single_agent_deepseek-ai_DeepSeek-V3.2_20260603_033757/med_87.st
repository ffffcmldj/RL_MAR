FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;          (* Input for starting the desalination process *)
    StopButton : BOOL;           (* Input for stopping the desalination process *)
    SalinitySensor : REAL;       (* Input for salinity level measurement *)
END_VAR
VAR_OUTPUT
    SeawaterInletValve : BOOL;   (* Output for seawater inlet valve control *)
    FreshwaterOutletValve : BOOL; (* Output for freshwater outlet valve control *)
    DesalinationInProgress : BOOL; (* Indicator for an ongoing desalination process *)
END_VAR
VAR
    MaxSalinity : REAL := 35.0;  (* Maximum allowable salinity in ppm for freshwater *)
    SalinityControlSeconds : INT := 0; (* Timer for salinity control in seconds *)
END_VAR

(* Main logic *)
IF StopButton THEN
    (* Stop process immediately when StopButton is pressed *)
    DesalinationInProgress := FALSE;
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    SalinityControlSeconds := 0;
ELSIF StartButton AND NOT DesalinationInProgress THEN
    (* Start process when StartButton is pressed and process is not already running *)
    DesalinationInProgress := TRUE;
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
    SalinityControlSeconds := 0;
END_IF;

(* Salinity monitoring and control *)
IF DesalinationInProgress THEN
    (* Increment timer each scan cycle - assuming 1 second per cycle *)
    SalinityControlSeconds := SalinityControlSeconds + 1;
    
    (* Check salinity every 10 seconds *)
    IF SalinityControlSeconds >= 10 THEN
        IF SalinitySensor > MaxSalinity THEN
            (* Close freshwater outlet valve if salinity is too high *)
            FreshwaterOutletValve := FALSE;
        ELSE
            (* Keep freshwater outlet valve open if salinity is acceptable *)
            FreshwaterOutletValve := TRUE;
        END_IF;
        (* Reset timer after check *)
        SalinityControlSeconds := 0;
    END_IF;
END_IF;

END_FUNCTION_BLOCK