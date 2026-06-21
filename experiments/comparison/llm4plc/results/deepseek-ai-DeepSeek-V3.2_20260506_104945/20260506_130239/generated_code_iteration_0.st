START_ST
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
    (* State management *)
    state : INT := 0; (* Current state of the FSM *)
    prevState : INT := 0; (* Previous state for tracking *)

    (* Queue management *)
    MaterialQueue : ARRAY[1..10] OF INT; (* FIFO queue for tasks *)
    queueHead : INT := 1; (* Index of first task in queue *)
    queueTail : INT := 1; (* Index where next task will be added *)
    queueCount : INT := 0; (* Number of tasks currently in queue *)

    (* AGV status tracking *)
    AGVPosition : ARRAY[1..3] OF INT := [0,0,0]; (* Current position of each AGV *)
    AGVDestination : ARRAY[1..3] OF INT := [0,0,0]; (* Destination for each AGV's current task *)
    AGVTask : ARRAY[1..3] OF INT := [0,0,0]; (* Current task ID for each AGV *)
    AGVReady : ARRAY[1..3] OF BOOL := [TRUE,TRUE,TRUE]; (* Ready status for each AGV *)

    (* Task processing *)
    currentTask : INT := 0; (* Task currently being processed *)
    errorCode : INT := 0; (* Error code for error states *)

    (* Loop counter *)
    i : INT;

    (* Helper flags *)
    taskAssigned : BOOL;
    agvCompleted : INT;
END_VAR

(* Helper function to check if queue is full *)
FUNCTION isQueueFull : BOOL
VAR_INPUT
END_VAR
BEGIN
    isQueueFull := (queueCount >= 10);
END_FUNCTION

(* Helper function to check if queue is empty *)
FUNCTION isQueueEmpty : BOOL
VAR_INPUT
END_VAR
BEGIN
    isQueueEmpty := (queueCount <= 0);
END_FUNCTION

(* Helper function to enqueue a task *)
FUNCTION enqueue : BOOL
VAR_INPUT
    task : INT;
END_VAR
BEGIN
    IF NOT isQueueFull() AND task > 0 THEN
        MaterialQueue[queueTail] := task;
        queueTail := queueTail + 1;
        IF queueTail > 10 THEN
            queueTail := 1;
        END_IF;
        queueCount := queueCount + 1;
        enqueue := TRUE;
    ELSE
        enqueue := FALSE;
    END_IF;
END_FUNCTION

(* Helper function to dequeue a task *)
FUNCTION dequeue : INT
VAR_INPUT
END_VAR
BEGIN
    IF NOT isQueueEmpty() THEN
        dequeue := MaterialQueue[queueHead];
        MaterialQueue[queueHead] := 0;
        queueHead := queueHead + 1;
        IF queueHead > 10 THEN
            queueHead := 1;
        END_IF;
        queueCount := queueCount - 1;
    ELSE
        dequeue := 0;
    END_IF;
END_FUNCTION

(* Main state machine implementation *)
CASE state OF
    0: (* STATE 0: INITIALIZE SYSTEM *)
        (* Initialize all AGVs as ready *)
        AGV1_Ready := TRUE;
        AGV2_Ready := TRUE;
        AGV3_Ready := TRUE;
        
        (* Initialize AGV status arrays *)
        FOR i := 1 TO 3 DO
            AGVReady[i] := TRUE;
            AGVPosition[i] := 0;
            AGVDestination[i] := 0;
            AGVTask[i] := 0;
        END_FOR;
        
        (* Initialize queue *)
        FOR i := 1 TO 10 DO
            MaterialQueue[i] := 0;
        END_FOR;
        queueHead := 1;
        queueTail := 1;
        queueCount := 0;
        
        (* Initialize other variables *)
        currentTask := 0;
        errorCode := 0;
        taskAssigned := FALSE;
        agvCompleted := 0;
        
        (* Transition to state 1 after initialization *)
        state := 1;
        prevState := 0;

    1: (* STATE 1: PROCESS NEW MATERIAL REQUEST *)
        (* Check for queue overflow *)
        IF isQueueFull() THEN
            errorCode := 1; (* Queue overflow error *)
            state := 7;
        (* Check for invalid request *)
        ELSIF MaterialRequest <= 0 THEN
            errorCode := 2; (* Invalid request error *)
            state := 8;
        (* Process valid request *)
        ELSIF MaterialRequest > 0 THEN
            (* Enqueue the request *)
            IF enqueue(MaterialRequest) THEN
                (* Check priority-based AGV assignment *)
                IF AGVReady[1] THEN
                    state := 2;
                ELSIF AGVReady[2] THEN
                    state := 3;
                ELSIF AGVReady[3] THEN
                    state := 4;
                ELSE
                    (* All AGVs busy, stay in state 1 *)
                    state := 9;
                END_IF;
            END_IF;
        (* No new request and queue is empty *)
        ELSIF isQueueEmpty() THEN
            state := 9;
        END_IF;
        prevState := 1;

    2: (* STATE 2: ASSIGN TASK TO AGV1 *)
        (* Assign task to AGV1 *)
        currentTask := dequeue();
        IF currentTask > 0 THEN
            AGVReady[1] := FALSE;
            AGV1_Ready := FALSE;
            AGVTask[1] := currentTask;
            AGVDestination[1] := currentTask; (* Using request value as destination *)
            taskAssigned := TRUE;
            state := 5;
        ELSE
            (* No task available, return to processing *)
            state := 1;
        END_IF;
        prevState := 2;

    3: (* STATE 3: ASSIGN TASK TO AGV2 *)
        (* Assign task to AGV2 *)
        currentTask := dequeue();
        IF currentTask > 0 THEN
            AGVReady[2] := FALSE;
            AGV2_Ready := FALSE;
            AGVTask[2] := currentTask;
            AGVDestination[2] := currentTask; (* Using request value as destination *)
            taskAssigned := TRUE;
            state := 5;
        ELSE
            (* No task available, return to processing *)
            state := 1;
        END_IF;
        prevState := 3;

    4: (* STATE 4: ASSIGN TASK TO AGV3 *)
        (* Assign task to AGV3 *)
        currentTask := dequeue();
        IF currentTask > 0 THEN
            AGVReady[3] := FALSE;
            AGV3_Ready := FALSE;
            AGVTask[3] := currentTask;
            AGVDestination[3] := currentTask; (* Using request value as destination *)
            taskAssigned := TRUE;
            state := 5;
        ELSE
            (* No task available, return to processing *)
            state := 1;
        END_IF;
        prevState := 4;

    5: (* STATE 5: MONITOR AGV WORKING STATUS *)
        (* Simulate AGV movement and check for task completion *)
        taskAssigned := FALSE;
        agvCompleted := 0;
        
        (* Check each AGV's progress *)
        FOR i := 1 TO 3 DO
            IF NOT AGVReady[i] THEN
                (* Simulate AGV movement - increment position by 1 each cycle *)
                IF AGVPosition[i] < AGVDestination[i] THEN
                    AGVPosition[i] := AGVPosition[i] + 1;
                END_IF;
                
                (* Check if AGV has reached destination *)
                IF AGVPosition[i] >= AGVDestination[i] THEN
                    agvCompleted := i;
                    state := 6;
                    EXIT; (* Exit loop when first AGV completes *)
                END_IF;
            END_IF;
        END_FOR;
        
        (* If no AGV completed, stay in monitoring state *)
        IF agvCompleted = 0 THEN
            state := 5;
        END_IF;
        prevState := 5;

    6: (* STATE 6: COMPLETE TASK AND RELEASE AGV *)
        (* Release the AGV that completed its task *)
        IF agvCompleted > 0 AND agvCompleted <= 3 THEN
            AGVReady[agvCompleted] := TRUE;
            AGVPosition[agvCompleted] := 0;
            AGVDestination[agvCompleted] := 0;
            AGVTask[agvCompleted] := 0;
            
            (* Update output variables *)
            CASE agvCompleted OF
                1: AGV1_Ready := TRUE;
                2: AGV2_Ready := TRUE;
                3: AGV3_Ready := TRUE;
            END_CASE;
            
            agvCompleted := 0;
        END_IF;
        
        (* Return to queue processing *)
        state := 1;
        prevState := 6;

    7: (* STATE 7: HANDLE QUEUE OVERFLOW ERROR *)
        (* Error handling for queue overflow *)
        (* In a real system, this would trigger an alarm or notification *)
        (* For now, just reset error and return to processing *)
        errorCode := 0;
        state := 1;
        prevState := 7;

    8: (* STATE 8: HANDLE INVALID REQUEST ERROR *)
        (* Error handling for invalid request *)
        (* In a real system, this would log the error *)
        errorCode := 0;
        state := 1;
        prevState := 8;

    9: (* STATE 9: SYSTEM IDLE *)
        (* System is idle - wait for new requests *)
        (* Check if new request arrived or queue has tasks *)
        IF MaterialRequest > 0 OR NOT isQueueEmpty() THEN
            state := 1;
        ELSE
            state := 9; (* Stay idle *)
        END_IF;
        prevState := 9;

    ELSE
        (* Default case - reset to initialization *)
        state := 0;
END_CASE;

(* Safety constraint: Ensure AGV positions are non-negative *)
FOR i := 1 TO 3 DO
    IF AGVPosition[i] < 0 THEN
        AGVPosition[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK
END_ST