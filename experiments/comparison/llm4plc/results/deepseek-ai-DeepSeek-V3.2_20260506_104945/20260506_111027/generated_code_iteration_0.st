START_ST
FUNCTION_BLOCK MaterialMixing
VAR_INPUT
    estop : BOOL;
    opeMode : BOOL;
    valveAStart : BOOL;
    valveBStart : BOOL;
    valveCStart : BOOL;
    valveDStart : BOOL;
    mixMotorStart : BOOL;
    autoStart : BOOL;
    processMode : BOOL;
    levelSensor : INT;
    mixMotorComplete : BOOL;
END_VAR
VAR_OUTPUT
    valveARun : BOOL;
    valveBRun : BOOL;
    valveCRun : BOOL;
    valveDRun : BOOL;
    mixMotorRun : BOOL;
END_VAR
VAR
    (* Edge detection for button inputs *)
    previousValveAStart : BOOL := FALSE;
    previousValveBStart : BOOL := FALSE;
    previousValveCStart : BOOL := FALSE;
    previousValveDStart : BOOL := FALSE;
    previousMixMotorStart : BOOL := FALSE;
    previousAutoStart : BOOL := FALSE;
    
    (* State machine variables *)
    state : INT := 0;
    prevState : INT := 0;
    
    (* Manual mode toggle variables *)
    valveAToggle : BOOL := FALSE;
    valveBToggle : BOOL := FALSE;
    valveCToggle : BOOL := FALSE;
    valveDToggle : BOOL := FALSE;
    mixMotorToggle : BOOL := FALSE;
    
    (* Internal output variables for manual and automatic modes *)
    valveARunManual : BOOL := FALSE;
    valveBRunManual : BOOL := FALSE;
    valveCRunManual : BOOL := FALSE;
    valveDRunManual : BOOL := FALSE;
    mixMotorRunManual : BOOL := FALSE;
    
    valveARunAuto : BOOL := FALSE;
    valveBRunAuto : BOOL := FALSE;
    valveCRunAuto : BOOL := FALSE;
    valveDRunAuto : BOOL := FALSE;
    mixMotorRunAuto : BOOL := FALSE;
