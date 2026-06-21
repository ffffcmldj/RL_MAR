ructured-text
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
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
    SalinityControlSeconds : INT := 0; (* Timer for salinity control in seconds *)
    MaxSalinity : REAL := 35.0; (* Maximum allowable salinity in ppm for freshwater *)
END_VAR

(* Function Block Logic *)
IF state = 0 THEN (* STATE 0: INITIALIZE *)
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    DesalinationInProgress := FALSE;

    IF StartButton = TRUE AND DesalinationInProgress = FALSE THEN
        state := 1; (* Transition to STATE 1 *)
    END_IF

ELSIF state = 1 THEN (* STATE 1: DESALINATION IN PROGRESS *)
    SeawaterInletValve := TRUE;
    FreshwaterOutletValve := TRUE;
    DesalinationInProgress := TRUE;

    SalinityControlSeconds := SalinityControlSeconds + 1; (* Increment timer *)

    IF StopButton = TRUE THEN
        state := 0; (* Transition to STATE 0 *)
    ELSIF SalinityControlSeconds >= 10 THEN
        state := 2; (* Transition to STATE 2 after 10 seconds *)
        SalinityControlSeconds := 0; (* Reset timer *)
    END_IF

ELSIF state = 2 THEN (* STATE 2: SALINITY CHECK *)
    SeawaterInletValve := TRUE;
    IF SalinitySensor > MaxSalinity THEN
        FreshwaterOutletValve := FALSE; (* Close valve if salinity is too high *)
    ELSE
        FreshwaterOutletValve := TRUE; (* Keep valve open if salinity is acceptable *)
    END_IF

    state := 1; (* Transition back to STATE 1 *)
END_IF

END_FUNCTION_BLOCK