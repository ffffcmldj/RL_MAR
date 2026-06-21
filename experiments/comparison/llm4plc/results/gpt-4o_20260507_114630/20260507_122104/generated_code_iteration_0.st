plaintext
START_ST
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
    state : INT := 0; (* Current state of the finite state machine *)
    prevState : INT := -1; (* Previous state of the finite state machine *)
    SalinityControlTimer : INT := 0; (* Timer to track the 10-second interval for salinity monitoring *)
    MaxSalinity : REAL := 35.0; (* Maximum allowable salinity in ppm for freshwater *)
END_VAR

(* State Machine Logic *)
CASE state OF
    (* STATE 0: IDLE *)
    0: 
        SeawaterInletValve := FALSE;
        FreshwaterOutletValve := FALSE;
        DesalinationInProgress := FALSE;

        (* Transition to STATE 1 if StartButton is pressed and desalination is not in progress *)
        IF StartButton = TRUE AND DesalinationInProgress = FALSE THEN
            state := 1;
        END_IF;

    (* STATE 1: START_DESALINATION *)
    1: 
        SeawaterInletValve := TRUE;
        FreshwaterOutletValve := TRUE;
        DesalinationInProgress := TRUE;

        (* Automatically transition to STATE 2 *)
        state := 2;

    (* STATE 2: MONITOR_SALINITY *)
    2: 
        SeawaterInletValve := TRUE;

        (* Increment the timer for salinity monitoring *)
        SalinityControlTimer := SalinityControlTimer + 1;

        (* Check salinity every 10 seconds *)
        IF SalinityControlTimer >= 10 THEN
            IF SalinitySensor > MaxSalinity THEN
                FreshwaterOutletValve := FALSE; (* Close the valve if salinity is too high *)
            ELSE
                FreshwaterOutletValve := TRUE; (* Keep the valve open if salinity is acceptable *)
            END_IF;
            SalinityControlTimer := 0; (* Reset the timer *)
        END_IF;

        (* Transition to STATE 3 if StopButton is pressed *)
        IF StopButton = TRUE THEN
            state := 3;
        END_IF;

    (* STATE 3: STOP_DESALINATION *)
    3: 
        SeawaterInletValve := FALSE;
        FreshwaterOutletValve := FALSE;
        DesalinationInProgress := FALSE;
        SalinityControlTimer := 0; (* Reset the timer *)

        (* Automatically transition to STATE 0 *)
        state := 0;

END_CASE;
END_FUNCTION_BLOCK
END_ST