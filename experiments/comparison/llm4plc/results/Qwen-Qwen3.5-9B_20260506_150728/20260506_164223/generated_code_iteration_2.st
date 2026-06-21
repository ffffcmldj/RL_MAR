START_REASON
The previous code generation failed due to a character encoding issue. The error message "illegal multibyte sequence" at position 78 indicates that the string literal comments (e.g., `(* IDLE *)`) contained non-ASCII characters (likely Chinese characters like "空闲", "分拣", etc., which were not properly escaped or encoded in the UTF-8/ASCII context required by the ANTLR parser and CODESYS compiler).

The compiler expects standard ASCII characters within string literals and comments. To fix this, I will:
1.  Remove all non-ASCII characters from the code, including comments.
2.  Replace descriptive Chinese comments with standard English keywords or simple ASCII placeholders.
3.  Ensure the logic remains identical to the previous iteration (using `CASE` statements for state transitions to avoid the previous "IF" syntax error, and ensuring all semicolons are correctly placed).
4.  Verify that all variable declarations and block structures (`FUNCTION_BLOCK`, `VAR_INPUT`, `VAR_OUTPUT`, `VAR`, `BEGIN`, `END`) are syntactically correct according to IEC 61131-3.

The logic will be:
-   **State 0 (Idle):** If Red -> State 1; If Green -> State 2; If Blue -> State 3.
-   **State 1 (Sort Red):** If Red not detected -> State 0; If Green -> State 2; If Blue -> State 3.
-   **State 2 (Sort Green):** If Green not detected -> State 0; If Red -> State 1; If Blue -> State 3.
-   **State 3 (Sort Blue):** If Blue not detected -> State 0; If Red -> State 1; If Green -> State 2.
-   **Outputs:** Set `RoboticArmMove` and the corresponding `Bin` output based on the final `currentState`.

This approach ensures the code is valid ST, free of encoding errors, and robust against the specific parser issues encountered previously.
END_REASON
START_ST
FUNCTION_BLOCK RoboticArmColorSorting
VAR_INPUT
    ColorSensorRed : BOOL;
    ColorSensorGreen : BOOL;
    ColorSensorBlue : BOOL;
END_VAR

VAR_OUTPUT
    RoboticArmMove : BOOL := FALSE;
    BinRed : BOOL := FALSE;
    BinGreen : BOOL := FALSE;
    BinBlue : BOOL := FALSE;
END_VAR

VAR
    currentState : INT := 0;
END_VAR

BEGIN
    (* Transition Logic *)
    CASE currentState OF
        0:
            IF ColorSensorRed THEN
                currentState := 1;
            ELSIF ColorSensorGreen THEN
                currentState := 2;
            ELSIF ColorSensorBlue THEN
                currentState := 3;
            END_IF;
        1:
            IF NOT ColorSensorRed THEN
                currentState := 0;
            ELSIF ColorSensorGreen THEN
                currentState := 2;
            ELSIF ColorSensorBlue THEN
                currentState := 3;
            END_IF;
        2:
            IF NOT ColorSensorGreen THEN
                currentState := 0;
            ELSIF ColorSensorRed THEN
                currentState := 1;
            ELSIF ColorSensorBlue THEN
                currentState := 3;
            END_IF;
        3:
            IF NOT ColorSensorBlue THEN
                currentState := 0;
            ELSIF ColorSensorRed THEN
                currentState := 1;
            ELSIF ColorSensorGreen THEN
                currentState := 2;
            END_IF;
    END_CASE;

    (* Output Assignment *)
    CASE currentState OF
        0:
            RoboticArmMove := FALSE;
            BinRed := FALSE;
            BinGreen := FALSE;
            BinBlue := FALSE;
        1:
            RoboticArmMove := TRUE;
            BinRed := TRUE;
            BinGreen := FALSE;
            BinBlue := FALSE;
        2:
            RoboticArmMove := TRUE;
            BinRed := FALSE;
            BinGreen := TRUE;
            BinBlue := FALSE;
        3:
            RoboticArmMove := TRUE;
            BinRed := FALSE;
            BinGreen := FALSE;
            BinBlue := TRUE;
    END_CASE;

END_FUNCTION_BLOCK
END_ST