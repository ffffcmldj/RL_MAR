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
        AGVPosition : ARRAY[1..3] OF INT := [0, 0, 0]; (* AGV position array initialized to zero *)
        i : INT; (* Loop counter *)
        QueueCount : INT := 0; (* Count of tasks in the queue *)
        TaskAssigned : BOOL := FALSE; (* Flag to check if a task is assigned *)
    END_VAR

    // Initialization of the queue and AGV positions
    IF QueueCount = 0 THEN
        FOR i := 1 TO 10 DO
            MaterialQueue[i] := 0; // Initialize queue to zero
        END_FOR
    END_IF

    // Handle new material request
    IF MaterialRequest > 0 THEN
        IF QueueCount < 10 THEN // Check for queue overflow
            QueueCount := QueueCount + 1;
            MaterialQueue[QueueCount] := MaterialRequest; // Add request to queue
        END_IF
    END_IF

    // Task assignment logic
    IF QueueCount > 0 THEN // Check if there are tasks in the queue
        IF AGV1_Ready THEN
            AGV1_Ready := FALSE; // AGV1 is now working
            TaskAssigned := TRUE;
            // Process the task
            MaterialQueue[1] := 0; // Mark task as completed
            QueueCount := QueueCount - 1; // Decrease queue count
            // Shift queue
            FOR i := 1 TO QueueCount DO
                MaterialQueue[i] := MaterialQueue[i + 1];
            END_FOR
        ELSIF AGV2_Ready THEN
            AGV2_Ready := FALSE; // AGV2 is now working
            TaskAssigned := TRUE;
            // Process the task
            MaterialQueue[1] := 0; // Mark task as completed
            QueueCount := QueueCount - 1; // Decrease queue count
            // Shift queue
            FOR i := 1 TO QueueCount DO
                MaterialQueue[i] := MaterialQueue[i + 1];
            END_FOR
        ELSIF AGV3_Ready THEN
            AGV3_Ready := FALSE; // AGV3 is now working
            TaskAssigned := TRUE;
            // Process the task
            MaterialQueue[1] := 0; // Mark task as completed
            QueueCount := QueueCount - 1; // Decrease queue count
            // Shift queue
            FOR i := 1 TO QueueCount DO
                MaterialQueue[i] := MaterialQueue[i + 1];
            END_FOR
        END_IF
    END_IF

    // Reset AGV status upon task completion
    IF TaskAssigned THEN
        IF NOT AGV1_Ready THEN
            AGV1_Ready := TRUE; // Reset AGV1 to ready
        ELSIF NOT AGV2_Ready THEN
            AGV2_Ready := TRUE; // Reset AGV2 to ready
        ELSIF NOT AGV3_Ready THEN
            AGV3_Ready := TRUE; // Reset AGV3 to ready
        END_IF
        TaskAssigned := FALSE; // Reset task assigned flag
    END_IF

    // Safety checks for AGV positions
    FOR i := 1 TO 3 DO
        IF AGVPosition[i] < 0 THEN
            AGVPosition[i] := 0; // Ensure AGV positions are non-negative
        END_IF
    END_FOR

END_FUNCTION_BLOCK