plaintext
START_ST
FUNCTION_BLOCK FB_BottleProcessing
VAR_INPUT
    bottleSensor : BOOL; (* Detects presence of a bottle *)
    cleaningConfirmButton : BOOL; (* Confirms cleaning stage completion *)
    fillingConfirmButton : BOOL; (* Confirms filling stage completion *)
    cappingConfirmButton : BOOL; (* Confirms capping stage completion *)
    packingConfirmButton : BOOL; (* Confirms packing stage completion *)
    finishedButton : BOOL; (* Confirms process completion *)
END_VAR

VAR_OUTPUT
    Pump_Motor : BOOL; (* Controls cleaning pump *)
    Filling_Valve : BOOL; (* Controls filling mechanism *)
    Capping_Machine : BOOL; (* Controls bottle capping *)
    Packing_Machine : BOOL; (* Controls packing system *)
    Completion_Light : BOOL; (* Indicates process completion *)
END_VAR

VAR
    State : INT := 0; (* Tracks the current state of the FSM *)
END_VAR

(* State Machine Logic *)
CASE State OF
    0: (* Waiting for bottle *)
        (* Set outputs for this state *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* Transition to Cleaning state if bottle is detected *)
        IF bottleSensor THEN
            Pump_Motor := TRUE; (* Start cleaning pump *)
            State := 1; (* Move to Cleaning state *)
        END_IF;

    1: (* Cleaning *)
        (* Set outputs for this state *)
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* Wait for cleaning confirmation *)
        IF cleaningConfirmButton THEN
            Pump_Motor := FALSE; (* Stop cleaning pump *)
            Filling_Valve := TRUE; (* Start filling mechanism *)
            State := 2; (* Move to Filling state *)
        END_IF;

    2: (* Filling *)
        (* Set outputs for this state *)
        Pump_Motor := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* Wait for filling confirmation *)
        IF fillingConfirmButton THEN
            Filling_Valve := FALSE; (* Stop filling mechanism *)
            Capping_Machine := TRUE; (* Start capping machine *)
            State := 3; (* Move to Capping state *)
        END_IF;

    3: (* Capping *)
        (* Set outputs for this state *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* Wait for capping confirmation *)
        IF cappingConfirmButton THEN
            Capping_Machine := FALSE; (* Stop capping machine *)
            Packing_Machine := TRUE; (* Start packing system *)
            State := 4; (* Move to Packing state *)
        END_IF;

    4: (* Packing *)
        (* Set outputs for this state *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Completion_Light := FALSE;

        (* Wait for packing confirmation *)
        IF packingConfirmButton THEN
            Packing_Machine := FALSE; (* Stop packing system *)
            Completion_Light := TRUE; (* Turn on completion light *)
            State := 5; (* Move to Completed state *)
        END_IF;

    5: (* Completed *)
        (* Set outputs for this state *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;

        (* Wait for process reset *)
        IF finishedButton THEN
            Completion_Light := FALSE; (* Turn off completion light *)
            (* Reset all outputs *)
            Pump_Motor := FALSE;
            Filling_Valve := FALSE;
            Capping_Machine := FALSE;
            Packing_Machine := FALSE;
            (* Return to Waiting state *)
            State := 0;
        END_IF;

END_CASE;
END_FUNCTION_BLOCK
END_ST