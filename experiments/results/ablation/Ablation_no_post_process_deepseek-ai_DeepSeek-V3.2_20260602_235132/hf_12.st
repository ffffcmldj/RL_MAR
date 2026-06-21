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
    (* Edge detection for manual mode buttons *)
    previousValveAStart : BOOL := FALSE;
    previousValveBStart : BOOL := FALSE;
    previousValveCStart : BOOL := FALSE;
    previousValveDStart : BOOL := FALSE;
    previousMixMotorStart : BOOL := FALSE;
    previousAutoStart : BOOL := FALSE;
    
    (* Automatic process state variables *)
    autoProcessActive : BOOL := FALSE;
    autoStep : INT := 0;
    
    (* Safety level interlock constant *)
    MAX_SAFE_LEVEL : INT := 105;
END_VAR

(* --- Primary Safety Logic: Emergency Stop & Overfill Protection --- *)
IF NOT estop THEN
    (* Emergency Stop Active: De-energize all outputs and reset automatic process *)
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
    autoProcessActive := FALSE;
    autoStep := 0;
ELSE
    (* Emergency Stop NOT Active: Normal Operation *)
    
    (* Independent Safety Interlock: Prevent overfilling *)
    IF levelSensor >= MAX_SAFE_LEVEL THEN
        valveARun := FALSE;
        valveBRun := FALSE;
        valveCRun := FALSE;
    END_IF;
    
    (* --- Mode Selection --- *)
    IF opeMode THEN
        (* --- AUTOMATIC MODE --- *)
        
        (* Toggle automatic process on rising edge of autoStart *)
        IF autoStart AND NOT previousAutoStart THEN
            autoProcessActive := NOT autoProcessActive;
            IF autoProcessActive THEN
                autoStep := 1; (* Start sequence *)
            ELSE
                autoStep := 0; (* Abort sequence *)
            END_IF;
        END_IF;
        previousAutoStart := autoStart;
        
        (* Automatic Process Sequence *)
        IF autoProcessActive THEN
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
                    
                3: (* Step 3: Branch based on processMode *)
                    IF NOT processMode THEN
                        (* Path for processMode = FALSE: Start Mixing *)
                        mixMotorRun := TRUE;
                        IF mixMotorComplete THEN
                            mixMotorRun := FALSE;
                            autoStep := 5; (* Skip to Valve D *)
                        END_IF;
                    ELSE
                        (* Path for processMode = TRUE: Open Valve C *)
                        valveCRun := TRUE;
                        IF levelSensor >= 100 THEN
                            valveCRun := FALSE;
                            autoStep := 4;
                        END_IF;
                    END_IF;
                    
                4: (* Step 4: Mixing for processMode = TRUE path *)
                    mixMotorRun := TRUE;
                    IF mixMotorComplete THEN
                        mixMotorRun := FALSE;
                        autoStep := 5;
                    END_IF;
                    
                5: (* Step 5: Open Valve D and end sequence *)
                    valveDRun := TRUE;
                    autoProcessActive := FALSE;
                    autoStep := 0;
            END_CASE;
        ELSE
            (* Automatic process not active: ensure all outputs are off *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
        END_IF;
        
    ELSE
        (* --- MANUAL MODE --- *)
        
        (* Valve A: Toggle on rising edge *)
        IF valveAStart AND NOT previousValveAStart THEN
            valveARun := NOT valveARun;
        END_IF;
        previousValveAStart := valveAStart;
        
        (* Valve B: Toggle on rising edge *)
        IF valveBStart AND NOT previousValveBStart THEN
            valveBRun := NOT valveBRun;
        END_IF;
        previousValveBStart := valveBStart;
        
        (* Valve C: Toggle on rising edge *)
        IF valveCStart AND NOT previousValveCStart THEN
            valveCRun := NOT valveCRun;
        END_IF;
        previousValveCStart := valveCStart;
        
        (* Valve D: Toggle on rising edge *)
        IF valveDStart AND NOT previousValveDStart THEN
            valveDRun := NOT valveDRun;
        END_IF;
        previousValveDStart := valveDStart;
        
        (* Mixing Motor: Toggle on rising edge *)
        IF mixMotorStart AND NOT previousMixMotorStart THEN
            mixMotorRun := NOT mixMotorRun;
        END_IF;
        previousMixMotorStart := mixMotorStart;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;