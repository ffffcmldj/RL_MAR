START_REASON
The previous validation feedback indicates a persistent encoding error: `'gbk' codec can't decode byte 0xaf in position 117`. This confirms that the code generation process is inadvertently introducing non-ASCII characters (likely from the previous reasoning block containing Chinese text or hidden BOM markers) into the final code block.

To fix this:
1.  **Strict ASCII/UTF-8 Compliance**: I will ensure the entire code block contains only standard ASCII characters (0-127). No comments will contain non-English text.
2.  **Syntax Correction**: I will adhere to the specific compiler requirement to place a semicolon `;` immediately after the `IF` keyword, as requested by the toolchain feedback ("Should replace 'IF' with ';'", interpreted as `IF condition; THEN`).
3.  **Structure Integrity**: I will ensure all `IF` blocks are closed with `END_IF`, variables are closed with `END_VAR`, and the function block is closed with `END_FUNCTION_BLOCK`.
4.  **Logic Verification**: The state machine logic will be preserved but cleaned of any potential encoding artifacts.
END_REASON

START_ST
FUNCTION_BLOCK VehicleControl
VAR_INPUT
    VehicleCount1 : INT;
    VehicleCount2 : INT;
    CurrentState  : INT;
END_VAR

VAR
    OutputSignal1 : BOOL;
    OutputSignal2 : BOOL;
    TempLight1    : BOOL;
    TempLight2    : BOOL;
    TransitionFlag: BOOL;
END_VAR

VAR_OUTPUT
    Light1 : BOOL;
    Light2 : BOOL;
    Alarm  : BOOL;
END_VAR

BEGIN
    (* Initialize outputs *)
    Light1 := FALSE;
    Light2 := FALSE;
    Alarm  := FALSE;
    TransitionFlag := FALSE;

    (* STATE 0: Initial State *)
    IF CurrentState = 0; THEN
        OutputSignal1 := FALSE;
        OutputSignal2 := FALSE;
        Light1 := FALSE;
        Light2 := FALSE;
        Alarm := FALSE;
    END_IF;

    (* STATE 1: Counting Vehicles 1 *)
    IF CurrentState = 1; THEN
        IF VehicleCount1 > VehicleCount2; THEN
            TempLight1 := TRUE;
            Light1 := TRUE;
            TransitionFlag := TRUE;
        ELSE
            TempLight1 := FALSE;
            Light1 := FALSE;
        END_IF;
    END_IF;

    (* STATE 2: Counting Vehicles 2 *)
    IF CurrentState = 2; THEN
        IF VehicleCount2 > VehicleCount1; THEN
            TempLight2 := TRUE;
            Light2 := TRUE;
            TransitionFlag := TRUE;
        ELSE
            TempLight2 := FALSE;
            Light2 := FALSE;
        END_IF;
    END_IF;

    (* STATE 3: Error/Alarm State *)
    IF CurrentState = 3; THEN
        Alarm := TRUE;
        Light1 := FALSE;
        Light2 := FALSE;
    END_IF;

    (* Default State Handling *)
    IF CurrentState <> 0; AND CurrentState <> 1; AND CurrentState <> 2; AND CurrentState <> 3; THEN
        Light1 := FALSE;
        Light2 := FALSE;
        Alarm := FALSE;
    END_IF;

    (* Output Assignment based on Transition Flag *)
    IF TransitionFlag; THEN
        OutputSignal1 := Light1;
        OutputSignal2 := Light2;
        TransitionFlag := FALSE;
    END_IF;

END_FUNCTION_BLOCK
END_ST