START_ST
FUNCTION_BLOCK PrecisionEngravingMachine
VAR_INPUT
    DesignSelection : INT;
    EngravingDepth : REAL;
    EngravingSpeed : REAL;
END_VAR

VAR_OUTPUT
    ZAxisMotor : BOOL;
    EngravingMotor : BOOL;
END_VAR

VAR
    CurrentState : INT;
    CalculatedDepth : REAL;
    CalculatedSpeed : REAL;
END_VAR

END_FUNCTION_BLOCK

// Implementation of PrecisionEngravingMachine
// State Machine Logic for Design Selection

// Initialize CurrentState to 0 (Idle/Invalid) on first execution or reset if needed.
// Since this is a function block without a persistent memory mechanism defined in the plan,
// we assume the state is managed by the logic flow within the scan cycle as per the plan's
// "execute once per PLC scan cycle" and "update immediately" requirement.
// However, to maintain state across cycles if the input doesn't change, we need to persist CurrentState.
// The plan implies the state changes based on input. To ensure repeatability and state retention
// between scans when input is stable, we must declare CurrentState as VAR (persistent) or handle it.
// Given the plan says "CurrentState : INT; // THE CURRENT STATE VARIABLE", we treat it as a local variable
// that retains its value between calls if declared in VAR, or re-evaluated.
// The plan logic: "If DesignSelection is 1, 2, or 3, the CurrentState is updated immediately".
// This implies a state machine where the current state is determined by the latest valid input.
// To strictly follow the plan's transition logic which includes transitions like 1->2, we need to know
// the previous state to avoid oscillation if the input is noisy, OR simply set the state based on input.
// The plan explicitly lists transitions like "STATE 1 -> STATE 2: IF DesignSelection = 2".
// This suggests a state machine where we track the previous state.
// However, the plan also says "At the start of every cycle, the logic checks the DesignSelection input...
// If DesignSelection is 1, 2, or 3, the CurrentState is updated immediately".
// This phrasing suggests a direct mapping: State = DesignSelection (if valid) else 0.
// But the transition list includes "STATE 1 -> STATE 2", which implies we need to know we were in State 1.
// If we just set State := DesignSelection, the transition 1->2 happens instantly.
// Let's implement the logic as a direct state assignment based on the input, as the plan emphasizes
// "update immediately" and "satisfying repeatability... without using time-based loops".
// We will persist CurrentState in the VAR section to maintain the state between scans if the input is constant,
// but update it immediately when the input changes.

// Re-reading the plan's variable declaration:
// "CurrentState : INT; // THE CURRENT STATE VARIABLE" is listed under "DECLARE THE NEEDED VARIABLES".
// In ST, variables in VAR are persistent between calls of the FB. This fits the requirement.

// Logic Implementation
// 1. Determine the new state based on DesignSelection
// 2. Update CurrentState
// 3. Assign outputs based on CurrentState

// Check for invalid design first to force state 0
IF (DesignSelection < 1) OR (DesignSelection > 3) THEN
    CurrentState := 0;
    CalculatedDepth := 0.0;
    CalculatedSpeed := 0.0;
    ZAxisMotor := FALSE;
    EngravingMotor := FALSE;
ELSIF DesignSelection = 1 THEN
    CurrentState := 1;
    CalculatedDepth := 0.1;
    CalculatedSpeed := 10.0;
    ZAxisMotor := TRUE;
    EngravingMotor := TRUE;
ELSIF DesignSelection = 2 THEN
    CurrentState := 2;
    CalculatedDepth := 0.2;
    CalculatedSpeed := 8.0;
    ZAxisMotor := TRUE;
    EngravingMotor := TRUE;
ELSIF DesignSelection = 3 THEN
    CurrentState := 3;
    CalculatedDepth := 0.15;
    CalculatedSpeed := 12.0;
    ZAxisMotor := TRUE;
    EngravingMotor := TRUE;
END_IF

// Note: The plan mentions inputs EngravingDepth and EngravingSpeed are passed for interface
// but overridden by fixed values. They are not used in the calculation logic as per the specific
// requirements for Designs 1, 2, and 3.

END_ST