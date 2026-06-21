TYPE
    AGV_Status : STRUCT
        IsReady : BOOL;
        IsWorking : BOOL;
        CurrentTask : INT; (* 0 = no task *)
        Position : INT;
    END_STRUCT;
END_TYPE

FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT; (* New material request, positive value indicates valid request *)
    TaskComplete : ARRAY[1..3] OF BOOL; (* External signal to indicate AGV task completion *)
END_VAR
VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE;
    AGV2_Ready : BOOL := TRUE;
    AGV3_Ready : BOOL := TRUE;
    QueueCount : INT := 0; (* Current number of pending tasks *)
    SystemError : BOOL := FALSE; (* Indicates system error state *)
END_VAR
VAR
    MaterialQueue : ARRAY[1..10] OF INT; (* FIFO queue for material requests *)
    QueueHead : INT := 1; (* Index of next task to assign *)
    QueueTail : INT := 1; (* Index where next request will be stored *)
    
    AGVs : ARRAY[1..3] OF AGV_Status := [
        (IsReady := TRUE, IsWorking := FALSE, CurrentTask := 0, Position := 0),
        (IsReady := TRUE, IsWorking := FALSE, CurrentTask := 0, Position := 0),
        (IsReady := TRUE, IsWorking := FALSE, CurrentTask := 0, Position := 0)
    ];
    
    i : INT;
    TempRequest : INT;
    TaskAssigned : BOOL;
END_VAR

(* Initialize outputs *)
AGV1_Ready := AGVs[1].IsReady;
AGV2_Ready := AGVs[2].IsReady;
AGV3_Ready := AGVs[3].IsReady;
QueueCount := 0; (* Will be calculated below *)
SystemError := FALSE;

(* Calculate actual queue count *)
QueueCount := 0;
FOR i := 1 TO 10 DO
    IF MaterialQueue[i] > 0 THEN
        QueueCount := QueueCount + 1;
    END_IF;
END_FOR;

(* 1. Handle new material requests with validation *)
IF MaterialRequest > 0 THEN
    (* Check for queue overflow *)
    IF QueueCount < 10 THEN
        (* Store request in queue *)
        MaterialQueue[QueueTail] := MaterialRequest;
        
        (* Update queue tail with wrap-around *)
        QueueTail := QueueTail + 1;
        IF QueueTail > 10 THEN
            QueueTail := 1;
        END_IF;
        
        QueueCount := QueueCount + 1;
    ELSE
        (* Queue overflow error *)
        SystemError := TRUE;
    END_IF;
END_IF;

(* 2. Handle task completion signals *)
FOR i := 1 TO 3 DO
    IF TaskComplete[i] AND AGVs[i].IsWorking THEN
        (* Reset AGV status upon task completion *)
        AGVs[i].IsWorking := FALSE;
        AGVs[i].CurrentTask := 0;
        AGVs[i].IsReady := TRUE;
        
        (* Safety: Ensure position is non-negative *)
        IF AGVs[i].Position < 0 THEN
            AGVs[i].Position := 0;
        END_IF;
    END_IF;
END_FOR;

(* 3. Priority-based task assignment (AGV1 > AGV2 > AGV3) *)
TaskAssigned := FALSE;

(* Check AGV1 first *)
IF (QueueCount > 0) AND (NOT TaskAssigned) THEN
    IF AGVs[1].IsReady AND (NOT AGVs[1].IsWorking) THEN
        (* Assign task to AGV1 *)
        AGVs[1].CurrentTask := MaterialQueue[QueueHead];
        AGVs[1].IsWorking := TRUE;
        AGVs[1].IsReady := FALSE;
        
        (* Remove task from queue *)
        MaterialQueue[QueueHead] := 0;
        
        (* Update queue head with wrap-around *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        
        QueueCount := QueueCount - 1;
        TaskAssigned := TRUE;
    END_IF;
END_IF;

(* Check AGV2 if AGV1 is busy *)
IF (QueueCount > 0) AND (NOT TaskAssigned) THEN
    IF AGVs[2].IsReady AND (NOT AGVs[2].IsWorking) THEN
        (* Assign task to AGV2 *)
        AGVs[2].CurrentTask := MaterialQueue[QueueHead];
        AGVs[2].IsWorking := TRUE;
        AGVs[2].IsReady := FALSE;
        
        (* Remove task from queue *)
        MaterialQueue[QueueHead] := 0;
        
        (* Update queue head with wrap-around *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        
        QueueCount := QueueCount - 1;
        TaskAssigned := TRUE;
    END_IF;
END_IF;

(* Check AGV3 if AGV1 and AGV2 are busy *)
IF (QueueCount > 0) AND (NOT TaskAssigned) THEN
    IF AGVs[3].IsReady AND (NOT AGVs[3].IsWorking) THEN
        (* Assign task to AGV3 *)
        AGVs[3].CurrentTask := MaterialQueue[QueueHead];
        AGVs[3].IsWorking := TRUE;
        AGVs[3].IsReady := FALSE;
        
        (* Remove task from queue *)
        MaterialQueue[QueueHead] := 0;
        
        (* Update queue head with wrap-around *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        
        QueueCount := QueueCount - 1;
        TaskAssigned := TRUE;
    END_IF;
END_IF;

(* 4. Update AGV positions for working AGVs *)
FOR i := 1 TO 3 DO
    IF AGVs[i].IsWorking THEN
        (* Simulate position update - in real system this would come from sensors *)
        AGVs[i].Position := AGVs[i].Position + 1;
        
        (* Safety constraint: Ensure position is non-negative *)
        IF AGVs[i].Position < 0 THEN
            AGVs[i].Position := 0;
        END_IF;
    END_IF;
END_FOR;

(* 5. Final output updates *)
AGV1_Ready := AGVs[1].IsReady;
AGV2_Ready := AGVs[2].IsReady;
AGV3_Ready := AGVs[3].IsReady;

(* 6. Additional error checking *)
(* Check for invalid queue state *)
IF (QueueCount < 0) OR (QueueCount > 10) THEN
    SystemError := TRUE;
END_IF;

(* Check for invalid AGV states *)
FOR i := 1 TO 3 DO
    IF AGVs[i].IsWorking AND AGVs[i].IsReady THEN
        SystemError := TRUE;
    END_IF;
    
    IF (AGVs[i].CurrentTask > 0) AND (NOT AGVs[i].IsWorking) THEN
        SystemError := TRUE;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK;