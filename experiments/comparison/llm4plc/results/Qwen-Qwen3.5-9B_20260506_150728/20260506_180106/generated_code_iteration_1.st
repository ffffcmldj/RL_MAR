START_REASON
The validation feedback indicates a specific syntax error detected by the CODESYS compiler: "应该用';' 替换'IF'" (Should replace 'IF' with ';').

In IEC 61131-3 Structured Text (ST), the `IF` statement is a control structure. However, the error message strongly suggests that the compiler is interpreting the logic incorrectly or there is a missing semicolon causing a parsing conflict where an `IF` keyword is expected to be a statement terminator or part of a different construct in the specific context the toolchain is analyzing (often related to how the toolchain parses the block structure or if there was a hidden character issue).

However, looking closely at the standard ST syntax, `IF ... THEN ... END_IF;` is correct. The error "replace IF with ;" is highly unusual for valid ST unless:
1. There is a missing semicolon at the end of a line immediately preceding an `IF` that causes a cascade error.
2. The toolchain is misinterpreting the structure.
3. Most likely in automated toolchain contexts for ST: The `END_FUNCTION_BLOCK` statement is missing a semicolon at the end, or a previous line inside the block is missing a semicolon, causing the parser to get confused about where the block ends or how statements are terminated.

Let's re-examine the code structure.
- `IF EmergencyStop THEN ... END_IF;` (Correct)
- `IF StartButton ... THEN ... END_IF;` (Correct)
- `IF StopButton ... THEN ... END_IF;` (Correct)
- `IF BeltRunning THEN ... END_IF;` (Correct)
- `END_FUNCTION_BLOCK` (Missing semicolon at the end of the line).

In strict CODESYS compilers, `END_FUNCTION_BLOCK` does not strictly require a semicolon, but some strict parsers or specific toolchain configurations (especially when wrapping code in larger structures) expect a semicolon to terminate the statement block if it's treated as a statement. However, the specific error "replace IF with ;" is very peculiar.

Wait, let's look at the error again: "应该用';' 替换'IF'". This often happens when the compiler expects a semicolon to terminate a previous statement, but finds an `IF` instead. This usually implies a missing semicolon at the end of a line *before* the `IF`.
In the provided code:
`RETURN; (* Exit the function block immediately *)` -> Ends with semicolon.
`END_IF;` -> Ends with semicolon.

Is it possible the error refers to the `END_FUNCTION_BLOCK`? No, that doesn't match "replace IF".

Let's consider the possibility that the toolchain expects the `IF` statements to be wrapped or formatted differently, OR, more likely, there is a subtle syntax issue with the `RETURN` statement or the variable initialization.
Actually, in some strict implementations, if a line ends without a semicolon and the next line starts with `IF`, it fails.
Line: `RETURN; (* Exit the function block immediately *)` -> Has semicolon.
Line: `END_IF;` -> Has semicolon.

Let's look at the `END_FUNCTION_BLOCK`. In many CODESYS versions, `END_FUNCTION_BLOCK` is a statement and should end with a semicolon if it is the last statement in the block, although it is often optional. If the toolchain is strict, adding a semicolon there is safe.

However, the specific error "replace IF with ;" suggests the parser saw something like `... ; IF ...` where it expected `... ; ; IF` or similar, OR it saw `... IF` where it expected `... ; IF`.
Wait, could it be the `IF` inside the `IF BeltRunning` block?
`IF ConveyorTimer >= RotationTime THEN`
`    ConveyorMotor := FALSE;`
`    ...`
`END_IF;`

Let's reconsider the standard fix for "replace IF with ;". This is a known hallucination or specific error in some code generators where they output `IF` without a preceding semicolon if the previous line didn't have one.
In the provided code:
`END_IF;` is followed by a comment `(* STEP 2... *)`.
Then `IF StartButton...`.
Comments do not need semicolons.

Hypothesis: The toolchain is complaining about the `END_FUNCTION_BLOCK` line. If the toolchain treats the entire block as a sequence of statements, the final `END_FUNCTION_BLOCK` might need a semicolon. But the error says "replace IF".

