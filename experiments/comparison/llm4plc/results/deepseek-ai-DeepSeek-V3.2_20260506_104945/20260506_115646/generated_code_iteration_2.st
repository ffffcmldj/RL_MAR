START_REASON
The feedback indicates an encoding issue with the CODESYS compiler validation: "gbk' codec can't decode byte 0xaf in position 93: illegal multibyte sequence". This suggests that there are non-ASCII characters or special characters in the code that the compiler cannot decode properly. The error occurs at position 93, which likely points to a specific character in the code. Given the previous code, the issue might be in the comment sections or variable names that contain non-standard characters. Since the code is in English, the problem could be with the comment delimiters or hidden characters introduced during copying. To fix this, I will ensure all comments use standard ASCII characters and remove any potential non-ASCII characters. I'll rewrite the code with clean comments and verify that all text is within the ASCII range. Additionally, I'll ensure the structure is correct to prevent any syntax errors.
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

CONST
    STATE_IDLE : INT := 0;
    STATE_MOVING_UP : INT := 1;
    STATE_CLEANING_DOWN : INT := 2;
    STATE_EMERGENCY_STOP : INT := 3;
END_CONST

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
            IF EmergencyStop = FALSE THEN
                state := STATE_IDLE;
            END_IF;
    END_CASE;
END_IF;

IF state = STATE_MOVING_UP AND prevState = STATE_IDLE THEN
    CleaningInProgress := TRUE;
ELSIF (state = STATE_IDLE AND prevState = STATE_CLEANING_DOWN) OR 
      (state = STATE_EMERGENCY_STOP AND prevState <> STATE_EMERGENCY_STOP) THEN
    CleaningInProgress := FALSE;
END_IF;

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

prevState := state;

END_FUNCTION_BLOCK
END_ST