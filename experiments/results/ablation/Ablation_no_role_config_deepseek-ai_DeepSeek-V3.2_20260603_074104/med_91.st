FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT; (* New material handling request, positive value indicates valid request *)
END_VAR

VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE; (* AGV 1 ready status *)
    AGV2_Ready : BOOL := TRUE; (* AGV 2 ready status *)
    AGV3_Ready : BOOL := TRUE; (* AGV 3 ready status *)
    QueueStatus : INT := 0; (* Current number of tasks in queue *)
    SystemError : BOOL := FALSE; (* System error flag *)
    ErrorCode : INT := 0; (* Error code: 0=No error, 1=Queue overflow, 2=Invalid request, 3=Position error *)
END_VAR

VAR
    (* Queue management variables *)
    MaterialQueue : ARRAY[1..10] OF INT; (* Material handling request queue *)
    QueueHead : INT := 1; (* Index of first element in queue *)
    QueueTail : INT := 1; (* Index where next element will be inserted *)
    QueueCount : INT := 0; (* Current number of elements in queue *)
    
    (* AGV status tracking *)
    AGVPosition : ARRAY[1..3] OF INT := [0,0,0]; (* Current position of each AGV *)
    AGVTask : ARRAY[1..3] OF INT := [0,0,0]; (* Current task assigned to each AGV *)
    AGVWorking : ARRAY[1..3] OF BOOL := [FALSE,FALSE,FALSE]; (* Working status of each AGV *)
    
    (* Internal flags and counters *)
    TaskInProgress : BOOL := FALSE; (* Flag indicating if any AGV is working *)
    i : INT; (* Loop counter *)
    TempRequest : INT; (* Temporary request storage *)
END_VAR

(* Initialize error states *)
SystemError := FALSE;
ErrorCode := 0;

(* 1. Queue Management - Process new material requests *)
IF MaterialRequest > 0 THEN
    (* Validate request *)
    IF MaterialRequest <= 0 THEN
        SystemError := TRUE;
        ErrorCode := 2; (* Invalid request *)
    ELSIF QueueCount >= 10 THEN
        SystemError := TRUE;
        ErrorCode := 1; (* Queue overflow *)
    ELSE
        (* Add request to queue - atomic operation *)
        MaterialQueue[QueueTail] := MaterialRequest;
        
        (* Update queue tail with wrap-around *)
        QueueTail := QueueTail + 1;
        IF QueueTail > 10 THEN
            QueueTail := 1;
        END_IF;
        
        (* Update queue count *)
        QueueCount := QueueCount + 1;
    END_IF;
END_IF;

(* 2. AGV Status Management - Update AGV ready status *)
AGV1_Ready := NOT AGVWorking[1];
AGV2_Ready := NOT AGVWorking[2];
AGV3_Ready := NOT AGVWorking[3];

(* 3. Task Execution Simulation - Simulate AGV movement and task completion *)
FOR i := 1 TO 3 DO
    IF AGVWorking[i] THEN
        (* Simulate AGV movement - increment position *)
        AGVPosition[i] := AGVPosition[i] + 1;
        
        (* Simulate task completion at position 100 *)
        IF AGVPosition[i] >= 100 THEN
            (* Task completed - reset AGV state *)
            AGVWorking[i] := FALSE;
            AGVTask[i] := 0;
            AGVPosition[i] := 0; (* Return to start position *)
        END_IF;
    END_IF;
END_FOR;

(* 4. Check if any task is in progress *)
TaskInProgress := FALSE;
FOR i := 1 TO 3 DO
    IF AGVWorking[i] THEN
        TaskInProgress := TRUE;
        EXIT;
    END_IF;
END_FOR;

(* 5. Priority-based Task Assignment *)
(* Only assign tasks if queue is not empty and no task is currently being assigned *)
IF (QueueCount > 0) AND (NOT TaskInProgress) THEN
    (* Priority order: AGV1 > AGV2 > AGV3 *)
    IF AGV1_Ready THEN
        (* Assign task to AGV1 *)
        AGVTask[1] := MaterialQueue[QueueHead];
        AGVWorking[1] := TRUE;
        
        (* Remove task from queue - atomic operation *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        QueueCount := QueueCount - 1;
        
    ELSIF AGV2_Ready THEN
        (* Assign task to AGV2 *)
        AGVTask[2] := MaterialQueue[QueueHead];
        AGVWorking[2] := TRUE;
        
        (* Remove task from queue *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        QueueCount := QueueCount - 1;
        
    ELSIF AGV3_Ready THEN
        (* Assign task to AGV3 *)
        AGVTask[3] := MaterialQueue[QueueHead];
        AGVWorking[3] := TRUE;
        
        (* Remove task from queue *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        QueueCount := QueueCount - 1;
    END_IF;
END_IF;

(* 6. Safety Constraints - Ensure non-negative positions *)
FOR i := 1 TO 3 DO
    IF AGVPosition[i] < 0 THEN
        AGVPosition[i] := 0;
        SystemError := TRUE;
        ErrorCode := 3; (* Position error *)
    END_IF;
END_FOR;

(* 7. Queue boundary validation *)
IF QueueCount < 0 THEN
    QueueCount := 0;
ELSIF QueueCount > 10 THEN
    QueueCount := 10;
    SystemError := TRUE;
    ErrorCode := 1; (* Queue overflow *)
END_IF;

IF QueueHead < 1 THEN
    QueueHead := 1;
ELSIF QueueHead > 10 THEN
    QueueHead := 10;
END_IF;

IF QueueTail < 1 THEN
    QueueTail := 1;
ELSIF QueueTail > 10 THEN
    QueueTail := 10;
END_IF;

(* 8. Output queue status *)
QueueStatus := QueueCount;

(* 9. System state validation - ensure consistency *)
IF (QueueCount = 0) AND (NOT AGVWorking[1]) AND (NOT AGVWorking[2]) AND (NOT AGVWorking[3]) THEN
    (* System in idle state - all resources released *)
    (* Additional cleanup if needed *)
END_IF;

END_FUNCTION_BLOCK