Alternative Hypothesis: The error is actually about the `IF` statements themselves being used in a context where a semicolon is required before them? No, that's not standard ST.

Let's look at the `RETURN` statement. `RETURN;` is correct.
Let's look at the variable declarations. `END_VAR` is correct.

Is it possible the error is a false positive from the toolchain description provided in the prompt, and the real issue is simply ensuring every statement ends with a semicolon, including the `END_FUNCTION_BLOCK`?
Actually, there is a specific pattern in some compilers where if you have:
`Statement1;`
`IF Statement2 THEN`
It works.
But if you have:
`Statement1` (Missing semicolon)
`IF Statement2 THEN`
It fails.

Let's check every line ending.
`END_VAR` (No semicolon needed, it's a declaration terminator).
`END_IF;` (Has semicolon).
`END_FUNCTION_BLOCK` (Missing semicolon).

If I add a semicolon to `END_FUNCTION_BLOCK`, does it fix "replace IF with ;"?
Maybe the toolchain interprets the missing semicolon on `END_FUNCTION_BLOCK` as a syntax error that cascades, and the specific error message is garbled or refers to the `IF` that follows in a recursive check?

Wait, I found a similar issue in other contexts. Sometimes, if the `IF` statement is the very first thing in the block, and the previous line (like `END_VAR`) didn't have a semicolon, it might trigger this. But `END_VAR` doesn't need one.

Let's try a different angle. The error "应该用';' 替换'IF'" literally means "Should use ';' to replace 'IF'". This is extremely specific. It implies the compiler thinks `IF` should be a semicolon. This happens if the parser is in a state expecting a statement terminator and encounters `IF`.
This usually means the line *before* the `IF` was not terminated with a semicolon.
Line before `IF EmergencyStop`: `END_VAR`.
Line before `IF StartButton`: `END_IF;`.
Line before `IF StopButton`: `END_IF;`.
Line before `IF BeltRunning`: `END_IF;`.

Is it possible the comments are interfering? No.
Is it possible the `END_FUNCTION_BLOCK` needs a semicolon, and the toolchain's error message is misleadingly pointing to the next `IF` in a nested check?

Let's assume the safest bet for CODESYS ST: Ensure every executable statement ends with a semicolon.
1. `RETURN;` is there.
2. `END_IF;` is there.
3. `END_FUNCTION_BLOCK` -> Add semicolon.

Wait, looking at the error again. "replace IF with ;".
Could it be that the toolchain expects the `IF` to be part of a `CASE` or something? No.
Could it be that the `IF` keyword is being confused with a variable? No.

Let's look at the `END_VAR` section.
`END_VAR` closes the variable section.
Then `BEGIN`.
Then `IF`.

Maybe the issue is the `END_FUNCTION_BLOCK` line. In some strict configurations, `END_FUNCTION_BLOCK` MUST end with a semicolon. If it doesn't, the compiler might report an error on the next line or the end of the file. The specific message "replace IF with ;" might be a translation artifact or a specific error code mapping where the parser got out of sync.

However, there is one more possibility. The `IF` statements are compound.
`IF StartButton AND NOT BeltRunning THEN`
This is valid.

Let's try to fix the code by ensuring `END_FUNCTION_BLOCK` has a semicolon, and double-checking all other terminators. Also, I will ensure the `END_VAR` line has a semicolon just in case the toolchain is hyper-strict about declaration blocks (though standard ST doesn't require it, some tools do).

Actually, looking at the error "replace IF with ;", it is highly probable that the toolchain is parsing the `END_FUNCTION_BLOCK` without a semicolon, and because it's the end of the block, it expects a semicolon. The error message might be pointing to the `IF` that *would* follow if this were inside a larger loop, or it's a specific toolchain quirk.

Let's add the semicolon to `END_FUNCTION_BLOCK`.
Also, I will add a semicolon to `END_VAR` just to be safe, as some strict parsers treat the end of a variable block as a statement.

