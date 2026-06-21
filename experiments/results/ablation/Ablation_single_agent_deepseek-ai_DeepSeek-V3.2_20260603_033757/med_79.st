FUNCTION_BLOCK CapsuleFillingMachineControl
VAR_INPUT
    CapsuleWeight : REAL;           // Current capsule weight
    TargetWeight : REAL;            // Target weight to achieve
    CapsuleInPosition : BOOL;       // Capsule position sensor
    HopperEmpty : BOOL;             // Hopper empty sensor
END_VAR

VAR_OUTPUT
    FeederMotor : BOOL;             // Feeder motor control
    FillingMotor : BOOL;            // Filling motor control
    ConveyorMotor : BOOL;           // Conveyor motor control
    FillingInProgress : BOOL;       // Filling status
    ErrorCode : INT;                // Error code (0=No error)
END_VAR

VAR
    // State machine
    CurrentState : INT := 0;        // 0=IDLE, 1=CONVEYING, 2=FILLING, 3=CONVEYING_OUT
    PreviousState : INT := 0;
    
    // Timers
    ConveyorTimer : TON;
    FillingTimer : TON;
    ConveyOutTimer : TON;
    CapsuleDetectionTimer : TON;
    
    // PID controller variables (simplified implementation)
    PID_Kp : REAL := 0.5;           // Proportional gain
    PID_Ki : REAL := 0.1;           // Integral gain
    PID_Kd : REAL := 0.05;          // Derivative gain
    PID_Integral : REAL := 0.0;
    PID_PreviousError : REAL := 0.0;
    PID_LastTime : REAL := 0.0;
    PID_CycleTime : REAL := 0.1;    // 100ms cycle time
    PID_Output : REAL := 0.0;
    
    // Control variables
    WeightTolerance : REAL := 0.1;  // Tolerance for weight comparison
    ConveyorTimeSet : TIME := T#2S; // Conveyor operation time
    FillingTimeout : TIME := T#10S; // Maximum filling time
    ConveyOutTime : TIME := T#1S;   // Convey out time
    CapsuleDetectionTimeout : TIME := T#5S; // Timeout for capsule detection
    
    // Internal flags
    CapsuleDetected : BOOL := FALSE;
    FillingComplete : BOOL := FALSE;
    ConveyorStarted : BOOL := FALSE;
    
    // Error handling
    ErrorCapsuleTimeout : BOOL := FALSE;
    ErrorFillingTimeout : BOOL := FALSE;
    ErrorHopperLow : BOOL := FALSE;
    
    // Temporary variables
    CurrentTime : REAL;
    Error : REAL;
    Derivative : REAL;
    dt : REAL;
END_VAR

// Initialize outputs
FeederMotor := FALSE;
FillingMotor := FALSE;
ConveyorMotor := FALSE;
FillingInProgress := FALSE;
ErrorCode := 0;

// Safety Check - Hopper Empty
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    ErrorCode := 1; // Hopper empty error
    CurrentState := 0; // Return to IDLE
    RETURN;
END_IF

// Weight Validation - Initial Check
IF CapsuleWeight >= TargetWeight - WeightTolerance THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    CurrentState := 0; // Return to IDLE
    RETURN;
END_IF

