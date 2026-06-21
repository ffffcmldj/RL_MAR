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
    previousValveAStart : BOOL := FALSE;
    previousValveBStart : BOOL := FALSE;
    previousValveCStart : BOOL := FALSE;
    previousValveDStart : BOOL := FALSE;
    previousMixMotorStart : BOOL := FALSE;
    previousAutoStart : BOOL := FALSE;
    previousMixMotorComplete : BOOL := FALSE;
    
    (* Manual mode latches *)
    manualValveARun : BOOL := FALSE;
    manualValveBRun : BOOL := FALSE;
    manualValveCRun : BOOL := FALSE;
    manualValveDRun : BOOL := FALSE;
    manualMixMotorRun : BOOL := FALSE;
    
    (* Automatic mode state machine *)
    autoState : INT := 0; (* 0: Idle, 1: Fill A, 2: Fill B, 3: Fill C (if processMode=true), 4: Mixing, 5: Discharge *)
    
    (* Automatic mode flags *)
    autoSequenceActive : BOOL := FALSE;
END_VAR

(* Emergency stop has highest priority *)
IF NOT estop THEN
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
    
    (* Reset all internal states *)
    manualValveARun := FALSE;
    manualValveBRun := FALSE;
    manualValveCRun := FALSE;
    manualValveDRun := FALSE;
    manualMixMotorRun := FALSE;
    autoState := 0;
    autoSequenceActive := FALSE;
    
    (* Reset edge detection variables *)
    previousValveAStart := valveAStart;
    previousValveBStart := valveBStart;
    previousValveCStart := valveCStart;
    previousValveDStart := valveDStart;
    previousMixMotorStart := mixMotorStart;
    previousAutoStart := autoStart;
    previousMixMotorComplete := mixMotorComplete;
    
    RETURN;
END_IF;

(* Mode selection *)
IF NOT opeMode THEN (* Manual mode *)
    (* Reset automatic mode states *)
    autoState := 0;
    autoSequenceActive := FALSE;
    
    (* Valve A manual control with toggle *)
    IF valveAStart AND NOT previousValveAStart THEN
        manualValveARun := NOT manualValveARun;
    END_IF;
    previousValveAStart := valveAStart;
    
    (* Valve B manual control with toggle *)
    IF valveBStart AND NOT previousValveBStart THEN
        manualValveBRun := NOT manualValveBRun;
    END_IF;
    previousValveBStart := valveBStart;
    
    (* Valve C manual control with toggle *)
    IF valveCStart AND NOT previousValveCStart THEN
        manualValveCRun := NOT manualValveCRun;
    END_IF;
    previousValveCStart := valveCStart;
    
    (* Valve D manual control with toggle *)
    IF valveDStart AND NOT previousValveDStart THEN
        manualValveDRun := NOT manualValveDRun;
    END_IF;
    previousValveDStart := valveDStart;
    
    (* Mixing motor manual control with toggle *)
    IF mixMotorStart AND NOT previousMixMotorStart THEN
        manualMixMotorRun := NOT manualMixMotorRun;
    END_IF;
    previousMixMotorStart := mixMotorStart;
    
    (* Reset autoStart edge detection *)
    previousAutoStart := autoStart;
    previousMixMotorComplete := mixMotorComplete;
    
    (* Assign manual outputs *)
    valveARun := manualValveARun;
    valveBRun := manualValveBRun;
    valveCRun := manualValveCRun;
    valveDRun := manualValveDRun;
    mixMotorRun := manualMixMotorRun;
    
ELSE (* Automatic mode *)
    (* Reset manual latches when switching to automatic mode *)
    manualValveARun := FALSE;
    manualValveBRun := FALSE;
    manualValveCRun := FALSE;
    manualValveDRun := FALSE;
    manualMixMotorRun := FALSE;
    
    (* Edge detection for autoStart button *)
    IF autoStart AND NOT previousAutoStart THEN
        autoSequenceActive := TRUE;
        autoState := 1; (* Start with Fill A state *)
    END_IF;
    previousAutoStart := autoStart;
    
    (* Automatic state machine *)
    IF autoSequenceActive THEN
        CASE autoState OF
            0: (* Idle state - waiting for autoStart *)
                valveARun := FALSE;
                valveBRun := FALSE;
                valveCRun := FALSE;
                valveDRun := FALSE;
                mixMotorRun := FALSE;
                
            1: (* Fill Material A *)
                valveARun := TRUE;
                valveBRun := FALSE;
                valveCRun := FALSE;
                valveDRun := FALSE;
                mixMotorRun := FALSE;
                
                IF levelSensor >= 50 THEN
                    valveARun := FALSE;
                    valveBRun := TRUE;
                    autoState := 2;
                END_IF;
                
            2: (* Fill Material B *)
                valveARun := FALSE;
                valveBRun := TRUE;
                valveCRun := FALSE;
                valveDRun := FALSE;
                mixMotorRun := FALSE;
                
                IF levelSensor >= 80 THEN
                    valveBRun := FALSE;
                    
                    IF processMode THEN
                        (* Process mode true: open valve C *)
                        valveCRun := TRUE;
                        autoState := 3;
                    ELSE
                        (* Process mode false: go directly to mixing *)
                        autoState := 4;
                    END_IF;
                END_IF;
                
            3: (* Fill Material C - only when processMode = TRUE *)
                valveARun := FALSE;
                valveBRun := FALSE;
                valveCRun := TRUE;
                valveDRun := FALSE;
                mixMotorRun := FALSE;
                
                IF levelSensor >= 100 THEN
                    valveCRun := FALSE;
                    autoState := 4;
                END_IF;
                
            4: (* Mixing *)
                valveARun := FALSE;
                valveBRun := FALSE;
                valveCRun := FALSE;
                valveDRun := FALSE;
                mixMotorRun := TRUE;
                
                (* Edge detection for mixMotorComplete *)
                IF mixMotorComplete AND NOT previousMixMotorComplete THEN
                    mixMotorRun := FALSE;
                    autoState := 5;
                END_IF;
                previousMixMotorComplete := mixMotorComplete;
                
            5: (* Discharge *)
                valveARun := FALSE;
                valveBRun := FALSE;
                valveCRun := FALSE;
                valveDRun := TRUE;
                mixMotorRun := FALSE;
                
                (* Sequence remains in discharge state until new cycle *)
                
        END_CASE;
    ELSE
        (* Auto sequence not active - all outputs off *)
        valveARun := FALSE;
        valveBRun := FALSE;
        valveCRun := FALSE;
        valveDRun := FALSE;
        mixMotorRun := FALSE;
        autoState := 0;
    END_IF;
    
    (* Reset manual edge detection variables *)
    previousValveAStart := valveAStart;
    previousValveBStart := valveBStart;
    previousValveCStart := valveCStart;
    previousValveDStart := valveDStart;
    previousMixMotorStart := mixMotorStart;
END_IF;

END_FUNCTION_BLOCK