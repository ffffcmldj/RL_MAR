ructured-text
FUNCTION_BLOCK FB_BottleProcessing

VAR_INPUT 
    bottleSensor : BOOL; // Detects presence of bottle
    cleaningConfirmButton : BOOL; // Confirms cleaning stage completion
    fillingConfirmButton : BOOL; // Confirms filling stage completion
    cappingConfirmButton : BOOL; // Confirms capping stage completion
    packingConfirmButton : BOOL; // Confirms packing stage completion
    finishedButton : BOOL; // Confirms process completion
END_VAR

VAR_OUTPUT 
    Pump_Motor : BOOL; // Controls cleaning pump
    Filling_Valve : BOOL; // Controls filling mechanism
    Capping_Machine : BOOL; // Controls bottle capping
    Packing_Machine : BOOL; // Controls packing system
    Completion_Light : BOOL; // Indicates process completion
END_VAR

VAR 
    State : INT := 0; // 0: Waiting, 1: Cleaning, 2: Filling, 3: Capping, 4: Packing, 5: Completed
END_VAR

CASE State OF
    0: (* Waiting *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        IF bottleSensor THEN
            Pump_Motor := TRUE;
            State := 1;
        END_IF;

    1: (* Cleaning *)
        Pump_Motor := TRUE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        IF cleaningConfirmButton THEN
            Pump_Motor := FALSE;
            Filling_Valve := TRUE;
            State := 2;
        END_IF;

    2: (* Filling *)
        Pump_Motor := FALSE;
        Filling_Valve := TRUE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        IF fillingConfirmButton THEN
            Filling_Valve := FALSE;
            Capping_Machine := TRUE;
            State := 3;
        END_IF;

    3: (* Capping *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := TRUE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        IF cappingConfirmButton THEN
            Capping_Machine := FALSE;
            Packing_Machine := TRUE;
            State := 4;
        END_IF;

    4: (* Packing *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := TRUE;
        Completion_Light := FALSE;
        IF packingConfirmButton THEN
            Packing_Machine := FALSE;
            Completion_Light := TRUE;
            State := 5;
        END_IF;

    5: (* Completed *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := TRUE;
        IF finishedButton THEN
            Completion_Light := FALSE;
            State := 0;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK