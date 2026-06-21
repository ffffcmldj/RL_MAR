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
        State : INT := 0; (* 0: Waiting, 1: Cleaning, 2: Filling, 3: Capping, 4: Packing, 5: Completed *)
    END_VAR

    CASE State OF
        0: (* Waiting *)
            IF bottleSensor THEN
                Pump_Motor := TRUE; (* Start cleaning pump *)
                State := 1; (* Transition to Cleaning *)
            END_IF;

        1: (* Cleaning *)
            IF cleaningConfirmButton THEN
                Pump_Motor := FALSE; (* Stop cleaning pump *)
                Filling_Valve := TRUE; (* Start filling mechanism *)
                State := 2; (* Transition to Filling *)
            END_IF;

        2: (* Filling *)
            IF fillingConfirmButton THEN
                Filling_Valve := FALSE; (* Stop filling mechanism *)
                Capping_Machine := TRUE; (* Start capping machine *)
                State := 3; (* Transition to Capping *)
            END_IF;

        3: (* Capping *)
            IF cappingConfirmButton THEN
                Capping_Machine := FALSE; (* Stop capping machine *)
                Packing_Machine := TRUE; (* Start packing machine *)
                State := 4; (* Transition to Packing *)
            END_IF;

        4: (* Packing *)
            IF packingConfirmButton THEN
                Packing_Machine := FALSE; (* Stop packing machine *)
                Completion_Light := TRUE; (* Turn on completion light *)
                State := 5; (* Transition to Completed *)
            END_IF;

        5: (* Completed *)
            IF finishedButton THEN
                Completion_Light := FALSE; (* Turn off completion light *)
                Pump_Motor := FALSE; (* Reset all outputs to FALSE *)
                Filling_Valve := FALSE;
                Capping_Machine := FALSE;
                Packing_Machine := FALSE;
                State := 0; (* Return to Waiting *)
            END_IF;
    END_CASE;
END_FUNCTION_BLOCK