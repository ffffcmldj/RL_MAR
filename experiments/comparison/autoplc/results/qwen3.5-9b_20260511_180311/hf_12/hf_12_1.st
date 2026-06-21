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
previousValveAStart : BOOL := FALSE;
previousValveBStart : BOOL := FALSE;
previousValveCStart : BOOL := FALSE;
previousValveDStart : BOOL := FALSE;
previousMixMotorStart : BOOL := FALSE;
previousAutoStart : BOOL := FALSE;
autoRunning : BOOL := FALSE;
END_VAR

IF estop THEN
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
ELSE
    IF NOT opeMode THEN
        IF valveAStart AND NOT previousValveAStart THEN
            valveARun := NOT valveARun;
        END_IF;
        previousValveAStart := valveAStart;

        IF valveBStart AND NOT previousValveBStart THEN
            valveBRun := NOT valveBRun;
        END_IF;
        previousValveBStart := valveBStart;

        IF valveCStart AND NOT previousValveCStart THEN
            valveCRun := NOT valveCRun;
        END_IF;
        previousValveCStart := valveCStart;

        IF valveDStart AND NOT previousValveDStart THEN
            valveDRun := NOT valveDRun;
        END_IF;
        previousValveDStart := valveDStart;

        IF mixMotorStart AND NOT previousMixMotorStart THEN
            mixMotorRun := NOT mixMotorRun;
        END_IF;
        previousMixMotorStart := mixMotorStart;

    ELSE
        IF autoStart AND NOT previousAutoStart THEN
            autoRunning := TRUE;
        END_IF;
        previousAutoStart := autoStart;

        IF autoRunning THEN
            IF levelSensor >= 50 THEN
                valveARun := FALSE;
                valveBRun := TRUE;
            ELSE
                valveARun := TRUE;
                valveBRun := FALSE;
            END_IF;

            IF levelSensor >= 80 THEN
                valveBRun := FALSE;
                autoRunning := FALSE;
            END_IF;

            IF NOT autoRunning THEN
                IF processMode = FALSE THEN
                    mixMotorRun := TRUE;
                    IF mixMotorComplete THEN
                        mixMotorRun := FALSE;
                        valveDRun := TRUE;
                        autoRunning := FALSE;
                    END_IF;
                ELSE
                    valveCRun := TRUE;
                    IF levelSensor >= 100 THEN
                        valveCRun := FALSE;
                        mixMotorRun := TRUE;
                        IF mixMotorComplete THEN
                            mixMotorRun := FALSE;
                            valveDRun := TRUE;
                            autoRunning := FALSE;
                        END_IF;
                    END_IF;
                END_IF;
            END_IF;
        END_IF;
    END_IF;
END_IF;

END_FUNCTION_BLOCK