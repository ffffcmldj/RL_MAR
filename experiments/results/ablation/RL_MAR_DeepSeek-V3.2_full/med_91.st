FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT; (* New material handling request *)
END_VAR

VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE; (* AGV 1 ready status *)
    AGV2_Ready : BOOL := TRUE; (* AGV 2 ready status *)
    AGV3_Ready : BOOL := TRUE; (* AGV 3 ready status *)
END_VAR

VAR
    MaterialQueue : ARRAY[1..10] OF INT; (* Material handling request queue *)
    AGVPosition : ARRAY[1..3] OF INT; (* AGV position array *)
    QueueHead : INT := 1; (* Head pointer for FIFO queue *)
    QueueTail : INT := 1; (* Tail pointer for FIFO queue *)
    QueueCount : INT := 0; (* Current number of tasks in queue *)
    AGVTask : ARRAY[1..3] OF INT := [0,0,0]; (* Current task assigned to each AGV *)
    AGVWorking : ARRAY[1..3] OF BOOL := [FALSE,FALSE,FALSE]; (* Working status of each AGV *)
    TaskToAssign : INT; (* Task to be assigned from queue *)
    Assigned : BOOL; (* Flag indicating task assignment occurred *)
    i : INT; (* Loop counter *)
    j : INT; (* Loop counter *)
    k : INT; (* Loop counter *)
END_VAR

(* 1. Queue Management: Enqueue new material requests *)
IF MaterialRequest > 0 THEN
    IF QueueCount < 10 THEN
        MaterialQueue[QueueTail] := MaterialRequest;
        QueueTail := QueueTail + 1;
        IF QueueTail > 10 THEN
            QueueTail := 1;
        END_IF;
        QueueCount := QueueCount + 1;
    END_IF;
END_IF;

(* 2. AGV Status Control: Update positions and reset upon completion *)
FOR i := 1 TO 3 DO
    IF AGVWorking[i] THEN
        AGVPosition[i] := AGVPosition[i] - 1;
        IF AGVPosition[i] <= 0 THEN
            AGVPosition[i] := 0;
            AGVWorking[i] := FALSE;
            AGVTask[i] := 0;
        END_IF;
    END_IF;
END_FOR;

(* 3. Priority-based Task Assignment: AGV1 > AGV2 > AGV3 *)
Assigned := FALSE;
IF QueueCount > 0 THEN
    TaskToAssign := MaterialQueue[QueueHead];
    FOR j := 1 TO 3 DO
        IF NOT AGVWorking[j] AND NOT Assigned THEN
            AGVWorking[j] := TRUE;
            AGVTask[j] := TaskToAssign;
            AGVPosition[j] := 10;
            QueueHead := QueueHead + 1;
            IF QueueHead > 10 THEN
                QueueHead := 1;
            END_IF;
            QueueCount := QueueCount - 1;
            Assigned := TRUE;
        END_IF;
    END_FOR;
END_IF;

(* 4. Safety Constraints: Ensure non-negative positions *)
FOR k := 1 TO 3 DO
    IF AGVPosition[k] < 0 THEN
        AGVPosition[k] := 0;
    END_IF;
END_FOR;

(* 5. State Monitoring: Update AGV ready status outputs *)
AGV1_Ready := NOT AGVWorking[1];
AGV2_Ready := NOT AGVWorking[2];
AGV3_Ready := NOT AGVWorking[3];

END_FUNCTION_BLOCK;