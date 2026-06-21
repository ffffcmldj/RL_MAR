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
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        
        IF bottleSensor THEN
            State := 1;
        END_IF;
    
    1:
        Pump_Motor := TRUE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        
        IF cleaningConfirmButton THEN
            State := 2;
        END_IF;
    
    2:
        Pump_Motor := FALSE;
        Filling_Valve := TRUE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        
        IF fillingConfirmButton THEN
            State := 3;
        END_IF;
    
    3:
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := TRUE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
        
        IF cappingConfirmButton THEN
            State := 4;
        END_IF;
    
    4:
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := TRUE;
        Completion_Light := FALSE;
        
        IF packingConfirmButton THEN
            State := 5;
        END_IF;
    
    5:
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := TRUE;
        
        IF finishedButton THEN
            State := 0;
        END_IF;
    
    ELSE
        State := 0;
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;
END_CASE;
END_FUNCTION_BLOCK