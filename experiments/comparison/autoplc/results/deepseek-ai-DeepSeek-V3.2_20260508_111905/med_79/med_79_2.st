FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    CapsuleWeight : REAL; (* Current capsule weight *)
    TargetWeight : REAL; (* Target weight to achieve *)
    CapsuleInPosition : BOOL; (* Capsule position sensor *)
    HopperEmpty : BOOL; (* Hopper empty sensor *)
END_VAR
VAR_OUTPUT
    FeederMotor : BOOL; (* Feeder motor control *)
    FillingMotor : BOOL; (* Filling motor control *)
    ConveyorMotor : BOOL; (* Conveyor motor control *)
    FillingInProgress : BOOL; (* Filling status *)
END_VAR
VAR
    // State machine states
    CurrentState : INT := 0; // 0=IDLE, 1=CONVEYING, 2=FILLING, 3=CONVEYING_OUT, 4=ERROR
    PreviousState : INT := 0;
    
    // Timers
    ConveyorTimer : TON;
    FillingTimer : TON;
    ConveyOutTimer : TON;
    
    // Timer presets (in milliseconds)
    ConveyorTimePreset : TIME := T#2S;
    FillingTimePreset : TIME := T#10S;
    ConveyOutTimePreset : TIME := T#1S;
    
    // PID controller variables
    PID_Error : REAL := 0.0;
    PID_LastError : REAL := 0.0;
    PID_Integral : REAL := 0.0;
    PID_Derivative : REAL := 0.0;
    PID_Output : REAL := 0.0;
    
    // PID tuning parameters
    Kp : REAL := 1.0; // Proportional gain
    Ki : REAL := 0.1; // Integral gain
    Kd : REAL := 0.05; // Derivative gain
    
    // Weight tolerance
    WeightTolerance : REAL := 0.005; // 0.5% tolerance
    
    // Error flags
    ErrorCode : INT := 0; // 0=No error, 1=Hopper empty, 2=Capsule not detected, 3=Filling timeout, 4=Initial overfill
    
    // Internal flags
    CapsuleDetected : BOOL := FALSE;
    WeightReached : BOOL := FALSE;
    ManualReset : BOOL := FALSE;
    
    // Cycle time tracking
    LastCycleTime : TIME := T#0s;
    DeltaTime : REAL := 0.01; // Default 10ms cycle time
    
    // Low hopper warning
    LowHopperWarning : BOOL := FALSE;
    LowHopperThreshold : REAL := 0.1; // 10% of normal level (simulated)
    
    // Internal variables for state transitions
    StateEntryTime : TIME := T#0s;
    CurrentTime : TIME := T#0s;
END_VAR

VAR_TEMP
    // Temporary variables for calculations
    TempReal : REAL;
    TempBool : BOOL;
    i : INT;
END_VAR

// Main execution
// Calculate delta time for PID controller
CurrentTime := TIME();
IF LastCycleTime > T#0s THEN
    DeltaTime := TIME_TO_REAL(CurrentTime - LastCycleTime); // Convert to seconds
    IF DeltaTime > 1.0 THEN
        DeltaTime := 0.01; // Limit maximum delta time
    END_IF
    IF DeltaTime < 0.001 THEN
        DeltaTime := 0.001; // Limit minimum delta time
    END_IF
END_IF
LastCycleTime := CurrentTime;

// Safety Check (Hopper Empty) - Highest priority
IF HopperEmpty THEN
    // Immediate shutdown
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    CurrentState := 4; // ERROR state
    ErrorCode := 1; // Hopper empty error
    RETURN; // Terminate execution
END_IF

// Check for low hopper level (simulated - would normally come from sensor)
// For simulation, we'll assume LowHopperWarning is an external input
// If LowHopperWarning is TRUE, we can set a warning but continue operation
// Only transition to error if it becomes critical

