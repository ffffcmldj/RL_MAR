FUNCTION_BLOCK AutomaticDoorControl
    VAR_INPUT
        ProximitySensor : BOOL;
        ElapsedTime : DINT; (* Changed from TIME to DINT, representing milliseconds *)
    END_VAR

    VAR_OUTPUT
        DoorOpen : BOOL;
    END_VAR

    VAR
        DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
    END_VAR

    // Initialization
    IF NOT DoorOpen THEN
        DoorOpen := FALSE; // Ensure the door is closed at the start
    END_IF;

    // Door Control Logic
    IF ProximitySensor THEN
        // Proximity sensor is activated
        IF NOT DoorOpen THEN
            // Door is currently closed, open the door
            DoorOpen := TRUE;
        END_IF;
    ELSE
        // Proximity sensor is deactivated
        IF DoorOpen THEN
            // Check if the elapsed time exceeds the open duration
            IF ElapsedTime >= DoorOpenDuration THEN
                // Close the door
                DoorOpen := FALSE;
            END_IF;
        END_IF;
    END_IF;

END_FUNCTION_BLOCK