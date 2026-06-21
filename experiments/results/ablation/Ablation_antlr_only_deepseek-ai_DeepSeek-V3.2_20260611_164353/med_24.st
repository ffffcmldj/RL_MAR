FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT; (* Time since last door opening in milliseconds *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
    tonDoorTimer : TON; (* Standard on-delay timer *)
    bDoorOpeningRequested : BOOL; (* Internal flag for door opening request *)
END_VAR

(* Timer configuration: Runs when door opening is requested *)
tonDoorTimer(
    IN := bDoorOpeningRequested,
    PT := DINT_TO_TIME(DoorOpenDuration)
);

(* Main control logic *)
IF ProximitySensor AND NOT DoorOpen THEN
    (* Request to open door when sensor active and door is closed *)
    DoorOpen := TRUE;
    bDoorOpeningRequested := TRUE;
END_IF;

IF DoorOpen THEN
    (* Door is currently open *)
    IF ProximitySensor THEN
        (* Sensor still active - keep door open and reset timer *)
        bDoorOpeningRequested := TRUE;
    ELSIF NOT bDoorOpeningRequested OR tonDoorTimer.Q THEN
        (* Close door if: 
           1. Opening request was cancelled (sensor inactive), OR
           2. Timer has expired (5 seconds elapsed) *)
        DoorOpen := FALSE;
    END_IF;
END_IF;

(* Reset opening request when door closes *)
IF NOT DoorOpen THEN
    bDoorOpeningRequested := FALSE;
END_IF;

END_FUNCTION_BLOCK