// State machine execution
CASE CurrentState OF
    0: // IDLE state
        // Reset outputs
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        
        // Reset error code if no active error
        IF ErrorCode <> 0 AND ManualReset THEN
            ErrorCode := 0;
            ManualReset := FALSE;
        END_IF
        
        // Weight Validation (Initial Check)
        IF CapsuleWeight >= TargetWeight THEN
            // Avoid overfilling
            CurrentState := 4; // ERROR state
            ErrorCode := 4; // Initial overfill error
        ELSIF CapsuleInPosition AND ErrorCode = 0 THEN
            // Capsule detected and no errors
            // Start conveying
            CurrentState := 1; // CONVEYING state
            StateEntryTime := CurrentTime;
            
            // Reset timers
            ConveyorTimer(IN:=FALSE, PT:=ConveyorTimePreset);
            ConveyorTimer(IN:=TRUE, PT:=ConveyorTimePreset);
        END_IF
        
    1: // CONVEYING state
        // Activate conveyor motor
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        // Check for capsule not detected timeout
        ConveyorTimer(IN:=TRUE, PT:=ConveyorTimePreset);
        IF ConveyorTimer.Q THEN
            // Timer expired - capsule not detected in time
            CurrentState := 4; // ERROR state
            ErrorCode := 2; // Capsule not detected error
            ConveyorMotor := FALSE;
        ELSIF CapsuleInPosition THEN
            // Capsule reached position - transition to FILLING
            CurrentState := 2; // FILLING state
            StateEntryTime := CurrentTime;
            ConveyorMotor := FALSE;
            
            // Reset filling timer
            FillingTimer(IN:=FALSE, PT:=FillingTimePreset);
            FillingTimer(IN:=TRUE, PT:=FillingTimePreset);
            
            // Reset PID controller
            PID_LastError := 0.0;
            PID_Integral := 0.0;
            PID_Derivative := 0.0;
        END_IF
        
    2: // FILLING state
        // Set filling in progress flag
        FillingInProgress := TRUE;
        
        // Activate feeder motor
        FeederMotor := TRUE;
        
        // Implement PID control for filling motor
        // Calculate error
        PID_Error := TargetWeight - CapsuleWeight;
        
        // Check if weight reached target within tolerance
        IF ABS(PID_Error) <= (TargetWeight * WeightTolerance) THEN
            // Weight reached - stop filling
            FillingMotor := FALSE;
            FeederMotor := FALSE;
            CurrentState := 3; // CONVEYING_OUT state
            StateEntryTime := CurrentTime;
            
            // Reset conveyor out timer
            ConveyOutTimer(IN:=FALSE, PT:=ConveyOutTimePreset);
            ConveyOutTimer(IN:=TRUE, PT:=ConveyOutTimePreset);
        ELSE
            // Continue filling with PID control
            // Calculate integral term with anti-windup
            IF NOT (FillingMotor AND (PID_Output >= 1.0)) THEN
                PID_Integral := PID_Integral + (PID_Error * DeltaTime);
            END_IF
            
            // Calculate derivative term
            PID_Derivative := (PID_Error - PID_LastError) / DeltaTime;
            
            // Calculate PID output
            PID_Output := (Kp * PID_Error) + (Ki * PID_Integral) + (Kd * PID_Derivative);
            
            // Limit output to 0-1 range
            IF PID_Output > 1.0 THEN
                PID_Output := 1.0;
            ELSIF PID_Output < 0.0 THEN
                PID_Output := 0.0;
            END_IF
            
            // Control filling motor based on PID output
            // Use threshold to convert to BOOL output
            IF PID_Output > 0.1 THEN
                FillingMotor := TRUE;
            ELSE
                FillingMotor := FALSE;
            END_IF
            
            // Update last error
            PID_LastError := PID_Error;
            
            // Check for filling timeout
            FillingTimer(IN:=TRUE, PT:=FillingTimePreset);
            IF FillingTimer.Q THEN
                // Filling timeout
                FillingMotor := FALSE;
                FeederMotor := FALSE;
                CurrentState := 4; // ERROR state
                ErrorCode := 3; // Filling timeout error
            END_IF
        END_IF
        
    3: // CONVEYING_OUT state
        // Activate conveyor to move filled capsule out
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        
        // Check timer
        ConveyOutTimer(IN:=TRUE, PT:=ConveyOutTimePreset);
        IF ConveyOutTimer.Q THEN
            // Conveying complete
            ConveyorMotor := FALSE;
            CurrentState := 0; // Return to IDLE
        END_IF
        
    4: // ERROR state
        // Deactivate all motors
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        
        // Stay in error state until manual reset
        IF ManualReset THEN
            // Reset error if conditions allow
            IF NOT HopperEmpty AND CapsuleWeight < TargetWeight THEN
                CurrentState := 0; // Return to IDLE
                ErrorCode := 0;
                ManualReset := FALSE;
            END_IF
        END_IF
        
    ELSE
        // Invalid state - reset to IDLE
        CurrentState := 0;
END_CASE

// Store previous state for edge detection
PreviousState := CurrentState;
END_FUNCTION_BLOCK