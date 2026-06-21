START_REASON
The feedback indicates a syntax error in the CODESYS compiler validation: "应该用';' 替换'STATE_IDLE'". This is Chinese for "should replace 'STATE_IDLE' with ';'". This suggests that in the CONST section, the constant definition for STATE_IDLE is incorrectly terminated. In Structured Text, constant definitions should end with a semicolon (;), not a colon or other punctuation. Looking at the original code:

CONST
    STATE_IDLE : INT := 0;
    STATE_MOVING_UP : INT := 1;
    STATE_CLEANING_DOWN : INT := 2;
    STATE_EMERGENCY_STOP : INT := 3;
END_CONST

All lines appear to end with semicolons, but the feedback specifically points to STATE_IDLE. Possibly, there's a hidden character or formatting issue in the original submission that caused the compiler to misinterpret the line. To fix this, I'll ensure that the CONST section is correctly formatted with proper semicolons and no extraneous characters. I'll rewrite the CONST section clearly, ensuring each constant definition ends with a semicolon. Additionally, I'll verify the overall structure to prevent any other potential syntax issues.

The rest of the code structure seems correct: it uses FUNCTION_BLOCK, proper variable sections with END_VAR, and a state machine. No changes are needed to the logic, but I'll ensure the code is clean and adheres to ST standards.
END_REASON

START_ST
FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;
    EmergencyStop : BOOL;
    UpperLimit : BOOL;
    LowerLimit : BOOL;
END_VAR

VAR_OUTPUT
    ElevatorUp : BOOL;
    ElevatorDown : BOOL;
    RotateClockwise : BOOL;
    WaterPump : BOOL;
END_VAR

VAR
    CleaningInProgress : BOOL;
    state : INT;
    prevState : INT;
END_VAR

(* State definitions *)
CONST
    STATE_IDLE : INT := 0;
    STATE_MOVING_UP : INT := 1;
    STATE_CLEANING_DOWN : INT := 2;
    STATE_EMERGENCY_STOP : INT := 3;
END_CONST

(* Main FSM execution *)
IF EmergencyStop = TRUE THEN
    state := STATE_EMERGENCY_STOP;
ELSE
    CASE state OF
        STATE_IDLE:
            IF StartButton = TRUE AND NOT CleaningInProgress THEN
                state := STATE_MOVING_UP;
            END_IF;
            
        STATE_MOVING_UP:
            IF UpperLimit = TRUE THEN
                state := STATE_CLEANING_DOWN;
            END_IF;
            
        STATE_CLEANING_DOWN:
            IF LowerLimit = TRUE THEN
                state := STATE_IDLE;
            END_IF;
            
        STATE_EMERGENCY_STOP:
            (* Remain in emergency stop until EmergencyStop is released *)
            IF EmergencyStop = FALSE THEN
                state := STATE_IDLE;
            END_IF;
    END_CASE;
END_IF;

(* Manage CleaningInProgress flag *)
IF state = STATE_MOVING_UP AND prevState = STATE_IDLE THEN
    CleaningInProgress := TRUE;
ELSIF (state = STATE_IDLE AND prevState = STATE_CLEANING_DOWN) OR 
      (state = STATE_EMERGENCY_STOP AND prevState <> STATE_EMERGENCY_STOP) THEN
    CleaningInProgress := FALSE;
END_IF;

(* Set outputs based on current state *)
CASE state OF
    STATE_IDLE:
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        
    STATE_MOVING_UP:
        ElevatorUp := TRUE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
        
    STATE_CLEANING_DOWN:
        ElevatorUp := FALSE;
        ElevatorDown := TRUE;
        RotateClockwise := TRUE;
        WaterPump := TRUE;
        
    STATE_EMERGENCY_STOP:
        ElevatorUp := FALSE;
        ElevatorDown := FALSE;
        RotateClockwise := FALSE;
        WaterPump := FALSE;
END_CASE;

(* Store previous state for edge detection *)
prevState := state;

END_FUNCTION_BLOCK
END_ST