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
    SalinityCheckTimer : TON;          (* IEC timer for 10-second interval *)
END_VAR

(* Timer for 10-second salinity check interval *)
SalinityCheckTimer(
    IN := DesalinationInProgress,
    PT := T#10S
);

(* Process Start/Stop Control *)
IF StopButton THEN
    (* Emergency/Manual Stop: Close valves, reset process *)
    DesalinationInProgress := FALSE;
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    SalinityControlSeconds := 0;
ELSIF StartButton AND NOT DesalinationInProgress THEN
    (* Start Process: Open valves, set process active *)
    DesalinationInProgress := TRUE;
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
    SalinityControlSeconds := 0;
END_IF;

(* Salinity Monitoring and Control *)
IF DesalinationInProgress THEN
    (* Update timer display value (seconds) *)
    SalinityControlSeconds := TIME_TO_INT(SalinityCheckTimer.ET) / 1000;
    
    (* Check salinity every 10 seconds *)
    IF SalinityCheckTimer.Q THEN
        IF SalinitySensor > MaxSalinity THEN
            FreshwaterOutletValve := FALSE;    (* Close valve if salinity too high *)
        ELSE
            FreshwaterOutletValve := TRUE;     (* Keep valve open if salinity OK *)
        END_IF;
        
        (* Reset timer for next 10-second interval *)
        SalinityCheckTimer(IN := FALSE);
        SalinityCheckTimer(IN := TRUE);
    END_IF;
ELSE
    (* Process not active: Ensure valves are closed *)
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
END_IF;

END_FUNCTION_BLOCK