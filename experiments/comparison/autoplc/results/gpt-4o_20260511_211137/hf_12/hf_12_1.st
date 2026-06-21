FUNCTION_BLOCK MaterialMixing
    VAR_INPUT
        estop : BOOL; // Emergency Stop Signal
        opeMode : BOOL; // Operation Mode
        valveAStart : BOOL; // Valve A Start Button
        valveBStart : BOOL; // Valve B Start Button
        valveCStart : BOOL; // Valve C Start Button
        valveDStart : BOOL; // Valve D Start Button
        mixMotorStart : BOOL; // Mixing Motor Start Button
        autoStart : BOOL; // Automatic Start Button
        processMode : BOOL; // Process Mode
        levelSensor : INT; // Liquid Level Sensor
        mixMotorComplete : BOOL; // Mixing Complete Signal
    END_VAR

    VAR_OUTPUT
        valveARun : BOOL; // Valve A Run Command
        valveBRun : BOOL; // Valve B Run Command
        valveCRun : BOOL; // Valve C Run Command
        valveDRun : BOOL; // Valve D Run Command
        mixMotorRun : BOOL; // Mixing Motor Run Command
    END_VAR

    VAR
        previousValveAStart : BOOL := FALSE;
        previousValveBStart : BOOL := FALSE;
        previousValveCStart : BOOL := FALSE;
        previousValveDStart : BOOL := FALSE;
        previousMixMotorStart : BOOL := FALSE;
        previousAutoStart : BOOL := FALSE;
        autoProcessStarted : BOOL := FALSE;
    END_VAR

    // Emergency Stop Logic
    IF NOT estop THEN
        valveARun := FALSE;
        valveBRun := FALSE;
        valveCRun := FALSE;
        valveDRun := FALSE;
        mixMotorRun := FALSE;
    ELSE
        // Manual Mode Logic
        IF NOT opeMode THEN
            // Valve A Control
            IF valveAStart AND NOT previousValveAStart THEN
                valveARun := NOT valveARun;
            END_IF
            previousValveAStart := valveAStart;

            // Valve B Control
            IF valveBStart AND NOT previousValveBStart THEN
                valveBRun := NOT valveBRun;
            END_IF
            previousValveBStart := valveBStart;

            // Valve C Control
            IF valveCStart AND NOT previousValveCStart THEN
                valveCRun := NOT valveCRun;
            END_IF
            previousValveCStart := valveCStart;

            // Valve D Control
            IF valveDStart AND NOT previousValveDStart THEN
                valveDRun := NOT valveDRun;
            END_IF
            previousValveDStart := valveDStart;

            // Mixing Motor Control
            IF mixMotorStart AND NOT previousMixMotorStart THEN
                mixMotorRun := NOT mixMotorRun;
            END_IF
            previousMixMotorStart := mixMotorStart;
        ELSE
            // Automatic Mode Logic
            IF autoStart AND NOT previousAutoStart THEN
                autoProcessStarted := TRUE;
                valveARun := TRUE;
            END_IF
            previousAutoStart := autoStart;

            IF autoProcessStarted THEN
                // Automatic Sequence
                IF levelSensor >= 50 THEN
                    valveARun := FALSE;
                    valveBRun := TRUE;
                END_IF

                IF levelSensor >= 80 THEN
                    valveBRun := FALSE;
                END_IF

                IF NOT processMode THEN
                    IF NOT mixMotorRun THEN
                        mixMotorRun := TRUE;
                    ELSIF mixMotorComplete THEN
                        mixMotorRun := FALSE;
                        valveDRun := TRUE;
                        autoProcessStarted := FALSE;
                    END_IF
                ELSE
                    IF levelSensor >= 100 THEN
                        valveCRun := FALSE;
                        IF NOT mixMotorRun THEN
                            mixMotorRun := TRUE;
                        ELSIF mixMotorComplete THEN
                            mixMotorRun := FALSE;
                            valveDRun := TRUE;
                            autoProcessStarted := FALSE;
                        END_IF
                    ELSE
                        valveCRun := TRUE;
                    END_IF
                END_IF
            END_IF
        END_IF
    END_IF
END_FUNCTION_BLOCK