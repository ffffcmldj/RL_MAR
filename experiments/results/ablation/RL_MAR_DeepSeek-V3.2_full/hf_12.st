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
END_VAR

(* Emergency Stop has highest priority - override all other logic *)
IF NOT estop THEN
    (* Automatic Operation Mode *)
    IF opeMode THEN
        (* Rising edge detection for autoStart button *)
        IF autoStart AND NOT previousAutoStart THEN
            valveARun := TRUE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
        END_IF;
        
        (* Automatic sequence logic *)
        IF valveARun AND (levelSensor >= 50) THEN
            valveARun := FALSE;
            valveBRun := TRUE;
        END_IF;
        
        IF valveBRun AND (levelSensor >= 80) THEN
            valveBRun := FALSE;
            IF processMode THEN
                valveCRun := TRUE;
            ELSE
                mixMotorRun := TRUE;
            END_IF;
        END_IF;
        
        IF valveCRun AND (levelSensor >= 100) THEN
            valveCRun := FALSE;
            mixMotorRun := TRUE;
        END_IF;
        
        IF mixMotorRun AND mixMotorComplete THEN
            mixMotorRun := FALSE;
            valveDRun := TRUE;
        END_IF;
    (* Manual Operation Mode *)
    ELSE
        (* Toggle logic with rising edge detection for manual buttons *)
        IF valveAStart AND NOT previousValveAStart THEN
            valveARun := NOT valveARun;
        END_IF;
        
        IF valveBStart AND NOT previousValveBStart THEN
            valveBRun := NOT valveBRun;
        END_IF;
        
        IF valveCStart AND NOT previousValveCStart THEN
            valveCRun := NOT valveCRun;
        END_IF;
        
        IF valveDStart AND NOT previousValveDStart THEN
            valveDRun := NOT valveDRun;
        END_IF;
        
        IF mixMotorStart AND NOT previousMixMotorStart THEN
            mixMotorRun := NOT mixMotorRun;
        END_IF;
    END_IF;
(* Emergency Stop active - force all outputs to FALSE *)
ELSE
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
END_IF;

(* Update previous state variables for edge detection *)
previousValveAStart := valveAStart;
previousValveBStart := valveBStart;
previousValveCStart := valveCStart;
previousValveDStart := valveDStart;
previousMixMotorStart := mixMotorStart;
previousAutoStart := autoStart;

END_FUNCTION_BLOCK;