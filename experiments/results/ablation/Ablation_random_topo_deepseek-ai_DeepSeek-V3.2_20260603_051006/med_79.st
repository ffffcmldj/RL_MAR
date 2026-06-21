FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    CapsuleWeight : REAL;          (* Current capsule weight *)
    TargetWeight : REAL;           (* Target weight to achieve *)
    CapsuleInPosition : BOOL;      (* Capsule position sensor *)
    HopperEmpty : BOOL;            (* Hopper empty sensor *)
END_VAR

VAR_OUTPUT
    FeederMotor : BOOL;            (* Feeder motor control *)
    FillingMotor : BOOL;           (* Filling motor control *)
    ConveyorMotor : BOOL;          (* Conveyor motor control *)
    FillingInProgress : BOOL;      (* Filling status *)
    ErrorCode : INT;               (* Error code: 0=OK, 1=Capsule timeout, 2=Filling timeout *)
END_VAR

VAR
    // State machine
    CurrentState : INT;            (* 0=IDLE, 1=CONVEYING, 2=FILLING, 3=CONVEYING_OUT *)
    
    // Timers
    ConveyorTimer : TON;
    FillingTimer : TON;
    ConveyOutTimer : TON;
    
    // Timing parameters
    ConveyorTime : TIME := T#2S;   (* Time to convey capsule to filling station *)
    MaxFillingTime : TIME := T#10S; (* Maximum allowed filling time *)
    ConveyOutTime : TIME := T#1S;  (* Time to convey filled capsule out *)
    
    // Control variables
    WeightTolerance : REAL := 0.01; (* 1% tolerance for weight comparison *)
    TargetReached : BOOL;
    FillingStarted : BOOL;
    
    // Error handling
    CapsuleTimeoutError : BOOL;
    FillingTimeoutError : BOOL;
    
    // PID-like control variables (simplified proportional control)
    Kp : REAL := 0.8;              (* Proportional gain *)
    PreviousError : REAL;
    ControlOutput : REAL;
    MinMotorSpeed : REAL := 0.1;   (* Minimum motor speed to prevent stalling *)
END_VAR

// Initialize timers
ConveyorTimer(IN:=FALSE, PT:=ConveyorTime);
FillingTimer(IN:=FALSE, PT:=MaxFillingTime);
ConveyOutTimer(IN:=FALSE, PT:=ConveyOutTime);

// Safety Check: Hopper Empty
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    CurrentState := 0;  // Return to IDLE state
    ErrorCode := 0;
    RETURN;
END_IF

// Weight Validation: Initial Check
IF CapsuleWeight >= TargetWeight THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    CurrentState := 0;  // Return to IDLE state
    ErrorCode := 0;
    RETURN;
END_IF

// Calculate if target weight is reached (within tolerance)
TargetReached := (CapsuleWeight >= TargetWeight * (1 - WeightTolerance)) 
                 AND (CapsuleWeight <= TargetWeight * (1 + WeightTolerance));

// State Machine Implementation
CASE CurrentState OF
    0: (* IDLE State *)
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        ErrorCode := 0;
        
        IF CapsuleInPosition THEN
            CurrentState := 1;  // Move to CONVEYING state
            ConveyorTimer(IN:=TRUE);  // Start conveyor timer
        END_IF
        
    1: (* CONVEYING State *)
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        ConveyorTimer(IN:=TRUE);  // Keep timer running
        
        IF ConveyorTimer.Q THEN
            // Conveyor timed out without capsule detection
            ConveyorMotor := FALSE;
            CapsuleTimeoutError := TRUE;
            ErrorCode := 1;
            CurrentState := 0;  // Return to IDLE
        ELSIF CapsuleInPosition THEN
            // Capsule successfully conveyed to filling station
            ConveyorTimer(IN:=FALSE);  // Reset timer
            CurrentState := 2;  // Move to FILLING state
            FillingTimer(IN:=TRUE);  // Start filling timer
            FillingStarted := TRUE;
            PreviousError := TargetWeight - CapsuleWeight;  // Initialize error for control
        END_IF
        
    2: (* FILLING State *)
        ConveyorMotor := FALSE;
        FillingInProgress := TRUE;
        
        // Simplified proportional control for filling motor
        IF NOT TargetReached AND NOT FillingTimer.Q THEN
            // Calculate error
            VAR
                Error : REAL;
            END_VAR
            
            Error := TargetWeight - CapsuleWeight;
            
            // Proportional control with minimum speed
            ControlOutput := Kp * Error;
            IF ControlOutput < MinMotorSpeed THEN
                ControlOutput := MinMotorSpeed;
            ELSIF ControlOutput > 1.0 THEN
                ControlOutput := 1.0;
            END_IF
            
            // Convert control output to motor command (simplified)
            FillingMotor := TRUE;
            FeederMotor := TRUE;  // Activate feeder to supply material
            
            PreviousError := Error;
        ELSE
            FillingMotor := FALSE;
            FeederMotor := FALSE;
            
            IF TargetReached THEN
                // Successful filling
                FillingTimer(IN:=FALSE);  // Reset timer
                CurrentState := 3;  // Move to CONVEYING_OUT state
                ConveyOutTimer(IN:=TRUE);  // Start convey out timer
            ELSIF FillingTimer.Q THEN
                // Filling timeout
                FillingTimeoutError := TRUE;
                ErrorCode := 2;
                CurrentState := 0;  // Return to IDLE
            END_IF
        END_IF
        
    3: (* CONVEYING_OUT State *)
        FillingMotor := FALSE;
        FeederMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        ConveyOutTimer(IN:=TRUE);  // Keep timer running
        
        IF ConveyOutTimer.Q THEN
            // Finished conveying out
            ConveyorMotor := FALSE;
            ConveyOutTimer(IN:=FALSE);  // Reset timer
            CurrentState := 0;  // Return to IDLE
        END_IF
        
END_CASE;

// Reset error flags when returning to IDLE state
IF CurrentState = 0 THEN
    CapsuleTimeoutError := FALSE;
    FillingTimeoutError := FALSE;
END_IF

END_FUNCTION_BLOCK