END_VAR

    (* Emergency stop logic - highest priority *)
    IF NOT estop THEN
        (* Force IDLE state and reset all outputs *)
        state := 0;
        valveARunManual := FALSE;
        valveBRunManual := FALSE;
        valveCRunManual := FALSE;
        valveDRunManual := FALSE;
        mixMotorRunManual := FALSE;
        valveAToggle := FALSE;
        valveBToggle := FALSE;
        valveCToggle := FALSE;
        valveDToggle := FALSE;
        mixMotorToggle := FALSE;
        
        valveARunAuto := FALSE;
        valveBRunAuto := FALSE;
        valveCRunAuto := FALSE;
        valveDRunAuto := FALSE;
        mixMotorRunAuto := FALSE;
        
        (* Store previous state for debugging *)
        prevState := state;
        
        (* Set final outputs to FALSE *)
        valveARun := FALSE;
        valveBRun := FALSE;
        valveCRun := FALSE;
        valveDRun := FALSE;
        mixMotorRun := FALSE;
        
        (* Update edge detection variables *)
        previousValveAStart := valveAStart;
        previousValveBStart := valveBStart;
        previousValveCStart := valveCStart;
        previousValveDStart := valveDStart;
        previousMixMotorStart := mixMotorStart;
        previousAutoStart := autoStart;
        
        RETURN;
    END_IF;
    
    (* Manual mode logic *)
    IF NOT opeMode THEN
        (* Manual mode - handle toggle logic for each valve and motor *)
        
        (* Valve A toggle *)
        IF valveAStart AND NOT previousValveAStart THEN
            valveAToggle := NOT valveAToggle;
        END_IF;
        valveARunManual := valveAToggle;
        
        (* Valve B toggle *)
        IF valveBStart AND NOT previousValveBStart THEN
            valveBToggle := NOT valveBToggle;
        END_IF;
        valveBRunManual := valveBToggle;
        
        (* Valve C toggle *)
        IF valveCStart AND NOT previousValveCStart THEN
            valveCToggle := NOT valveCToggle;
        END_IF;
        valveCRunManual := valveCToggle;
        
        (* Valve D toggle *)
        IF valveDStart AND NOT previousValveDStart THEN
            valveDToggle := NOT valveDToggle;
        END_IF;
        valveDRunManual := valveDToggle;
        
        (* Mixing motor toggle *)
        IF mixMotorStart AND NOT previousMixMotorStart THEN
            mixMotorToggle := NOT mixMotorToggle;
        END_IF;
        mixMotorRunManual := mixMotorToggle;
        
        (* In manual mode, automatic outputs are FALSE *)
        valveARunAuto := FALSE;
        valveBRunAuto := FALSE;
        valveCRunAuto := FALSE;
        valveDRunAuto := FALSE;
        mixMotorRunAuto := FALSE;
        
        (* Reset state machine to IDLE when in manual mode *)
        state := 0;
        prevState := state;
        
    ELSE
        (* Automatic mode - state machine logic *)
        
        (* Reset manual outputs in automatic mode *)
        valveARunManual := FALSE;
        valveBRunManual := FALSE;
        valveCRunManual := FALSE;
        valveDRunManual := FALSE;
        mixMotorRunManual := FALSE;
        valveAToggle := FALSE;
        valveBToggle := FALSE;
        valveCToggle := FALSE;
        valveDToggle := FALSE;
        mixMotorToggle := FALSE;
        
        (* State machine transitions *)
        CASE state OF
            0: (* IDLE *)
                valveARunAuto := FALSE;
                valveBRunAuto := FALSE;
                valveCRunAuto := FALSE;
                valveDRunAuto := FALSE;
                mixMotorRunAuto := FALSE;
                
                IF autoStart AND NOT previousAutoStart THEN
                    state := 1; (* AUTOMATIC_START_WAIT *)
                END_IF;
                
            1: (* AUTOMATIC_START_WAIT *)
                valveARunAuto := FALSE;
                valveBRunAuto := FALSE;
                valveCRunAuto := FALSE;
                valveDRunAuto := FALSE;
                mixMotorRunAuto := FALSE;
                
                (* Immediate transition to valve A open *)
                state := 2; (* AUTOMATIC_VALVE_A_OPEN *)
                
            2: (* AUTOMATIC_VALVE_A_OPEN *)
                valveARunAuto := TRUE;
                valveBRunAuto := FALSE;
                valveCRunAuto := FALSE;
                valveDRunAuto := FALSE;
                mixMotorRunAuto := FALSE;
                
                IF levelSensor >= 50 THEN
                    state := 3; (* AUTOMATIC_VALVE_B_OPEN *)
                END_IF;
                
            3: (* AUTOMATIC_VALVE_B_OPEN *)
                valveARunAuto := FALSE;
                valveBRunAuto := TRUE;
                valveCRunAuto := FALSE;
                valveDRunAuto := FALSE;
                mixMotorRunAuto := FALSE;
                
                IF levelSensor >= 80 THEN
                    IF NOT processMode THEN
                        state := 4; (* AUTOMATIC_PROCESSMODE_FALSE_MIXING *)
                    ELSE
                        state := 6; (* AUTOMATIC_PROCESSMODE_TRUE_VALVE_C_OPEN *)
                    END_IF;
                END_IF;
                
            4: (* AUTOMATIC_PROCESSMODE_FALSE_MIXING *)
                valveARunAuto := FALSE;
                valveBRunAuto := FALSE;
                valveCRunAuto := FALSE;
                valveDRunAuto := FALSE;
                mixMotorRunAuto := TRUE;
                
                IF mixMotorComplete THEN
                    state := 5; (* AUTOMATIC_PROCESSMODE_FALSE_VALVE_D_OPEN *)
                END_IF;
                
            5: (* AUTOMATIC_PROCESSMODE_FALSE_VALVE_D_OPEN *)
                valveARunAuto := FALSE;
                valveBRunAuto := FALSE;
                valveCRunAuto := FALSE;
                valveDRunAuto := TRUE;
                mixMotorRunAuto := FALSE;
                
                (* Process ends, return to idle *)
                state := 0;
                
            6: (* AUTOMATIC_PROCESSMODE_TRUE_VALVE_C_OPEN *)
                valveARunAuto := FALSE;
                valveBRunAuto := FALSE;
                valveCRunAuto := TRUE;
                valveDRunAuto := FALSE;
                mixMotorRunAuto := FALSE;
                
                IF levelSensor >= 100 THEN
                    state := 7; (* AUTOMATIC_PROCESSMODE_TRUE_MIXING *)
                END_IF;
                
            7: (* AUTOMATIC_PROCESSMODE_TRUE_MIXING *)
                valveARunAuto := FALSE;
                valveBRunAuto := FALSE;
                valveCRunAuto := FALSE;
                valveDRunAuto := FALSE;
                mixMotorRunAuto := TRUE;
                
                IF mixMotorComplete THEN
                    state := 8; (* AUTOMATIC_PROCESSMODE_TRUE_VALVE_D_OPEN *)
                END_IF;
                
            8: (* AUTOMATIC_PROCESSMODE_TRUE_VALVE_D_OPEN *)
                valveARunAuto := FALSE;
                valveBRunAuto := FALSE;
                valveCRunAuto := FALSE;
                valveDRunAuto := TRUE;
                mixMotorRunAuto := FALSE;
                
                (* Process ends, return to idle *)
                state := 0;
                
        END_CASE;
        
        prevState := state;
    END_IF;
    
    (* Combine manual and automatic outputs *)
    valveARun := valveARunManual OR valveARunAuto;
    valveBRun := valveBRunManual OR valveBRunAuto;
    valveCRun := valveCRunManual OR valveCRunAuto;
    valveDRun := valveDRunManual OR valveDRunAuto;
    mixMotorRun := mixMotorRunManual OR mixMotorRunAuto;
    
    (* Update edge detection variables for next cycle *)
    previousValveAStart := valveAStart;
    previousValveBStart := valveBStart;
    previousValveCStart := valveCStart;
    previousValveDStart := valveDStart;
    previousMixMotorStart := mixMotorStart;
    previousAutoStart := autoStart;
    
END_FUNCTION_BLOCK
END_ST