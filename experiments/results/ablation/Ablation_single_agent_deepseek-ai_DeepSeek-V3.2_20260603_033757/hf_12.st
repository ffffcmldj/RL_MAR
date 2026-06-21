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
    (* Edge detection variables for manual mode *)
    prevValveAStart : BOOL := FALSE;
    prevValveBStart : BOOL := FALSE;
    prevValveCStart : BOOL := FALSE;
    prevValveDStart : BOOL := FALSE;
    prevMixMotorStart : BOOL := FALSE;
    prevAutoStart : BOOL := FALSE;
    
    (* Automatic mode state variables *)
    autoActive : BOOL := FALSE;
    autoStep : INT := 0;
END_VAR

(* Emergency stop logic - highest priority *)
IF NOT estop THEN
    (* Emergency stop triggered - stop all equipment *)
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
    autoActive := FALSE;
    autoStep := 0;
ELSE
    (* Normal operation *)
    IF opeMode THEN
        (* Automatic Mode *)
        
        (* Toggle automatic process on rising edge of autoStart *)
        IF autoStart AND NOT prevAutoStart THEN
            autoActive := NOT autoActive;
            IF autoActive THEN
                autoStep := 1; (* Start with step 1: open valve A *)
            ELSE
                autoStep := 0; (* Reset to idle *)
            END_IF;
        END_IF;
        prevAutoStart := autoStart;
        
        (* Automatic process state machine *)
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
                        autoStep := 2; (* Move to step 2: open valve B *)
                    END_IF;
                    
                2: (* Step 2: Open valve B *)
                    valveBRun := TRUE;
                    
                    IF levelSensor >= 80 THEN
                        valveBRun := FALSE;
                        IF processMode THEN
                            autoStep := 3; (* ProcessMode = TRUE: go to step 3 *)
                        ELSE
                            autoStep := 4; (* ProcessMode = FALSE: skip to step 4 *)
                        END_IF;
                    END_IF;
                    
                3: (* Step 3: Open valve C (only when processMode = TRUE) *)
                    valveCRun := TRUE;
                    
                    IF levelSensor >= 100 THEN
                        valveCRun := FALSE;
                        autoStep := 4; (* Move to step 4: start mixing *)
                    END_IF;
                    
                4: (* Step 4: Start mixing motor *)
                    mixMotorRun := TRUE;
                    
                    IF mixMotorComplete THEN
                        mixMotorRun := FALSE;
                        autoStep := 5; (* Move to step 5: open valve D *)
                    END_IF;
                    
                5: (* Step 5: Open valve D and end process *)
                    valveDRun := TRUE;
                    autoActive := FALSE; (* Process complete *)
                    autoStep := 0; (* Reset state machine *)
                    
            END_CASE;
        ELSE
            (* Automatic mode inactive - ensure all outputs are off *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
        END_IF;
        
    ELSE
        (* Manual Mode *)
        
        (* Valve A toggle on rising edge *)
        IF valveAStart AND NOT prevValveAStart THEN
            valveARun := NOT valveARun;
        END_IF;
        prevValveAStart := valveAStart;
        
        (* Valve B toggle on rising edge *)
        IF valveBStart AND NOT prevValveBStart THEN
            valveBRun := NOT valveBRun;
        END_IF;
        prevValveBStart := valveBStart;
        
        (* Valve C toggle on rising edge *)
        IF valveCStart AND NOT prevValveCStart THEN
            valveCRun := NOT valveCRun;
        END_IF;
        prevValveCStart := valveCStart;
        
        (* Valve D toggle on rising edge *)
        IF valveDStart AND NOT prevValveDStart THEN
            valveDRun := NOT valveDRun;
        END_IF;
        prevValveDStart := valveDStart;
        
        (* Mixing motor toggle on rising edge *)
        IF mixMotorStart AND NOT prevMixMotorStart THEN
            mixMotorRun := NOT mixMotorRun;
        END_IF;
        prevMixMotorStart := mixMotorStart;
        
    END_IF;
END_IF;

END_FUNCTION_BLOCK