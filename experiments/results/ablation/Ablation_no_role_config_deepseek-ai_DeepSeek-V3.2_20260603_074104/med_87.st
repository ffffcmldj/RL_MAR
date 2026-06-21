FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;           (* Input for starting the desalination process *)
    StopButton : BOOL;            (* Input for stopping the desalination process *)
    SalinitySensor : REAL;        (* Input for salinity level measurement *)
END_VAR
VAR_OUTPUT
    SeawaterInletValve : BOOL;    (* Output for seawater inlet valve control *)
    FreshwaterOutletValve : BOOL; (* Output for freshwater outlet valve control *)
    DesalinationInProgress : BOOL;(* Indicator for an ongoing desalination process *)
END_VAR
VAR
    MaxSalinity : REAL := 35.0;   (* Maximum allowable salinity in ppm for freshwater *)
    SalinityControlSeconds : INT := 0; (* Timer for salinity control in seconds *)
END_VAR

(* Start/Stop Control Logic *)
IF StopButton THEN
    (* Immediate stop when StopButton is pressed *)
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    DesalinationInProgress := FALSE;
    SalinityControlSeconds := 0;
ELSIF StartButton AND NOT DesalinationInProgress THEN
    (* Start process when StartButton is pressed and process isn't already running *)
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
    DesalinationInProgress := TRUE;
END_IF;

(* Salinity Monitoring and Control Logic *)
IF DesalinationInProgress THEN
    (* Increment timer each cycle (assuming 1 second cycle time) *)
    SalinityControlSeconds := SalinityControlSeconds + 1;
    
    (* Check salinity every 10 seconds *)
    IF SalinityControlSeconds >= 10 THEN
        IF SalinitySensor > MaxSalinity THEN
            (* Close freshwater valve if salinity is too high *)
            FreshwaterOutletValve := FALSE;
        ELSE
            (* Keep freshwater valve open if salinity is acceptable *)
            FreshwaterOutletValve := TRUE;
        END_IF;
        (* Reset timer after check *)
        SalinityControlSeconds := 0;
    END_IF;
END_IF;

END_FUNCTION_BLOCK