// State Machine Implementation
CASE CurrentState OF
    0: // IDLE State
        FeederMotor := FALSE;
        FillingMotor := FALSE;
        ConveyorMotor := FALSE;
        FillingInProgress := FALSE;
        
        // Reset timers
        ConveyorTimer(IN:=FALSE, PT:=ConveyorTimeSet);
        FillingTimer(IN:=FALSE, PT:=FillingTimeout);
        ConveyOutTimer(IN:=FALSE, PT:=ConveyOutTime);
        CapsuleDetectionTimer(IN:=FALSE, PT:=CapsuleDetectionTimeout);
        
        // Reset flags
        CapsuleDetected := FALSE;
        FillingComplete := FALSE;
        ConveyorStarted := FALSE;
        ErrorCapsuleTimeout := FALSE;
        ErrorFillingTimeout := FALSE;
        
        // Reset PID controller
        PID_Integral := 0.0;
        PID_PreviousError := 0.0;
        PID_Output := 0.0;
        
        // Transition to CONVEYING when capsule is detected
        IF CapsuleInPosition THEN
            CurrentState := 1;
            CapsuleDetectionTimer(IN:=TRUE, PT:=CapsuleDetectionTimeout);
        END_IF
        
    1: // CONVEYING State
        ConveyorMotor := TRUE;
        ConveyorStarted := TRUE;
        FillingInProgress := FALSE;
        
        // Start conveyor timer
        ConveyorTimer(IN:=TRUE, PT:=ConveyorTimeSet);
        
        // Check for capsule detection timeout
        CapsuleDetectionTimer(IN:=TRUE, PT:=CapsuleDetectionTimeout);
        IF CapsuleDetectionTimer.Q THEN
            ErrorCapsuleTimeout := TRUE;
            ErrorCode := 2; // Capsule detection timeout
            CurrentState := 0; // Return to IDLE
        END_IF
        
        // Transition to FILLING after conveyor time or when weight indicates capsule is in position
        IF ConveyorTimer.Q OR (CapsuleWeight > 0.1) THEN
            CurrentState := 2;
            ConveyorMotor := FALSE;
            FillingInProgress := TRUE;
            PID_LastTime := REAL_TO_TIME(T#0ms) / 1000000.0; // Initialize time
        END_IF
        
    2: // FILLING State
        ConveyorMotor := FALSE;
        FillingInProgress := TRUE;
        
        // Start filling timer
        FillingTimer(IN:=TRUE, PT:=FillingTimeout);
        
        // Check for filling timeout
        IF FillingTimer.Q THEN
            ErrorFillingTimeout := TRUE;
            ErrorCode := 3; // Filling timeout
            CurrentState := 0; // Return to IDLE
            FillingMotor := FALSE;
        ELSE
            // Simplified PID Controller Implementation
            CurrentTime := REAL_TO_TIME(T#0ms) / 1000000.0; // Get current time in seconds
            
            // Calculate time difference
            dt := CurrentTime - PID_LastTime;
            IF dt < PID_CycleTime THEN
                // Wait for next cycle
                FillingMotor := FillingMotor; // Maintain current state
            ELSE
                // Calculate error
                Error := TargetWeight - CapsuleWeight;
                
                // Proportional term
                PID_Output := PID_Kp * Error;
                
                // Integral term (with anti-windup)
                IF ABS(Error) < TargetWeight * 0.5 THEN // Only integrate when error is reasonable
                    PID_Integral := PID_Integral + (PID_Ki * Error * dt);
                    // Limit integral term
                    IF PID_Integral > 100.0 THEN
                        PID_Integral := 100.0;
                    ELSIF PID_Integral < -100.0 THEN
                        PID_Integral := -100.0;
                    END_IF;
                END_IF;
                
                // Derivative term
                Derivative := PID_Kd * (Error - PID_PreviousError) / dt;
                
                // Calculate total output
                PID_Output := PID_Output + PID_Integral + Derivative;
                
                // Limit output to 0-100%
                IF PID_Output > 100.0 THEN
                    PID_Output := 100.0;
                ELSIF PID_Output < 0.0 THEN
                    PID_Output := 0.0;
                END_IF;
                
                // Control filling motor based on PID output
                FillingMotor := (PID_Output > 5.0); // Minimum 5% output to start motor
                
                // Update previous values
                PID_PreviousError := Error;
                PID_LastTime := CurrentTime;
            END_IF;
            
            // Check if target weight is reached
            IF CapsuleWeight >= TargetWeight - WeightTolerance THEN
                FillingMotor := FALSE;
                FillingComplete := TRUE;
                CurrentState := 3; // Transition to CONVEYING_OUT
                ConveyOutTimer(IN:=TRUE, PT:=ConveyOutTime);
            END_IF;
        END_IF;
        
    3: // CONVEYING_OUT State
        FillingMotor := FALSE;
        ConveyorMotor := TRUE;
        FillingInProgress := FALSE;
        
        // Start convey out timer
        ConveyOutTimer(IN:=TRUE, PT:=ConveyOutTime);
        
        // Transition back to IDLE after convey out time
        IF ConveyOutTimer.Q THEN
            ConveyorMotor := FALSE;
            CurrentState := 0;
        END_IF;
        
    ELSE
        // Default case - return to IDLE
        CurrentState := 0;
END_CASE;

// Update error code based on error flags
IF ErrorCapsuleTimeout THEN
    ErrorCode := 2;
ELSIF ErrorFillingTimeout THEN
    ErrorCode := 3;
ELSIF ErrorHopperLow THEN
    ErrorCode := 4;
END_IF;

// Update previous state
PreviousState := CurrentState;
END_FUNCTION_BLOCK