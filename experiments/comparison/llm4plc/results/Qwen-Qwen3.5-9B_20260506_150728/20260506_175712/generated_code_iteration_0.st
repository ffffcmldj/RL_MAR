START_ST
FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    SalinitySensor : REAL;
END_VAR
VAR_OUTPUT
    SeawaterInletValve : BOOL;
    FreshwaterOutletValve : BOOL;
    DesalinationInProgress : BOOL;
END_VAR
VAR
    (* State Machine Variables *)
    currentState : INT; (* 0: IDLE, 1: RUNNING, 2: SALINITY_HIGH *)
    
    (* Timer Variables for 10-second interval *)
    salinityTimer : INT; (* Accumulates scan cycles or time units up to 10 *)
    (* Note: In a real implementation, this would typically be driven by a TON timer block
       where PT = T#10s. Here we simulate the logic flow assuming the timer increments
       by 1 every scan cycle for demonstration of the state logic. *)
    
    (* Constants *)
    MaxSalinity : REAL := 35.0;
    TimerInterval : INT := 10;
END_VAR

BEGIN
    (* --- Initialization --- *)
    MaxSalinity := 35.0;
    
    (* --- State Machine Logic --- *)
    
    (* Transition: IDLE (0) -> RUNNING (1) *)
    (* Condition: StartButton pressed AND currently not in progress *)
    IF (StartButton = TRUE) AND (DesalinationInProgress = FALSE) THEN
        currentState := 1;
        salinityTimer := 0; (* Reset timer on start *)
    END_IF;

    (* Transition: RUNNING (1) -> SALINITY_HIGH (2) *)
    (* Condition: Currently running AND salinity is too high *)
    IF (currentState = 1) AND (SalinitySensor > MaxSalinity) THEN
        currentState := 2;
    END_IF;

    (* Transition: SALINITY_HIGH (2) -> RUNNING (1) *)
    (* Condition: Currently in high salinity state AND salinity is acceptable *)
    IF (currentState = 2) AND (SalinitySensor <= MaxSalinity) THEN
        currentState := 1;
    END_IF;

    (* Transition: RUNNING (1) -> IDLE (0) *)
    (* Condition: StopButton pressed *)
    IF (StopButton = TRUE) THEN
        currentState := 0;
        salinityTimer := 0;
    END_IF;

    (* Transition: SALINITY_HIGH (2) -> IDLE (0) *)
    (* Condition: StopButton pressed *)
    IF (currentState = 2) AND (StopButton = TRUE) THEN
        currentState := 0;
        salinityTimer := 0;
    END_IF;

    (* --- Timer Logic for 10-second Interval --- *)
    (* Increment timer every scan cycle *)
    salinityTimer := salinityTimer + 1;

    (* Check if 10 seconds have elapsed *)
    IF salinityTimer >= TimerInterval THEN
        salinityTimer := 0; (* Reset timer for next interval *)
        
        (* Perform Salinity Check *)
        IF SalinitySensor > MaxSalinity THEN
            (* Force state to SALINITY_HIGH if not already there *)
            IF currentState <> 2 THEN
                currentState := 2;
            END_IF;
        ELSE
            (* Force state to RUNNING if salinity is good *)
            IF currentState <> 1 THEN
                currentState := 1;
            END_IF;
        END_IF;
    END_IF;

    (* --- Output Assignment Based on State --- *)
    
    CASE currentState OF
        0: (* IDLE *)
            SeawaterInletValve := FALSE;
            FreshwaterOutletValve := FALSE;
            DesalinationInProgress := FALSE;
            
        1: (* RUNNING *)
            SeawaterInletValve := TRUE;
            FreshwaterOutletValve := TRUE;
            DesalinationInProgress := TRUE;
            
        2: (* SALINITY_HIGH *)
            SeawaterInletValve := TRUE;
            FreshwaterOutletValve := FALSE;
            DesalinationInProgress := TRUE;
    END_CASE;

END_FUNCTION_BLOCK
END_ST