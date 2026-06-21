TYPE
    // Define a FIFO queue structure for up to 50 pending requests per elevator
    ElevatorQueue : STRUCT
        Buffer : ARRAY[1..50] OF INT;
        Head : INT; // Points to the next element to be removed
        Tail : INT; // Points to the next free position for insertion
        Count : INT; // Number of elements currently in the queue
    END_STRUCT;
END_TYPE

FUNCTION_BLOCK CarParkingSystem
VAR_INPUT
    NewCarSlot : INT; (* Input for new car arrival slot number (1-100) *)
END_VAR
VAR_OUTPUT
    Elevator1Busy : BOOL; (* Elevator 1 status - TRUE when moving to target *)
    Elevator2Busy : BOOL; (* Elevator 2 status - TRUE when moving to target *)
    Elevator1Position : INT; (* Elevator 1 current position (1-50) *)
    Elevator2Position : INT; (* Elevator 2 current position (51-100) *)
END_VAR
VAR
    // Target positions for each elevator
    Elevator1Target : INT;
    Elevator2Target : INT;
    
    // Parking slot occupancy tracking (TRUE = occupied)
    CarSlots : ARRAY[1..100] OF BOOL;
    
    // Queues for pending requests when elevators are busy
    Queue1 : ElevatorQueue;
    Queue2 : ElevatorQueue;
    
    // Internal helper variables
    bInitComplete : BOOL := FALSE;
    iScanSlot : INT;
END_VAR

// ============================================================================
// INITIALIZATION - Executes once on first scan
// ============================================================================
IF NOT bInitComplete THEN
    // Initialize parking slots as empty
    FOR iScanSlot := 1 TO 100 DO
        CarSlots[iScanSlot] := FALSE;
    END_FOR;
    
    // Set initial elevator positions (home positions)
    Elevator1Position := 1;
    Elevator2Position := 51;
    Elevator1Target := 1;
    Elevator2Target := 51;
    
    // Set elevators to idle state
    Elevator1Busy := FALSE;
    Elevator2Busy := FALSE;
    
    // Initialize queues
    Queue1.Head := 1;
    Queue1.Tail := 1;
    Queue1.Count := 0;
    
    Queue2.Head := 1;
    Queue2.Tail := 1;
    Queue2.Count := 0;
    
    bInitComplete := TRUE;
END_IF;

// ============================================================================
// QUEUE MANAGEMENT FUNCTIONS (Local implementations)
// ============================================================================

// Function to add a slot to a queue (returns TRUE if successful)
IF (NewCarSlot >= 1) AND (NewCarSlot <= 100) AND (NOT CarSlots[NewCarSlot]) THEN
    CarSlots[NewCarSlot] := TRUE;
    
    CASE NewCarSlot OF
        1..50:
            // Assign to Elevator 1 zone
            IF NOT Elevator1Busy THEN
                // Elevator 1 is idle - assign directly
                Elevator1Target := NewCarSlot;
                Elevator1Busy := TRUE;
            ELSE
                // Elevator 1 is busy - add to queue if space available
                IF Queue1.Count < 50 THEN
                    Queue1.Buffer[Queue1.Tail] := NewCarSlot;
                    Queue1.Tail := Queue1.Tail + 1;
                    Queue1.Count := Queue1.Count + 1;
                    
                    // Wrap tail pointer if necessary
                    IF Queue1.Tail > 50 THEN
                        Queue1.Tail := 1;
                    END_IF;
                END_IF;
                // If queue is full (50 pending requests), the arrival is ignored
            END_IF;
            
        51..100:
            // Assign to Elevator 2 zone
            IF NOT Elevator2Busy THEN
                // Elevator 2 is idle - assign directly
                Elevator2Target := NewCarSlot;
                Elevator2Busy := TRUE;
            ELSE
                // Elevator 2 is busy - add to queue if space available
                IF Queue2.Count < 50 THEN
                    Queue2.Buffer[Queue2.Tail] := NewCarSlot;
                    Queue2.Tail := Queue2.Tail + 1;
                    Queue2.Count := Queue2.Count + 1;
                    
                    // Wrap tail pointer if necessary
                    IF Queue2.Tail > 50 THEN
                        Queue2.Tail := 1;
                    END_IF;
                END_IF;
                // If queue is full (50 pending requests), the arrival is ignored
            END_IF;
    END_CASE;
END_IF;

// ============================================================================
// ELEVATOR 1 MOTION CONTROL
// ============================================================================
IF Elevator1Busy THEN
    // Move elevator toward target (one slot per scan cycle)
    IF Elevator1Position < Elevator1Target THEN
        Elevator1Position := Elevator1Position + 1;
    ELSIF Elevator1Position > Elevator1Target THEN
        Elevator1Position := Elevator1Position - 1;
    ELSE
        // Reached target - elevator becomes idle
        Elevator1Busy := FALSE;
        
        // Check if there are pending requests in queue
        IF Queue1.Count > 0 THEN
            // Get next target from queue (FIFO)
            Elevator1Target := Queue1.Buffer[Queue1.Head];
            Queue1.Head := Queue1.Head + 1;
            Queue1.Count := Queue1.Count - 1;
            
            // Wrap head pointer if necessary
            IF Queue1.Head > 50 THEN
                Queue1.Head := 1;
            END_IF;
            
            // Elevator becomes busy again with new target
            Elevator1Busy := TRUE;
        END_IF;
    END_IF;
END_IF;

// ============================================================================
// ELEVATOR 2 MOTION CONTROL
// ============================================================================
IF Elevator2Busy THEN
    // Move elevator toward target (one slot per scan cycle)
    IF Elevator2Position < Elevator2Target THEN
        Elevator2Position := Elevator2Position + 1;
    ELSIF Elevator2Position > Elevator2Target THEN
        Elevator2Position := Elevator2Position - 1;
    ELSE
        // Reached target - elevator becomes idle
        Elevator2Busy := FALSE;
        
        // Check if there are pending requests in queue
        IF Queue2.Count > 0 THEN
            // Get next target from queue (FIFO)
            Elevator2Target := Queue2.Buffer[Queue2.Head];
            Queue2.Head := Queue2.Head + 1;
            Queue2.Count := Queue2.Count - 1;
            
            // Wrap head pointer if necessary
            IF Queue2.Head > 50 THEN
                Queue2.Head := 1;
            END_IF;
            
            // Elevator becomes busy again with new target
            Elevator2Busy := TRUE;
        END_IF;
    END_IF;
END_IF;

// ============================================================================
// IDLE ELEVATOR SCANNING
// ============================================================================
// Elevator 1 scans its zone (slots 1-50) when idle
IF NOT Elevator1Busy THEN
    FOR iScanSlot := 1 TO 50 DO
        IF CarSlots[iScanSlot] THEN
            // Found an occupied slot in zone - assign as target
            Elevator1Target := iScanSlot;
            Elevator1Busy := TRUE;
            EXIT; // Stop scanning after first assignment
        END_IF;
    END_FOR;
END_IF;

// Elevator 2 scans its zone (slots 51-100) when idle
IF NOT Elevator2Busy THEN
    FOR iScanSlot := 51 TO 100 DO
        IF CarSlots[iScanSlot] THEN
            // Found an occupied slot in zone - assign as target
            Elevator2Target := iScanSlot;
            Elevator2Busy := TRUE;
            EXIT; // Stop scanning after first assignment
        END_IF;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK;