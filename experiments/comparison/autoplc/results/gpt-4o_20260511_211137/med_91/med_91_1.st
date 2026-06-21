FUNCTION_BLOCK AGVControlSystem
    VAR_INPUT
        MaterialRequest : INT; (* New material request *)
    END_VAR
    VAR_OUTPUT
        AGV1_Ready : BOOL := TRUE; (* AGV 1 ready status *)
        AGV2_Ready : BOOL := TRUE; (* AGV 2 ready status *)
        AGV3_Ready : BOOL := TRUE; (* AGV 3 ready status *)
    END_VAR
    VAR
        MaterialQueue : ARRAY[1..10] OF INT; (* Material handling request queue *)
        AGVPosition : ARRAY[1..3] OF INT; (* AGV position array *)
        AGVStatus : ARRAY[1..3] OF BOOL := [TRUE, TRUE, TRUE]; (* AGV status array: TRUE for ready, FALSE for working *)
        QueueHead : INT := 1; (* Head of the queue *)
        QueueTail : INT := 0; (* Tail of the queue *)
        i : INT; (* Loop counter *)
    END_VAR

    // Add new material request to the queue
    IF MaterialRequest > 0 THEN
        IF QueueTail < 10 THEN
            QueueTail := QueueTail + 1;
            MaterialQueue[QueueTail] := MaterialRequest;
        ELSE
            // Handle queue overflow
            // Error handling code here
        END_IF
    END_IF

    // Task assignment based on priority
    FOR i := 1 TO 3 DO
        IF AGVStatus[i] = TRUE THEN
            IF QueueHead <= QueueTail THEN
                // Assign task to AGV
                AGVStatus[i] := FALSE;
                AGVPosition[i] := MaterialQueue[QueueHead];
                QueueHead := QueueHead + 1;
            END_IF
        END_IF
    END_FOR

    // Update AGV status and position
    FOR i := 1 TO 3 DO
        IF AGVStatus[i] = FALSE THEN
            // Simulate task completion
            AGVPosition[i] := AGVPosition[i] - 1;
            IF AGVPosition[i] <= 0 THEN
                AGVStatus[i] := TRUE;
                AGVPosition[i] := 0;
            END_IF
        END_IF
    END_FOR

    // Update output ready status
    AGV1_Ready := AGVStatus[1];
    AGV2_Ready := AGVStatus[2];
    AGV3_Ready := AGVStatus[3];

    // Ensure AGV positions are non-negative
    FOR i := 1 TO 3 DO
        IF AGVPosition[i] < 0 THEN
            AGVPosition[i] := 0;
        END_IF
    END_FOR

    // Reset queue if all tasks are completed
    IF QueueHead > QueueTail THEN
        QueueHead := 1;
        QueueTail := 0;
    END_IF
END_FUNCTION_BLOCK