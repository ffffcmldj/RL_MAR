TYPE AGV_Status :
STRUCT
    IsReady : BOOL;
    CurrentTask : INT;
    Position : INT;
    IsWorking : BOOL;
END_STRUCT
END_TYPE

FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT; (* New material request, valid if > 0 *)
    ExecuteCycle : BOOL := TRUE; (* Enable processing for the scan cycle *)
END_VAR
VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE;
    AGV2_Ready : BOOL := TRUE;
    AGV3_Ready : BOOL := TRUE;
    QueueCount : INT := 0; (* Number of pending tasks *)
    SystemIdle : BOOL := TRUE; (* All AGVs ready AND queue empty *)
    ErrorCode : INT := 0; (* 0: OK, 1: Queue Overflow, 2: Invalid Request *)
END_VAR
VAR
    MaterialQueue : ARRAY[1..10] OF INT; (* FIFO queue for tasks *)
    QueueHead : INT := 1; (* Index of the next task to dequeue *)
    QueueTail : INT := 1; (* Index where the next task will be enqueued *)
    AGVs : ARRAY[1..3] OF AGV_Status := [(IsReady:=TRUE, CurrentTask:=0, Position:=0, IsWorking:=FALSE),
                                         (IsReady:=TRUE, CurrentTask:=0, Position:=0, IsWorking:=FALSE),
                                         (IsReady:=TRUE, CurrentTask:=0, Position:=0, IsWorking:=FALSE)];
    TaskAssignedThisCycle : BOOL; (* Prevents multiple assignments in one scan *)
    i : INT;
END_VAR

(* 1. Process new material request with validation and overflow protection *)
ErrorCode := 0;
IF ExecuteCycle THEN
    IF MaterialRequest > 0 THEN
        IF QueueCount < 10 THEN
            MaterialQueue[QueueTail] := MaterialRequest;
            QueueTail := QueueTail + 1;
            IF QueueTail > 10 THEN
                QueueTail := 1;
            END_IF;
            QueueCount := QueueCount + 1;
        ELSE
            ErrorCode := 1; (* Queue Overflow *)
        END_IF;
    ELSIF MaterialRequest < 0 THEN
        ErrorCode := 2; (* Invalid Request *)
    END_IF;

    (* 2. Priority-based task assignment (AGV1 > AGV2 > AGV3) *)
    TaskAssignedThisCycle := FALSE;
    FOR i := 1 TO 3 DO
        IF (AGVs[i].IsReady) AND (QueueCount > 0) AND (NOT TaskAssignedThisCycle) THEN
            AGVs[i].CurrentTask := MaterialQueue[QueueHead];
            AGVs[i].IsReady := FALSE;
            AGVs[i].IsWorking := TRUE;
            AGVs[i].Position := 0; (* Reset position at task start *)
            QueueHead := QueueHead + 1;
            IF QueueHead > 10 THEN
                QueueHead := 1;
            END_IF;
            QueueCount := QueueCount - 1;
            TaskAssignedThisCycle := TRUE;
        END_IF;
    END_FOR;

    (* 3. Simulate task execution and handle completion *)
    FOR i := 1 TO 3 DO
        IF AGVs[i].IsWorking THEN
            (* Simulate position update during task execution *)
            AGVs[i].Position := AGVs[i].Position + 1;

            (* Safety constraint: ensure non-negative position *)
            IF AGVs[i].Position < 0 THEN
                AGVs[i].Position := 0;
            END_IF;

            (* Task completion check - example: task completes after 10 position units *)
            IF AGVs[i].Position >= 10 THEN
                (* Release AGV resource *)
                AGVs[i].Position := 0;
                AGVs[i].CurrentTask := 0;
                AGVs[i].IsWorking := FALSE;
                AGVs[i].IsReady := TRUE;
            END_IF;
        END_IF;
    END_FOR;

    (* 4. Update output status *)
    AGV1_Ready := AGVs[1].IsReady;
    AGV2_Ready := AGVs[2].IsReady;
    AGV3_Ready := AGVs[3].IsReady;

    (* 5. State monitoring and synchronization *)
    SystemIdle := (QueueCount = 0) AND AGVs[1].IsReady AND AGVs[2].IsReady AND AGVs[3].IsReady;

    (* 6. Sanity checks for queue indices (defensive programming) *)
    IF QueueHead < 1 OR QueueHead > 10 THEN
        QueueHead := 1;
    END_IF;
    IF QueueTail < 1 OR QueueTail > 10 THEN
        QueueTail := 1;
    END_IF;
    IF QueueCount < 0 THEN
        QueueCount := 0;
    ELSIF QueueCount > 10 THEN
        QueueCount := 10;
    END_IF;
END_IF;

END_FUNCTION_BLOCK