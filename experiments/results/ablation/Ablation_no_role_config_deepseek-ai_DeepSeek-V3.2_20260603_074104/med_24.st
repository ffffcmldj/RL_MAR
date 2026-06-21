FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT; (* Time in milliseconds since last cycle *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
    TimeOpen : DINT := 0; (* Accumulated time door has been open *)
    PreviousSensor : BOOL := FALSE; (* Edge detection for sensor *)
END_VAR

(* Main control logic *)
IF ProximitySensor AND NOT DoorOpen THEN
    (* Open door when sensor activates and door is closed *)
    DoorOpen := TRUE;
    TimeOpen := 0; (* Reset timer *)
ELSIF DoorOpen THEN
    (* Door is currently open *)
    IF ProximitySensor THEN
        (* Sensor still active - keep door open and reset timer *)
        TimeOpen := 0;
    ELSE
        (* Sensor inactive - increment timer *)
        TimeOpen := TimeOpen + ElapsedTime;
        
        (* Close door if timer exceeds duration *)
        IF TimeOpen >= DoorOpenDuration THEN
            DoorOpen := FALSE;
            TimeOpen := 0; (* Reset for next cycle *)
        END_IF;
    END_IF;
END_IF;

(* Store current sensor state for next cycle *)
PreviousSensor := ProximitySensor;

END_FUNCTION_BLOCK