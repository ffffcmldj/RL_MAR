START_ST
FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT;
    TaskCompleted : BOOL; (* External signal indicating a task is finished *)
END_VAR
VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE;
    AGV2_Ready : BOOL := TRUE;
    AGV3_Ready : BOOL := TRUE;
    OverflowError : BOOL := FALSE;
    InvalidRequestError : BOOL := FALSE;
END_VAR
VAR
    (* States *)
    state : INT; (* 0:IDLE, 1:PENDING_ASSIGNMENT, 2:ASSIGNING, 3:EXECUTING, 4:COMPLETED, 5:ERROR *)
    prevState : INT;
    
    (* Queue Variables *)
    MaterialQueue : ARRAY[1..10] OF INT;
    QueueHead : INT := 1;
    QueueTail : INT := 1;
    QueueCount : INT := 0;
    
    (* AGV Variables *)
    AGVPosition : ARRAY[1..3] OF INT := [0, 0, 0];
    AGVStatus : ARRAY[1..3] OF BOOL := [TRUE, TRUE, TRUE]; (* TRUE=Ready, FALSE=Working *)
    AGVTaskID : ARRAY[1..3] OF INT := [0, 0, 0];
    
    (* Logic Helpers *)
    i : INT;
    SelectedAGV : INT;
    PriorityLogic : BOOL;
    NextState : INT;
END_VAR

BEGIN
    (* 0. INITIALIZE PREVIOUS STATE *)
    IF prevState = 0 THEN
        prevState := state;
    END_IF;

    (* 1. STATE MACHINE LOGIC *)
    
    (* STATE 0: IDLE *)
    IF state = 0 THEN
        (* Check for invalid input or overflow before accepting *)
        IF MaterialRequest < 0 THEN
            NextState := 5; (* ERROR *)
            InvalidRequestError := TRUE;
        ELSE
            IF QueueCount < 10 THEN
                NextState := 1; (* PENDING_ASSIGNMENT *)
                OverflowError := FALSE;
            ELSE
                NextState := 5; (* ERROR: Overflow *)
                OverflowError := TRUE;
            END_IF;
        END_IF;
    END_IF;

    (* STATE 1: PENDING_ASSIGNMENT *)
    IF state = 1 THEN
        (* Find best AGV based on priority: AGV1 > AGV2 > AGV3 *)
        (* Only assign if AGV is Ready (TRUE) *)
        PriorityLogic := FALSE;
        SelectedAGV := 0;

        IF AGVStatus[1] = TRUE THEN
            SelectedAGV := 1;
            PriorityLogic := TRUE;
        ELSIF AGVStatus[2] = TRUE THEN
            SelectedAGV := 2;
            PriorityLogic := TRUE;
        ELSIF AGVStatus[3] = TRUE THEN
            SelectedAGV := 3;
            PriorityLogic := TRUE;
        END_IF;

        IF PriorityLogic = TRUE THEN
            NextState := 2; (* ASSIGNING *)
        ELSE
            (* No AGV available, stay pending or go idle if queue logic dictates *)
            (* Per plan: if no AGV ready, we might wait. 
               However, to ensure system reaches idle state eventually, 
               if queue is not empty but no AGV ready, we stay here or transition to Idle if we consider 'no AGV' as system halt.
               Let's transition to IDLE if no AGV is ready to prevent infinite wait, 
               but strictly following plan: "Only assigns tasks to AGVs that are in the ready state".
               If none are ready, we cannot assign. We will transition to IDLE to reset or wait. *)
            NextState := 0; (* IDLE - effectively waiting for AGV to become ready or new request *)
        END_IF;
    END_IF;

    (* STATE 2: ASSIGNING *)
    IF state = 2 THEN
        (* Execute assignment *)
        IF SelectedAGV > 0 THEN
            (* Update AGV Status to Working *)
            AGVStatus[SelectedAGV] := FALSE;
            
            (* Assign Task ID from Queue Head *)
            IF QueueHead <= QueueTail THEN
                AGVTaskID[SelectedAGV] := MaterialQueue[QueueHead];
                QueueHead := QueueHead + 1;
                QueueCount := QueueCount - 1;
            END_IF;
            
            (* Record Position (Simulated: Set to current request ID or fixed offset for demo) *)
            AGVPosition[SelectedAGV] := MaterialRequest;
            
            NextState := 3; (* EXECUTING *)
        ELSE
            NextState := 5; (* ERROR: Assignment failed *)
        END_IF;
    END_IF;

    (* STATE 3: EXECUTING *)
    IF state = 3 THEN
        (* Monitor TaskCompleted Signal *)
        IF TaskCompleted = TRUE THEN
            NextState := 4; (* COMPLETED *)
        END_IF;
    END_IF;

    (* STATE 4: COMPLETED *)
    IF state = 4 THEN
        (* Reset AGV Status to Ready *)
        IF SelectedAGV > 0 THEN
            AGVStatus[SelectedAGV] := TRUE;
            AGVTaskID[SelectedAGV] := 0;
            AGVPosition[SelectedAGV] := 0;
        END_IF;
        
        (* Check if more tasks in queue *)
        IF QueueCount > 0 THEN
            NextState := 1; (* PENDING_ASSIGNMENT - Next task *)
        ELSE
            NextState := 0; (* IDLE *)
        END_IF;
    END_IF;

    (* STATE 5: ERROR/SAFETY_CHECK *)
    IF state = 5 THEN
        (* Reset System to Safe State *)
        AGVStatus[1] := TRUE;
        AGVStatus[2] := TRUE;
        AGVStatus[3] := TRUE;
        AGVTaskID[1] := 0; AGVTaskID[2] := 0; AGVTaskID[3] := 0;
        AGVPosition[1] := 0; AGVPosition[2] := 0; AGVPosition[3] := 0;
        
        (* Clear Queue if corrupted or reset *)
        QueueHead := 1;
        QueueTail := 1;
        QueueCount := 0;
        
        NextState := 0; (* IDLE *)
    END_IF;

    (* TRANSITION LOGIC *)
    state := NextState;
    prevState := state;

    (* 2. OUTPUT ASSIGNMENT *)
    (* Ensure non-negative positions *)
    IF AGVPosition[1] < 0 THEN AGVPosition[1] := 0; END_IF;
    IF AGVPosition[2] < 0 THEN AGVPosition[2] := 0; END_IF;
    IF AGVPosition[3] < 0 THEN AGVPosition[3] := 0; END_IF;

    (* Map Status to Outputs *)
    AGV1_Ready := AGVStatus[1];
    AGV2_Ready := AGVStatus[2];
    AGV3_Ready := AGVStatus[3];

END_FUNCTION_BLOCK
END_ST