START_REASON
The previous code failed CODESYS compiler validation with the error "应该用';' 替换'IF'" (Should replace 'IF' with ';'). This indicates a syntax error where the `IF` keyword was likely placed incorrectly, possibly missing a semicolon before it or in a context where an assignment or statement was expected instead of a control flow start.

Upon reviewing the generated code, the structure appears standard, but the specific error message suggests a potential issue with how the compiler interprets the start of the `IF` statement in the context of the specific toolchain version or a hidden formatting issue. However, the most common cause for this specific error in IEC 61131-3 when "IF" is flagged is often related to:
1.  Missing semicolons at the end of the preceding line immediately before the `IF`.
2.  Using `IF` as a variable name (not the case here).
3.  A specific quirk where the toolchain expects a semicolon after the `END_VAR` of the input/output sections if they are followed by `VAR` without a blank line, though standard parsers handle this fine.

Given the strict feedback "Replace 'IF' with ';'", it implies the toolchain sees a token stream where an `IF` is unexpected or the preceding statement wasn't terminated. To ensure absolute compliance and robustness, I will:
1.  Add explicit semicolons after every single statement within the `CASE` and `IF` blocks to prevent any ambiguity.
2.  Ensure the `END_VAR` after `VAR_INPUT` and `VAR_OUTPUT` is clearly separated.
3.  Double-check that no `IF` is accidentally used as a variable name or in a declaration context.
4.  Maintain the logic flow while ensuring every statement ends with `;`.

END_REASON

START_ST
FUNCTION_BLOCK CoffeeMachineControl
VAR_INPUT
    StartButton : BOOL;
    ElapsedTime : DINT;
END_VAR

VAR_OUTPUT
    WaterHeating : BOOL;
    GrinderRunning : BOOL;
    Brewing : BOOL;
    GrinderFinished : BOOL;
    WaterHeated : BOOL;
    CoffeeReady : BOOL;
END_VAR

VAR
    CurrentState : INT := 0;
    WaterHeatingDuration : DINT := 30000; (* 30 seconds *)
    GrindingDuration : DINT := 10000; (* 10 seconds *)
    BrewingDuration : DINT := 60000; (* 60 seconds *)
    Timer : DINT := 0;
END_VAR

BEGIN
    (* Reset timers if state changes *)
    IF CurrentState <> 0 THEN
        Timer := 0;
    END_IF;

    (* Handle Start Button Logic *)
    IF StartButton = TRUE THEN
        StartButton := FALSE; (* Debounce: Prevent multiple triggers *)
        CurrentState := 1; (* Transition to HEATING_WATER *)
        Timer := 0;
    END_IF;

    (* State Machine Logic *)
    CASE CurrentState OF
        0: (* STATE 0: IDLE *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            GrinderFinished := FALSE;
            WaterHeated := FALSE;
            CoffeeReady := FALSE;
            Timer := 0;
        1: (* STATE 1: HEATING_WATER *)
            WaterHeating := TRUE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            GrinderFinished := FALSE;
            WaterHeated := FALSE;
            CoffeeReady := FALSE;
            IF Timer >= WaterHeatingDuration THEN
                WaterHeating := FALSE;
                WaterHeated := TRUE;
                CurrentState := 2; (* Transition to GRINDING *)
                Timer := 0;
            END_IF;
        2: (* STATE 2: GRINDING *)
            WaterHeating := FALSE;
            GrinderRunning := TRUE;
            Brewing := FALSE;
            GrinderFinished := FALSE;
            WaterHeated := TRUE;
            CoffeeReady := FALSE;
            IF Timer >= GrindingDuration THEN
                GrinderRunning := FALSE;
                GrinderFinished := TRUE;
                CurrentState := 3; (* Transition to BREWING *)
                Timer := 0;
            END_IF;
        3: (* STATE 3: BREWING *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := TRUE;
            GrinderFinished := TRUE;
            WaterHeated := TRUE;
            CoffeeReady := FALSE;
            IF Timer >= BrewingDuration THEN
                Brewing := FALSE;
                CoffeeReady := TRUE;
                CurrentState := 4; (* Transition to READY *)
                Timer := 0;
            END_IF;
        4: (* STATE 4: READY *)
            WaterHeating := FALSE;
            GrinderRunning := FALSE;
            Brewing := FALSE;
            GrinderFinished := TRUE;
            WaterHeated := TRUE;
            CoffeeReady := TRUE;
            Timer := 0;
    END_CASE;

    (* Increment Timer *)
    IF ElapsedTime > Timer THEN
        Timer := ElapsedTime;
    END_IF;

END_FUNCTION_BLOCK
END_ST