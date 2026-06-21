plaintext
START_ST
FUNCTION_BLOCK MaterialMixing
VAR_INPUT
    estop : BOOL; (* Emergency Stop Signal *)
    opeMode : BOOL; (* Operation Mode *)
    valveAStart : BOOL; (* Valve A Start Button *)
    valveBStart : BOOL; (* Valve B Start Button *)
    valveCStart : BOOL; (* Valve C Start Button *)
    valveDStart : BOOL; (* Valve D Start Button *)
    mixMotorStart : BOOL; (* Mixing Motor Start Button *)
    autoStart : BOOL; (* Automatic Start Button *)
    processMode : BOOL; (* Process Mode *)
    levelSensor : INT; (* Liquid Level Sensor *)
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
    state : INT := 0; (* Current state of the system *)
    prevState : INT := 0; (* Previous state of the system *)
    previousValveAStart : BOOL := FALSE; (* Previous state of valveAStart input *)
    previousValveBStart : BOOL := FALSE; (* Previous state of valveBStart input *)
    previousValveCStart : BOOL := FALSE; (* Previous state of valveCStart input *)
    previousValveDStart : BOOL := FALSE; (* Previous state of valveDStart input *)
    previousMixMotorStart : BOOL := FALSE; (* Previous state of mixMotorStart input *)
    previousAutoStart : BOOL := FALSE; (* Previous state of autoStart input *)
    autoProcessActive : BOOL := FALSE; (* Indicates if the automatic process is active *)
END_VAR

(* Emergency Stop Logic *)
IF NOT estop THEN
    state := 0; (* Emergency Stop State *)
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
    RETURN;
END_IF

CASE state OF
    (* STATE 0: Emergency Stop *)
    0:
        IF estop AND NOT opeMode THEN
            state := 1; (* Transition to Manual Mode *)
        ELSIF estop AND opeMode THEN
            state := 2; (* Transition to Automatic Mode *)
        END_IF;

    (* STATE 1: Manual Mode *)
    1:
        (* Substate 1.1: Control Valve A *)
        IF valveAStart AND NOT previousValveAStart THEN
            valveARun := NOT valveARun; (* Toggle Valve A *)
        END_IF;
        previousValveAStart := valveAStart;

        (* Substate 1.2: Control Valve B *)
        IF valveBStart AND NOT previousValveBStart THEN
            valveBRun := NOT valveBRun; (* Toggle Valve B *)
        END_IF;
        previousValveBStart := valveBStart;

        (* Substate 1.3: Control Valve C *)
        IF valveCStart AND NOT previousValveCStart THEN
            valveCRun := NOT valveCRun; (* Toggle Valve C *)
        END_IF;
        previousValveCStart := valveCStart;

        (* Substate 1.4: Control Valve D *)
        IF valveDStart AND NOT previousValveDStart THEN
            valveDRun := NOT valveDRun; (* Toggle Valve D *)
        END_IF;
        previousValveDStart := valveDStart;

        (* Substate 1.5: Control Mixing Motor *)
        IF mixMotorStart AND NOT previousMixMotorStart THEN
            mixMotorRun := NOT mixMotorRun; (* Toggle Mixing Motor *)
        END_IF;
        previousMixMotorStart := mixMotorStart;

        (* Transition to Emergency Stop *)
        IF NOT estop THEN
            state := 0;
        END_IF;

    (* STATE 2: Automatic Mode *)
    2:
        IF NOT autoProcessActive THEN
            IF autoStart AND NOT previousAutoStart THEN
                autoProcessActive := TRUE; (* Start Automatic Process *)
                state := 21; (* Transition to Substate 2.1 *)
            END_IF;
            previousAutoStart := autoStart;
        ELSE
            CASE state OF
                (* Substate 2.1: Open Valve A *)
                21:
                    valveARun := TRUE;
                    IF levelSensor >= 50 THEN
                        valveARun := FALSE;
                        state := 22; (* Transition to Substate 2.2 *)
                    END_IF;

                (* Substate 2.2: Close Valve A and Open Valve B *)
                22:
                    valveBRun := TRUE;
                    IF levelSensor >= 80 THEN
                        valveBRun := FALSE;
                        IF NOT processMode THEN
                            state := 241; (* Transition to Substate 2.4.1 *)
                        ELSE
                            state := 242; (* Transition to Substate 2.4.2 *)
                        END_IF;
                    END_IF;

                (* Substate 2.4.1: Mixing Logic (processMode = FALSE) *)
                241:
                    mixMotorRun := TRUE;
                    IF mixMotorComplete THEN
                        mixMotorRun := FALSE;
                        valveDRun := TRUE;
                        autoProcessActive := FALSE; (* End Automatic Process *)
                    END_IF;

                (* Substate 2.4.2: Mixing Logic (processMode = TRUE) *)
                242:
                    valveCRun := TRUE;
                    IF levelSensor >= 100 THEN
                        valveCRun := FALSE;
                        mixMotorRun := TRUE;
                        IF mixMotorComplete THEN
                            mixMotorRun := FALSE;
                            valveDRun := TRUE;
                            autoProcessActive := FALSE; (* End Automatic Process *)
                        END_IF;
                    END_IF;
            END_CASE;
        END_IF;

        (* Transition to Emergency Stop *)
        IF NOT estop THEN
            state := 0;
        END_IF;
END_CASE;
END_FUNCTION_BLOCK
END_ST