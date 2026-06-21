(* ============================================================
   Window Cleaning System - Production-Ready FUNCTION_BLOCK
   IEC 61131-3 Structured Text
   Senior PLC Commissioning Engineer - Final Authority Version
   ============================================================ *)

(* --- Custom Data Types for Enhanced Safety and Readability --- *)
TYPE
    E_SystemState : (
        STATE_IDLE,            (* 0: System ready, waiting for start *)
        STATE_ASCENDING,       (* 1: Elevator moving to upper limit *)
        STATE_DESCENDING,      (* 2: Elevator cleaning while descending *)
        STATE_FAULT            (* 3: Safety fault detected *)
    );
END_TYPE

(* --- Main Function Block --- *)
FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;        (* Momentary start command *)
    EmergencyStop : BOOL;      (* Safety stop - NC contact recommended *)
    UpperLimit : BOOL;         (* Physical limit switch - TRUE at upper position *)
    LowerLimit : BOOL;         (* Physical limit switch - TRUE at lower position *)
END_VAR

VAR_OUTPUT
    ElevatorUp : BOOL;         (* Command to move elevator upward *)
    ElevatorDown : BOOL;       (* Command to move elevator downward *)
    RotateClockwise : BOOL;    (* Command to activate cleaning brush *)
    WaterPump : BOOL;          (* Command to activate water pump *)
    SystemState : E_SystemState; (* Current operational state for diagnostics *)
    FaultCondition : BOOL;     (* TRUE when in STATE_FAULT *)
END_VAR

VAR
    (* --- State Management --- *)
    CurrentState : E_SystemState := STATE_IDLE;
    
    (* --- Edge Detection and Memory --- *)
    StartButtonPrev : BOOL := FALSE;
    StartRisingEdge : BOOL;
    
    UpperLimitPrev : BOOL := FALSE;
    UpperLimitEdge : BOOL;
    
    LowerLimitPrev : BOOL := FALSE;
    LowerLimitEdge : BOOL;
    
    (* --- Safety Flags --- *)
    BothLimitsActive : BOOL;
    EmergencyStopActive : BOOL;
    
    (* --- Internal Command Variables --- *)
    cmd_ElevatorUp : BOOL;
    cmd_ElevatorDown : BOOL;
    cmd_RotateClockwise : BOOL;
    cmd_WaterPump : BOOL;
END_VAR

(* ============================================================
   MAIN LOGIC EXECUTION
   ============================================================ *)

(* --- Step 1: Input Processing and Edge Detection --- *)
StartRisingEdge := StartButton AND NOT StartButtonPrev;
StartButtonPrev := StartButton;

UpperLimitEdge := UpperLimit AND NOT UpperLimitPrev;
UpperLimitPrev := UpperLimit;

LowerLimitEdge := LowerLimit AND NOT LowerLimitPrev;
LowerLimitPrev := LowerLimit;

(* --- Step 2: Safety Condition Checks --- *)
EmergencyStopActive := EmergencyStop;
BothLimitsActive := UpperLimit AND LowerLimit; (* Fault condition *)

(* --- Step 3: Emergency Stop - Highest Priority Override --- *)
IF EmergencyStopActive THEN
    CurrentState := STATE_IDLE;
    cmd_ElevatorUp := FALSE;
    cmd_ElevatorDown := FALSE;
    cmd_RotateClockwise := FALSE;
    cmd_WaterPump := FALSE;
    
(* --- Step 4: Fault Condition Handling --- *)
ELSIF BothLimitsActive THEN
    CurrentState := STATE_FAULT;
    cmd_ElevatorUp := FALSE;
    cmd_ElevatorDown := FALSE;
    cmd_RotateClockwise := FALSE;
    cmd_WaterPump := FALSE;
    
(* --- Step 5: Normal State Machine Operation --- *)
ELSE
    CASE CurrentState OF
        (* ========== STATE_IDLE ========== *)
        STATE_IDLE:
            (* Reset all commands *)
            cmd_ElevatorUp := FALSE;
            cmd_ElevatorDown := FALSE;
            cmd_RotateClockwise := FALSE;
            cmd_WaterPump := FALSE;
            
            (* Transition to ASCENDING on valid start *)
            IF StartRisingEdge AND NOT LowerLimit THEN
                CurrentState := STATE_ASCENDING;
            END_IF;
        
        (* ========== STATE_ASCENDING ========== *)
        STATE_ASCENDING:
            (* Set commands for upward movement *)
            cmd_ElevatorUp := TRUE;
            cmd_ElevatorDown := FALSE;
            cmd_RotateClockwise := FALSE;
            cmd_WaterPump := FALSE;
            
            (* Check for upper limit with edge detection *)
            IF UpperLimitEdge THEN
                CurrentState := STATE_DESCENDING;
                cmd_ElevatorUp := FALSE; (* Stop upward movement *)
            END_IF;
            
            (* Safety: If lower limit becomes active during ascent *)
            IF LowerLimit THEN
                CurrentState := STATE_IDLE; (* Abort to idle *)
                cmd_ElevatorUp := FALSE;
            END_IF;
        
        (* ========== STATE_DESCENDING ========== *)
        STATE_DESCENDING:
            (* Set commands for cleaning descent *)
            cmd_ElevatorUp := FALSE;
            cmd_ElevatorDown := TRUE;
            cmd_RotateClockwise := TRUE;
            cmd_WaterPump := TRUE;
            
            (* Check for lower limit with edge detection *)
            IF LowerLimitEdge THEN
                CurrentState := STATE_IDLE;
                cmd_ElevatorDown := FALSE;
                cmd_RotateClockwise := FALSE;
                cmd_WaterPump := FALSE;
            END_IF;
            
            (* Safety: If upper limit becomes active during descent *)
            IF UpperLimit THEN
                CurrentState := STATE_IDLE; (* Abort to idle *)
                cmd_ElevatorDown := FALSE;
                cmd_RotateClockwise := FALSE;
                cmd_WaterPump := FALSE;
            END_IF;
        
        (* ========== STATE_FAULT ========== *)
        STATE_FAULT:
            (* Maintain safe state until reset *)
            cmd_ElevatorUp := FALSE;
            cmd_ElevatorDown := FALSE;
            cmd_RotateClockwise := FALSE;
            cmd_WaterPump := FALSE;
            
            (* Manual reset required - clear fault only when limits are not both active *)
            IF NOT BothLimitsActive AND StartRisingEdge THEN
                CurrentState := STATE_IDLE;
            END_IF;
    END_CASE;
END_IF;

(* --- Step 6: Final Output Assignment with Mutual Exclusion --- *)
(* Ensure ElevatorUp and ElevatorDown are never TRUE simultaneously *)
IF cmd_ElevatorUp AND cmd_ElevatorDown THEN
    ElevatorUp := FALSE;
    ElevatorDown := FALSE;
ELSE
    ElevatorUp := cmd_ElevatorUp;
    ElevatorDown := cmd_ElevatorDown;
END_IF;

(* Cleaning outputs follow their commands directly *)
RotateClockwise := cmd_RotateClockwise;
WaterPump := cmd_WaterPump;

(* --- Step 7: Diagnostic Outputs --- *)
SystemState := CurrentState;
FaultCondition := (CurrentState = STATE_FAULT);

END_FUNCTION_BLOCK;