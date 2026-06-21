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
    Pump_Motor : BOOL;
    Filling_Valve : BOOL;
    Capping_Machine : BOOL;
    Packing_Machine : BOOL;
    Completion_Light : BOOL;
END_VAR

VAR
    State : INT := 0;
END_VAR

CASE State OF
    0:
        IF bottleSensor THEN
            Pump_Motor := TRUE;
            State := 1;
        END_IF;
        
    1:
        IF cleaningConfirmButton THEN
            Pump_Motor := FALSE;
            Filling_Valve := TRUE;
            State := 2;
        END_IF;
        
    2:
        IF fillingConfirmButton THEN
            Filling_Valve := FALSE;
            Capping_Machine := TRUE;
            State := 3;
        END_IF;
        
    3:
        IF cappingConfirmButton THEN
            Capping_Machine := FALSE;
            Packing_Machine := TRUE;
            State := 4;
        END_IF;
        
    4:
        IF packingConfirmButton THEN
            Packing_Machine := FALSE;
            Completion_Light := TRUE;
            State := 5;
        END_IF;
        
    5:
        IF finishedButton THEN
            Completion_Light := FALSE;
            Pump_Motor := FALSE;
            Filling_Valve := FALSE;
            Capping_Machine := FALSE;
            Packing_Machine := FALSE;
            State := 0;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK