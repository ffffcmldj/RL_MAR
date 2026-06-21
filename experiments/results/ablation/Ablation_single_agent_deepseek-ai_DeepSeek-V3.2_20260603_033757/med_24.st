FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT; (* milliseconds since door was last opened *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
    eState : (stDoorClosed, stDoorOpen, stDoorClosing);
END_VAR

(* Main state machine logic *)
CASE eState OF
    stDoorClosed:
        DoorOpen := FALSE;
        IF ProximitySensor THEN
            eState := stDoorOpen;
        END_IF;
    
    stDoorOpen:
        DoorOpen := TRUE;
        IF NOT ProximitySensor AND (ElapsedTime >= DoorOpenDuration) THEN
            eState := stDoorClosing;
        END_IF;
    
    stDoorClosing:
        DoorOpen := FALSE;
        IF NOT ProximitySensor THEN
            eState := stDoorClosed;
        ELSIF ProximitySensor THEN
            eState := stDoorOpen;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK