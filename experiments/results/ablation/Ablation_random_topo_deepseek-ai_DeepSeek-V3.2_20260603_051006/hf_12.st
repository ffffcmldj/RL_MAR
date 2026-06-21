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

(* Emergency stop logic - highest priority *)
IF NOT estop THEN
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
    autoActive := FALSE;
    autoStep := 0;
ELSE
    (* Manual mode *)
    IF NOT opeMode THEN
        (* Valve A toggle control *)
        IF valveAStart AND NOT previousValveAStart THEN
            valveARun := NOT valveARun;
        END_IF;
        previousValveAStart := valveAStart;
        
        (* Valve B toggle control *)
        IF valveBStart AND NOT previousValveBStart THEN
            valveBRun := NOT valveBRun;
        END_IF;
        previousValveBStart := valveBStart;
        
        (* Valve C toggle control *)
        IF valveCStart AND NOT previousValveCStart THEN
            valveCRun := NOT valveCRun;
        END_IF;
        previousValveCStart := valveCStart;
        
        (* Valve D toggle control *)
        IF valveDStart AND NOT previousValveDStart THEN
            valveDRun := NOT valveDRun;
        END_IF;
        previousValveDStart := valveDStart;
        
        (* Mixing motor toggle control *)
        IF mixMotorStart AND NOT previousMixMotorStart THEN
            mixMotorRun := NOT mixMotorRun;
        END_IF;
        previousMixMotorStart := mixMotorStart;
        
        (* Reset automatic mode variables in manual mode *)
        autoActive := FALSE;
        autoStep := 0;
        
    (* Automatic mode *)
    ELSE
        (* Auto start button handling - toggle functionality *)
        IF autoStart AND NOT previousAutoStart THEN
            autoActive := NOT autoActive;
            IF autoActive THEN
                autoStep := 1;
            ELSE
                autoStep := 0;
            END_IF;
        END_IF;
        previousAutoStart := autoStart;
        
        (* Automatic process sequence *)
        IF autoActive THEN
            CASE autoStep OF
                1: (* Step 1: Open valve A *)
                    valveARun := TRUE;
                    valveBRun := FALSE;
                    valveCRun := FALSE;
                    valveDRun := FALSE;
                    mixMotorRun := FALSE;
                    
                    IF levelSensor >= 50 THEN
                        valveARun := FALSE;
                        autoStep := 2;
                    END_IF;
                    
                2: (* Step 2: Open valve B *)
                    valveBRun := TRUE;
                    
                    IF levelSensor >= 80 THEN
                        valveBRun := FALSE;
                        autoStep := 3;
                    END_IF;
                    
                3: (* Step 3: Process mode decision *)
                    IF NOT processMode THEN
                        (* Process mode false: Start mixing motor *)
                        mixMotorRun := TRUE;
                        
                        IF mixMotorComplete THEN
                            mixMotorRun := FALSE;
                            autoStep := 4;
                        END_IF;
                    ELSE
                        (* Process mode true: Open valve C *)
                        valveCRun := TRUE;
                        
                        IF levelSensor >= 100 THEN
                            valveCRun := FALSE;
                            autoStep := 4;
                        END_IF;
                    END_IF;
                    
                4: (* Step 4: Handle mixing for process mode true *)
                    IF processMode THEN
                        mixMotorRun := TRUE;
                        
                        IF mixMotorComplete THEN
                            mixMotorRun := FALSE;
                            autoStep := 5;
                        END_IF;
                    ELSE
                        autoStep := 5;
                    END_IF;
                    
                5: (* Step 5: Open valve D and end process *)
                    valveDRun := TRUE;
                    autoActive := FALSE;
                    autoStep := 0;
                    
            END_CASE;
        ELSE
            (* Auto not active - ensure all outputs are off *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK