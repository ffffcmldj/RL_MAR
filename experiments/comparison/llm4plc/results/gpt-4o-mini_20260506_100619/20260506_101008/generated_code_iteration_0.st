ructured-text
START_ST
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
    state : INT; (* THE STATE VARIABLE *)
    previousValveAStart : BOOL := FALSE; (* FOR RISING EDGE DETECTION OF VALVE A START *)
    previousValveBStart : BOOL := FALSE; (* FOR RISING EDGE DETECTION OF VALVE B START *)
    previousValveCStart : BOOL := FALSE; (* FOR RISING EDGE DETECTION OF VALVE C START *)
    previousValveDStart : BOOL := FALSE; (* FOR RISING EDGE DETECTION OF VALVE D START *)
    previousMixMotorStart : BOOL := FALSE; (* FOR RISING EDGE DETECTION OF MIXING MOTOR START *)
    previousAutoStart : BOOL := FALSE; (* FOR RISING EDGE DETECTION OF AUTO START *)
END_VAR

(* STATE MACHINE IMPLEMENTATION *)
IF estop = FALSE THEN
    state := 11; (* EMERGENCY STOP STATE *)
ELSE
    CASE state OF
        0: (* INITIALIZE *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
            IF opeMode = FALSE THEN
                state := 1; (* MANUAL CONTROL *)
            ELSIF opeMode = TRUE THEN
                state := 2; (* AUTOMATIC CONTROL - WAITING FOR AUTO START *)
            END_IF;

        1: (* MANUAL CONTROL *)
            valveARun := (valveAStart XOR previousValveAStart);
            valveBRun := (valveBStart XOR previousValveBStart);
            valveCRun := (valveCStart XOR previousValveCStart);
            valveDRun := (valveDStart XOR previousValveDStart);
            mixMotorRun := (mixMotorStart XOR previousMixMotorStart);
            IF estop = FALSE THEN
                state := 0; (* BACK TO INITIALIZE STATE *)
            END_IF;

        2: (* AUTOMATIC CONTROL - WAITING FOR AUTO START *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
            IF autoStart = TRUE THEN
                state := 3; (* AUTOMATIC CONTROL - OPEN VALVE A *)
            END_IF;

        3: (* AUTOMATIC CONTROL - OPEN VALVE A *)
            valveARun := TRUE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
            IF levelSensor >= 50 THEN
                state := 4; (* AUTOMATIC CONTROL - CLOSE VALVE A, OPEN VALVE B *)
            END_IF;

        4: (* AUTOMATIC CONTROL - CLOSE VALVE A, OPEN VALVE B *)
            valveARun := FALSE;
            valveBRun := TRUE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
            IF levelSensor >= 80 THEN
                state := 5; (* AUTOMATIC CONTROL - CLOSE VALVE B *)
            END_IF;

        5: (* AUTOMATIC CONTROL - CLOSE VALVE B *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
            IF processMode = FALSE THEN
                state := 6; (* AUTOMATIC CONTROL - START MIXING MOTOR (PROCESS MODE FALSE) *)
            ELSIF processMode = TRUE THEN
                state := 8; (* AUTOMATIC CONTROL - OPEN VALVE C (PROCESS MODE TRUE) *)
            END_IF;

        6: (* AUTOMATIC CONTROL - START MIXING MOTOR (PROCESS MODE FALSE) *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := TRUE;
            IF mixMotorComplete = TRUE THEN
                state := 7; (* AUTOMATIC CONTROL - OPEN VALVE D (PROCESS MODE FALSE) *)
            END_IF;

        7: (* AUTOMATIC CONTROL - OPEN VALVE D (PROCESS MODE FALSE) *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := TRUE;
            mixMotorRun := FALSE;
            state := 2; (* END OF PROCESS, RETURN TO WAITING STATE *)

        8: (* AUTOMATIC CONTROL - OPEN VALVE C (PROCESS MODE TRUE) *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := TRUE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
            IF levelSensor >= 100 THEN
                state := 9; (* AUTOMATIC CONTROL - START MIXING MOTOR (PROCESS MODE TRUE) *)
            END_IF;

        9: (* AUTOMATIC CONTROL - START MIXING MOTOR (PROCESS MODE TRUE) *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := TRUE;
            IF mixMotorComplete = TRUE THEN
                state := 10; (* AUTOMATIC CONTROL - OPEN VALVE D (PROCESS MODE TRUE) *)
            END_IF;

        10: (* AUTOMATIC CONTROL - OPEN VALVE D (PROCESS MODE TRUE) *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := TRUE;
            mixMotorRun := FALSE;
            state := 2; (* END OF PROCESS, RETURN TO WAITING STATE *)

        11: (* EMERGENCY STOP *)
            valveARun := FALSE;
            valveBRun := FALSE;
            valveCRun := FALSE;
            valveDRun := FALSE;
            mixMotorRun := FALSE;
    END_CASE;
END_IF;

previousValveAStart := valveAStart;
previousValveBStart := valveBStart;
previousValveCStart := valveCStart;
previousValveDStart := valveDStart;
previousMixMotorStart := mixMotorStart;
previousAutoStart := autoStart;

END_FUNCTION_BLOCK
END_ST