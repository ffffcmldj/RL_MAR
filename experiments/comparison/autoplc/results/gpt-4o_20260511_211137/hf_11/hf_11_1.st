FUNCTION_BLOCK FB_BottleProcessing
    VAR_INPUT 
        bottleSensor : BOOL;
        cleaningConfirmButton : BOOL;
        fillingConfirmButton : BOOL;
        cappingConfirmButton : BOOL;
        packingConfirmButton : BOOL;
        finishedButton : BOOL;
    END_VAR

    VAR_OUTPUT 
        Pump_Motor : BOOL := FALSE;
        Filling_Valve : BOOL := FALSE;
        Capping_Machine : BOOL := FALSE;
        Packing_Machine : BOOL := FALSE;
        Completion_Light : BOOL := FALSE;
    END_VAR

    VAR 
        State : INT := 0; // 0: Waiting, 1: Cleaning, 2: Filling, 3: Capping, 4: Packing, 5: Completed
    END_VAR

    // Sequential control logic for bottle processing
    CASE State OF
        0: // Waiting
            IF bottleSensor THEN
                Pump_Motor := TRUE;
                State := 1;
            END_IF;

        1: // Cleaning
            IF cleaningConfirmButton THEN
                Pump_Motor := FALSE;
                Filling_Valve := TRUE;
                State := 2;
            END_IF;

        2: // Filling
            IF fillingConfirmButton THEN
                Filling_Valve := FALSE;
                Capping_Machine := TRUE;
                State := 3;
            END_IF;

        3: // Capping
            IF cappingConfirmButton THEN
                Capping_Machine := FALSE;
                Packing_Machine := TRUE;
                State := 4;
            END_IF;

        4: // Packing
            IF packingConfirmButton THEN
                Packing_Machine := FALSE;
                Completion_Light := TRUE;
                State := 5;
            END_IF;

        5: // Completed
            IF finishedButton THEN
                Completion_Light := FALSE;
                // Reset all outputs to FALSE
                Pump_Motor := FALSE;
                Filling_Valve := FALSE;
                Capping_Machine := FALSE;
                Packing_Machine := FALSE;
                // Return to Waiting state
                State := 0;
            END_IF;
    END_CASE;
END_FUNCTION_BLOCK