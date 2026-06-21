START_REASON
The previous code failed validation due to an encoding error: 'gbk' codec can't decode byte 0xa2 in position 35: illegal multibyte sequence. This indicates that the comment character `(*` or the content within the comments contains non-ASCII characters (likely Chinese characters like `(* Represents milliseconds...` or similar) that are not compatible with the GBK encoding expected by the ANTLR parser and CODESYS compiler. Structured Text compilers often require strict ASCII compliance for comments unless specific Unicode settings are enabled, which are not guaranteed here. To fix this, I must replace all comments containing non-ASCII characters with ASCII-safe equivalents or remove them entirely. Additionally, I will ensure the code structure remains strictly compliant with the FUNCTION_BLOCK requirements.
END_REASON

START_ST
FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT;
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    CurrentState : INT;
    DoorOpenDuration : DINT := 5000;
END_VAR

BEGIN
    CASE CurrentState OF
        0:
            IF ProximitySensor THEN
                CurrentState := 1;
            END_IF;
            
        1:
            IF (NOT ProximitySensor) OR (ElapsedTime >= DoorOpenDuration) THEN
                CurrentState := 2;
            END_IF;
            
        2:
            CurrentState := 0;
    END_CASE;

    DoorOpen := (CurrentState = 1);

END_FUNCTION_BLOCK
END_ST