START_REASON
The previous code failed CODESYS validation with the error "发现非预期的记号'VAR'" (Unexpected token 'VAR'). This indicates that the `VAR` keyword was placed in an invalid location or the structure was malformed.

In IEC 61131-3 Structured Text:
1.  **Function Blocks (FB)** must start with `FUNCTION_BLOCK Name`.
2.  Immediately after the name, the **Variable Declarations** section begins. This section contains `VAR_INPUT`, `VAR_OUTPUT`, `VAR_IN_OUT`, and `VAR`.
3.  The `VAR` keyword is used for **local variables** that are not inputs or outputs.
4.  Crucially, the `BEGIN` keyword must come **after** all variable declarations are closed.
5.  The previous code structure looked correct at a glance, but the error suggests a potential issue with how the variables were grouped or if there was a missing newline/whitespace that confused the parser in the specific toolchain environment, or perhaps the `VAR` section was not properly closed before `BEGIN`.
6.  However, looking closely at standard strict parsers, the structure `FUNCTION_BLOCK ... VAR_INPUT ... END_VAR; VAR_OUTPUT ... END_VAR; VAR ... END_VAR; BEGIN ... END_FUNCTION_BLOCK;` is the correct standard.
7.  The error "Unexpected token 'VAR'" often happens if the `VAR` keyword is used where only `VAR_INPUT`/`OUTPUT` are expected, OR if the previous `END_VAR` was missing or malformed.
8.  In the previous attempt, I had:
    ```
    VAR_INPUT
        Enable : BOOL;
    END_VAR
    VAR_OUTPUT
        TimeoutOccurred : BOOL;
    END_VAR
    VAR
        RequestTimeout : TIME;
        TimerElapsed : BOOL;
    BEGIN  <-- Missing END_VAR here!
    ```
    **Correction**: The `VAR` section for local variables **must** be closed with `END_VAR` before the `BEGIN` keyword starts the executable logic. The previous code missed `END_VAR` after the local variables (`RequestTimeout`, `TimerElapsed`).

I will now generate the corrected code ensuring `END_VAR` closes the `VAR` section immediately before `BEGIN`.
END_REASON

START_ST
FUNCTION_BLOCK RequestHandler
VAR_INPUT
    Enable : BOOL;
END_VAR
VAR_OUTPUT
    TimeoutOccurred : BOOL;
END_VAR
VAR
    RequestTimeout : TIME;
    TimerElapsed : BOOL;
END_VAR
BEGIN
    IF Enable THEN
        RequestTimeout := T#5s;
        TimerElapsed := FALSE;
    END_IF;

    IF RequestTimeout > T#0s THEN
        TimerElapsed := TRUE;
        TimeoutOccurred := TRUE;
    ELSE
        TimeoutOccurred := FALSE;
    END_IF;
END_FUNCTION_BLOCK
END_ST