Wait, I missed something. Is `RETURN` allowed in a `FUNCTION_BLOCK`? Yes.
Is `END_IF` allowed? Yes.

Let's refine the plan:
1. Add semicolon to `END_FUNCTION_BLOCK`.
2. Add semicolon to `END_VAR` (optional but safe).
3. Ensure all `END_IF` have semicolons (they do).
4. Ensure all assignments have semicolons (they do).

One more check: The error says "replace IF with ;".
If I have:
`... ;`
`IF ...`
It works.
If I have:
`...` (no semicolon)
`IF ...`
It fails.

Where could the missing semicolon be?
`END_VAR` does not need a semicolon.
`END_IF` has a semicolon.
`RETURN` has a semicolon.

Is it possible the `IF` inside `IF BeltRunning` is the issue?
`IF ConveyorTimer >= RotationTime THEN`
This is inside the `IF BeltRunning` block.
The line before it is `ConveyorTimer := ConveyorTimer + 1;`. This has a semicolon.

Okay, let's look at the `END_FUNCTION_BLOCK` again.
If the toolchain considers the `END_FUNCTION_BLOCK` as a statement that must end with a semicolon, and it's missing, that's the most likely culprit for a syntax error at the end of the file. The specific error message might be a red herring or a specific mapping for "unexpected token at end of block".

Let's generate the code with `END_FUNCTION_BLOCK;` and `END_VAR;` to be absolutely sure.

START_ST
FUNCTION_BLOCK SushiConveyorControl
VAR_INPUT
    StartButton : BOOL; (* Input to start the conveyor *)
    StopButton : BOOL; (* Input to stop the conveyor *)
    EmergencyStop : BOOL; (* Input for emergency stop *)
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL; (* Output to control the conveyor motor *)
END_VAR
VAR
    BeltRunning : BOOL; (* Status of the conveyor: Running or Stopped *)
    ConveyorTimer : INT; (* Timer counter for conveyor rotation *)
    RotationTime : INT := 5; (* Time for one rotation in seconds *)
END_VAR;

BEGIN
    (* ----------------------------------------------------------- *)
    (* STEP 1: EMERGENCY STOP (HIGHEST PRIORITY)                   *)
    (* If EmergencyStop is TRUE, halt everything immediately.      *)
    (* ----------------------------------------------------------- *)
    IF EmergencyStop THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
        RETURN; (* Exit the function block immediately *)
    END_IF;

    (* ----------------------------------------------------------- *)
    (* STEP 2: START CONTROL                                       *)
    (* Start if button is pressed and conveyor is not running.     *)
    (* ----------------------------------------------------------- *)
    IF StartButton AND NOT BeltRunning THEN
        ConveyorMotor := TRUE;
        BeltRunning := TRUE;
        ConveyorTimer := 0;
    END_IF;

    (* ----------------------------------------------------------- *)
    (* STEP 3: STOP CONTROL                                         *)
    (* Stop if button is pressed and conveyor is currently running. *)
    (* ----------------------------------------------------------- *)
    IF StopButton AND BeltRunning THEN
        ConveyorMotor := FALSE;
        BeltRunning := FALSE;
        ConveyorTimer := 0;
    END_IF;

    (* ----------------------------------------------------------- *)
    (* STEP 4: SIMULATED ROTATION (TIMED ON/OFF CYCLE)              *)
    (* Logic executes only if the conveyor is running.             *)
    (* ----------------------------------------------------------- *)
    IF BeltRunning THEN
        (* Increment the timer *)
        ConveyorTimer := ConveyorTimer + 1;

        (* Check if the timer has reached the rotation limit *)
        IF ConveyorTimer >= RotationTime THEN
            (* Cycle Complete: Turn off motor and reset state *)
            ConveyorMotor := FALSE;
            BeltRunning := FALSE;
            ConveyorTimer := 0;
        END_IF;
        (* Else: Timer < RotationTime, ConveyorMotor remains TRUE *)
    END_IF;

END_FUNCTION_BLOCK;
END_ST
END_REASON