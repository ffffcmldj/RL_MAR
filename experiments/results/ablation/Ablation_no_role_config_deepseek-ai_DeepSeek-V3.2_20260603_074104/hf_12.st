FUNCTION_BLOCK MaterialMixing
VAR_INPUT
    estop : BOOL; (* Emergency Stop Signal, FALSE: Emergency stop triggered, TRUE: No emergency stop triggered *)
    opeMode : BOOL; (* Operation Mode, FALSE: Manual Operation Mode, TRUE: Automatic Operation Mode *)
    valveAStart : BOOL; (* Valve A Start Button *)
    valveBStart : BOOL; (* Valve B Start Button *)
    valveCStart : BOOL; (* Valve C Start Button *)
    valveDStart : BOOL; (* Valve D Start Button *)
    mixMotorStart : BOOL; (* Mixing Motor Start Button *)
    autoStart : BOOL; (* Automatic Start Button *)
    processMode : BOOL; (* Process Mode *)
    levelSensor : INT; (* Liquid Level Sensor, unit cm *)
    mixMotorComplete : BOOL; (* Mixing Complete Signal *)
END_VAR
VAR_OUTPUT
    valveARun : BOOL; (* Valve A Run Command *)
    valveBRun : BOOL; (* Valve B Run Command *)
    valveCRun : BOOL; (* Valve C Run Command *)
    valveDRun : BOOL; (* Valve D Run Command *)
    mixMotorRun : BOOL; (* Mixing Motor Run Command *)
END_VAR
VAR
    previousValveAStart : BOOL := FALSE;
    previousValveBStart : BOOL := FALSE;
    previousValveCStart : BOOL := FALSE;
    previousValveDStart : BOOL := FALSE;
    previousMixMotorStart : BOOL := FALSE;
    previousAutoStart : BOOL := FALSE;
    autoActive : BOOL := FALSE;
    autoStep : INT := 0;
END_VAR

(* Emergency stop has highest priority - when estop is FALSE, stop all equipment *)
IF NOT estop THEN
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
    autoActive := FALSE;
    autoStep := 0;
ELSE
    (* Automatic Operation Mode *)
    IF opeMode THEN
        (* Manual valve control is disabled in automatic mode *)
        (* Start automatic sequence on rising edge of autoStart button *)
        IF NOT previousAutoStart AND autoStart THEN
            autoActive := TRUE;
            autoStep := 1;
        END_IF;
        
        (* Execute automatic sequence *)
        IF autoActive THEN
            CASE autoStep OF
                1: (* Step 1: Open Valve A *)
                    valveARun := TRUE;
                    IF levelSensor >= 50 THEN
                        valveARun := FALSE;
                        autoStep := 2;
                    END_IF;
                    
                2: (* Step 2: Open Valve B *)
                    valveBRun := TRUE;
                    IF levelSensor >= 80 THEN
                        valveBRun := FALSE;
                        autoStep := 3;
                    END_IF;
                    
                3: (* Step 3: Check process mode *)
                    IF processMode THEN
                        autoStep := 4; (* Process Mode TRUE: Go to Valve C step *)
                    ELSE
                        autoStep := 5; (* Process Mode FALSE: Skip to mixing motor *)
                    END_IF;
                    
                4: (* Step 4: Open Valve C (only when processMode is TRUE) *)
                    valveCRun := TRUE;
                    IF levelSensor >= 100 THEN
                        valveCRun := FALSE;
                        autoStep := 5;
                    END_IF;
                    
                5: (* Step 5: Start mixing motor *)
                    mixMotorRun := TRUE;
                    IF mixMotorComplete THEN
                        mixMotorRun := FALSE;
                        autoStep := 6;
                    END_IF;
                    
                6: (* Step 6: Open Valve D to deliver mixture *)
                    valveDRun := TRUE;
                    (* Automatic process ends, reset for next cycle *)
                    autoActive := FALSE;
                    autoStep := 0;
            END_CASE;
        END_IF;
        
    (* Manual Operation Mode *)
    ELSE
        (* Toggle Valve A on rising edge of valveAStart button *)
        IF NOT previousValveAStart AND valveAStart THEN
            valveARun := NOT valveARun;
        END_IF;
        
        (* Toggle Valve B on rising edge of valveBStart button *)
        IF NOT previousValveBStart AND valveBStart THEN
            valveBRun := NOT valveBRun;
        END_IF;
        
        (* Toggle Valve C on rising edge of valveCStart button *)
        IF NOT previousValveCStart AND valveCStart THEN
            valveCRun := NOT valveCRun;
        END_IF;
        
        (* Toggle Valve D on rising edge of valveDStart button *)
        IF NOT previousValveDStart AND valveDStart THEN
            valveDRun := NOT valveDRun;
        END_IF;
        
        (* Toggle mixing motor on rising edge of mixMotorStart button *)
        IF NOT previousMixMotorStart AND mixMotorStart THEN
            mixMotorRun := NOT mixMotorRun;
        END_IF;
    END_IF;
END_IF;

(* Update previous states for edge detection *)
previousValveAStart := valveAStart;
previousValveBStart := valveBStart;
previousValveCStart := valveCStart;
previousValveDStart := valveDStart;
previousMixMotorStart := mixMotorStart;
previousAutoStart := autoStart;

END_FUNCTION_BLOCK