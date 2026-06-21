FUNCTION_BLOCK CarParkingSystem
VAR_INPUT
    NewCarSlot : INT; (* Input for new car arrival slot number *)
END_VAR
VAR_OUTPUT
    Elevator1Busy : BOOL; (* Elevator 1 status - busy or idle *)
    Elevator2Busy : BOOL; (* Elevator 2 status - busy or idle *)
    Elevator1Position : INT; (* Elevator 1 current position *)
    Elevator2Position : INT; (* Elevator 2 current position *)
END_VAR
VAR
    Elevator1Target : INT; (* Elevator 1 target floor *)
    Elevator2Target : INT; (* Elevator 2 target floor *)
    CarSlots : ARRAY[1..100] OF BOOL; (* Array to represent parking slots - TRUE if occupied *)
    bInitialized : BOOL := FALSE; (* Initialization flag *)
    i : INT; (* Loop index *)
    PendingRequests1 : ARRAY[1..50] OF BOOL; (* Pending requests for Elevator 1 *)
    PendingRequests2 : ARRAY[51..100] OF BOOL; (* Pending requests for Elevator 2 *)
    ScanIndex1 : INT := 1; (* Scanning index for Elevator 1 *)
    ScanIndex2 : INT := 51; (* Scanning index for Elevator 2 *)
END_VAR

(* Initialization - executed once *)
IF NOT bInitialized THEN
    Elevator1Busy := FALSE;
    Elevator2Busy := FALSE;
    Elevator1Position := 0;
    Elevator2Position := 0;
    Elevator1Target := 0;
    Elevator2Target := 0;
    
    (* Initialize all parking slots as empty *)
    FOR i := 1 TO 100 DO
        CarSlots[i] := FALSE;
    END_FOR;
    
    (* Initialize pending request arrays *)
    FOR i := 1 TO 50 DO
        PendingRequests1[i] := FALSE;
    END_FOR;
    
    FOR i := 51 TO 100 DO
        PendingRequests2[i] := FALSE;
    END_FOR;
    
    bInitialized := TRUE;
END_IF;

(* Process new car arrival if valid *)
IF (NewCarSlot >= 1) AND (NewCarSlot <= 100) THEN
    IF NOT CarSlots[NewCarSlot] THEN
        CarSlots[NewCarSlot] := TRUE;
        
        (* Store request in appropriate pending queue *)
        IF NewCarSlot <= 50 THEN
            PendingRequests1[NewCarSlot] := TRUE;
        ELSE
            PendingRequests2[NewCarSlot] := TRUE;
        END_IF;
    END_IF;
END_IF;

(* Control Elevator 1 movement *)
IF Elevator1Busy THEN
    IF Elevator1Position < Elevator1Target THEN
        Elevator1Position := Elevator1Position + 1;
    ELSIF Elevator1Position > Elevator1Target THEN
        Elevator1Position := Elevator1Position - 1;
    ELSE
        (* Elevator reached target - mark slot as serviced *)
        IF (Elevator1Target >= 1) AND (Elevator1Target <= 50) THEN
            PendingRequests1[Elevator1Target] := FALSE;
        END_IF;
        Elevator1Busy := FALSE;
    END_IF;
END_IF;

(* Control Elevator 2 movement *)
IF Elevator2Busy THEN
    IF Elevator2Position < Elevator2Target THEN
        Elevator2Position := Elevator2Position + 1;
    ELSIF Elevator2Position > Elevator2Target THEN
        Elevator2Position := Elevator2Position - 1;
    ELSE
        (* Elevator reached target - mark slot as serviced *)
        IF (Elevator2Target >= 51) AND (Elevator2Target <= 100) THEN
            PendingRequests2[Elevator2Target] := FALSE;
        END_IF;
        Elevator2Busy := FALSE;
    END_IF;
END_IF;

(* Idle elevator scanning for pending requests - Elevator 1 *)
IF NOT Elevator1Busy THEN
    (* Check for pending requests with round-robin scanning *)
    FOR i := 0 TO 49 DO
        ScanIndex1 := ScanIndex1 + 1;
        IF ScanIndex1 > 50 THEN
            ScanIndex1 := 1;
        END_IF;
        
        IF PendingRequests1[ScanIndex1] THEN
            Elevator1Target := ScanIndex1;
            Elevator1Busy := TRUE;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

(* Idle elevator scanning for pending requests - Elevator 2 *)
IF NOT Elevator2Busy THEN
    (* Check for pending requests with round-robin scanning *)
    FOR i := 0 TO 49 DO
        ScanIndex2 := ScanIndex2 + 1;
        IF ScanIndex2 > 100 THEN
            ScanIndex2 := 51;
        END_IF;
        
        IF PendingRequests2[ScanIndex2] THEN
            Elevator2Target := ScanIndex2;
            Elevator2Busy := TRUE;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK