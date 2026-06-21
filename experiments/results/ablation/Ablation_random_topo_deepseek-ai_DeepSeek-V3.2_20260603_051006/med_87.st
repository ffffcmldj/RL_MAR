FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;          (* Input for starting the desalination process *)
    StopButton : BOOL;           (* Input for stopping the desalination process *)
    SalinitySensor : REAL;       (* Input for salinity level measurement *)
END_VAR

VAR_OUTPUT
    SeawaterInletValve : BOOL;       (* Output for seawater inlet valve control *)
    FreshwaterOutletValve : BOOL;    (* Output for freshwater outlet valve control *)
    DesalinationInProgress : BOOL;   (* Indicator for an ongoing desalination process *)
END_VAR

VAR
    MaxSalinity : REAL := 35.0;          (* Maximum allowable salinity in ppm for freshwater *)
    SalinityControlSeconds : INT := 0;   (* Timer for salinity control in seconds *)
    SalinityCheckTimer : TON;            (* Timer for 10-second salinity checks *)
    StartButtonRisingEdge : R_TRIG;      (* Rising edge detector for StartButton *)
    StopButtonRisingEdge : R_TRIG;       (* Rising edge detector for StopButton *)
    SalinityExceeded : BOOL := FALSE;    (* Flag indicating salinity exceeds maximum *)
END_VAR

(* Edge detection for buttons *)
StartButtonRisingEdge(CLK := StartButton);
StopButtonRisingEdge(CLK := StopButton);

(* Main process logic *)
IF StopButton THEN
    (* Immediate stop when StopButton is pressed *)
    DesalinationInProgress := FALSE;
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    SalinityControlSeconds := 0;
    SalinityCheckTimer(IN := FALSE, PT := T#10S);
    SalinityExceeded := FALSE;
ELSIF StartButtonRisingEdge.Q AND NOT DesalinationInProgress THEN
    (* Start process when StartButton is pressed and process is not already in progress *)
    DesalinationInProgress := TRUE;
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
    SalinityControlSeconds := 0;
    SalinityCheckTimer(IN := TRUE, PT := T#10S);
    SalinityExceeded := FALSE;
ELSIF DesalinationInProgress THEN
    (* Process is active - handle salinity monitoring *)
    SeawaterInletValve := TRUE;
    
    (* 10-second salinity check timer *)
    SalinityCheckTimer(IN := TRUE, PT := T#10S);
    
    IF SalinityCheckTimer.Q THEN
        (* Timer elapsed - perform salinity check *)
        SalinityControlSeconds := SalinityControlSeconds + 10;
        SalinityCheckTimer(IN := FALSE, PT := T#10S);
        
        (* Check salinity against maximum *)
        IF SalinitySensor > MaxSalinity THEN
            SalinityExceeded := TRUE;
            FreshwaterOutletValve := FALSE;  (* Close valve if salinity too high *)
        ELSE
            SalinityExceeded := FALSE;
            FreshwaterOutletValve := TRUE;   (* Keep valve open if salinity OK *)
        END_IF;
        
        (* Restart timer for next check *)
        SalinityCheckTimer(IN := TRUE, PT := T#10S);
    END_IF;
    
    (* Stop process on rising edge of StopButton *)
    IF StopButtonRisingEdge.Q THEN
        DesalinationInProgress := FALSE;
        SeawaterInletValve := FALSE;
        FreshwaterOutletValve := FALSE;
        SalinityControlSeconds := 0;
        SalinityCheckTimer(IN := FALSE, PT := T#10S);
        SalinityExceeded := FALSE;
    END_IF;
ELSE
    (* Process is idle *)
    DesalinationInProgress := FALSE;
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    SalinityCheckTimer(IN := FALSE, PT := T#10S);
END_IF;

END_FUNCTION_BLOCK