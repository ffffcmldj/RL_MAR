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

// Main control logic
IF NOT estop THEN
    // Emergency stop triggered, stop all operations
    valveARun := FALSE;
    valveBRun := FALSE;
    valveCRun := FALSE;
    valveDRun := FALSE;
    mixMotorRun := FALSE;
ELSE
    // Normal operation
    IF NOT opeMode THEN
        // Manual Mode
        // Valve A Control
        IF valveAStart AND NOT previousValveAStart THEN
            valveARun := NOT valveARun; // Toggle Valve A
        END_IF;
        previousValveAStart := valveAStart;

        // Valve B Control
        IF valveBStart AND NOT previousValveBStart THEN
            valveBRun := NOT valveBRun; // Toggle Valve B
        END_IF;
        previousValveBStart := valveBStart;

        // Valve C Control
        IF valveCStart AND NOT previousValveCStart THEN
            valveCRun := NOT valveCRun; // Toggle Valve C
        END_IF;
        previousValveCStart := valveCStart;

        // Valve D Control
        IF valveDStart AND NOT previousValveDStart THEN
            valveDRun := NOT valveDRun; // Toggle Valve D
        END_IF;
        previousValveDStart := valveDStart;

        // Mixing Motor Control
        IF mixMotorStart AND NOT previousMixMotorStart THEN
            mixMotorRun := NOT mixMotorRun; // Toggle Mixing Motor
        END_IF;
        previousMixMotorStart := mixMotorStart;

    ELSE
        // Automatic Mode
        IF autoStart AND NOT previousAutoStart THEN
            // Start automatic process
            valveARun := TRUE; // Open Valve A
        END_IF;
        previousAutoStart := autoStart;

        // Check liquid level sensor
        IF levelSensor >= 50 THEN
            valveARun := FALSE; // Close Valve A
            valveBRun := TRUE; // Open Valve B
        END_IF;

        IF levelSensor >= 80 THEN
            valveBRun := FALSE; // Close Valve B
        END_IF;

        // Process Mode Logic
        IF NOT processMode THEN
            // Process Mode FALSE
            IF NOT mixMotorRun THEN
                mixMotorRun := TRUE; // Start Mixing Motor
            END_IF;

            IF mixMotorComplete THEN
                mixMotorRun := FALSE; // Stop Mixing Motor
                valveDRun := TRUE; // Open Valve D
            END_IF;

        ELSE
            // Process Mode TRUE
            valveCRun := TRUE; // Open Valve C
            IF levelSensor >= 100 THEN
                valveCRun := FALSE; // Close Valve C
                mixMotorRun := TRUE; // Start Mixing Motor
            END_IF;

            IF mixMotorComplete THEN
                mixMotorRun := FALSE; // Stop Mixing Motor
                valveDRun := TRUE; // Open Valve D
            END_IF;
        END_IF;
    END_IF;
END_FUNCTION_BLOCK