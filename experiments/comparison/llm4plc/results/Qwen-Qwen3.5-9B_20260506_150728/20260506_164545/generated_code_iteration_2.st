START_REASON
The previous attempt failed because the `point_type` structure was defined in the global scope, but the CODESYS compiler still reported "Unknown type: 'point_type'". This usually happens in CODESYS when:
1. The `TYPE` definition is not recognized as a global type due to missing `PROGRAM` or `FUNCTION_BLOCK` context in some strict configurations, or more likely,
2. The variable declaration inside the `FUNCTION_BLOCK` `VAR_OUTPUT` section is referencing the type before the compiler has fully processed the global scope in a single pass, or
3. Most critically, in many CODESYS versions, defining a `TYPE` directly in the global scope without a surrounding `PROGRAM` or `FUNCTION_BLOCK` wrapper (or using the specific `TYPE` keyword correctly in the global namespace) can sometimes be ambiguous if the file structure isn't strictly followed.

However, the most robust solution in CODESYS Structured Text to ensure a type is visible to all blocks is to define it globally using the standard `TYPE ... END_TYPE` syntax, but ensure there are no syntax errors preventing the parser from seeing it.

Wait, looking closer at the error and the code structure: The code provided in the "START_ST" block *did* put the TYPE at the top. Why did it fail?
Ah, the error "Unknown type" often persists if the type definition itself has a syntax error or if the compiler version requires the type to be defined within a `PROGRAM` or `FUNCTION_BLOCK` if it's not a global library type, OR (and this is common in IDEs) the `TYPE` definition must be outside any block, which it was.

Let's re-evaluate the specific CODESYS constraint. In CODESYS, `TYPE` definitions are allowed in the global scope. However, sometimes if the file is treated as a specific block file, global types might not be visible unless the file is a "Global" file or the type is defined inside a `PROGRAM` that is instantiated.

Actually, the most common reason for this specific error in a standalone snippet provided to a compiler is that the `TYPE` definition is syntactically correct, but the compiler context expects the type to be defined *inside* the block if it's not a standard library type, OR the `END_TYPE` is missing or malformed.

Let's look at the generated code again:
```
TYPE point_type :
    STRUCT
        X : INT;
        Y : INT;
    END_STRUCT;
END_TYPE
```
This looks correct.

Is it possible the issue is that `point_type` is used in `VAR_OUTPUT` but the compiler hasn't parsed the global scope yet? No, that's not how ST works.

Alternative hypothesis: The user's environment might require the type to be defined inside a `PROGRAM` or `FUNCTION_BLOCK` if it's not a global file. But standard ST allows global types.

Let's try a different approach that is guaranteed to work in CODESYS: Define the type inside a dummy `PROGRAM` or simply ensure the `TYPE` is strictly global.
Wait, I see a potential issue in the logic of the previous response. The previous response said "Move the TYPE... to the global scope". The code *did* do that.
Perhaps the error is actually about the `VAR_OUTPUT` declaration? No, `point_type` is a valid type.

Let's reconsider the "Unknown type" error. In some CODESYS configurations, if you define a `TYPE` in the global scope of a file that is meant to be a `FUNCTION_BLOCK` file, it might not be exported correctly.
However, the most reliable fix that works across all CODESYS versions for custom types used in FBs is to define the `TYPE` globally, but ensure the syntax is perfect.

Wait, I missed a subtle point. In the previous code, the `TYPE` definition was:
```
TYPE point_type :
    STRUCT
        X : INT;
        Y : INT;
    END_STRUCT;
END_TYPE
```
This is correct.

Is it possible the error is actually due to the `FUNCTION_BLOCK` definition itself? No.

Let's try to define the `TYPE` inside a `PROGRAM` block that is never called, or just ensure the global scope is clean.
Actually, there is a known quirk: If the file is saved as a `.st` file containing only FBs, global types should work.
Maybe the issue is that the `TYPE` definition needs to be separated by a newline from the first `FUNCTION_BLOCK`? It was.

Let's try a different strategy: Define the `TYPE` inside the `FUNCTION_BLOCK` itself? No, that creates a local type which is fine, but the error says "Unknown type", implying it's looking for a global one or the local one isn't being resolved. If I define it inside the FB, it should be known.
BUT, the requirement is to maintain the structure.

Let's look at the error again: "未知的类型: 'point_type'".
If I define `point_type` inside `FB_PointOperations`, it is local to that FB. `FB_ExpandedPoint` uses `point_type`? No, `FB_ExpandedPoint` uses `INT`.
Wait, `FB_ExpandedPoint` does NOT use `point_type`. Only `FB_PointOperations` uses it.
So if `point_type` is global, `FB_PointOperations` should see it.
If `point_type` is local to `FB_PointOperations`, it should also see it.

Why did the global definition fail?
Maybe the compiler requires the `TYPE` to be defined in a `PROGRAM` block if it's not a global library?
Let's try defining the `TYPE` inside a `PROGRAM` block that acts as a namespace, or simply ensure the `TYPE` is the very first thing.

Actually, there is a simpler explanation. In some IDEs, if you define a `TYPE` in the global scope, you must ensure it is not inside a `FUNCTION_BLOCK` (which it wasn't).
Is it possible the `END_TYPE` was missing in the user's mind? No, it was there.

Let's try to define the `TYPE` inside the `FUNCTION_BLOCK` `FB_PointOperations`. This guarantees visibility for that block without relying on global scope resolution which might be failing in the specific toolchain environment.
Wait, if I move it inside, `FB_ExpandedPoint` doesn't need it. So that solves the visibility issue for the specific block.
However, the prompt implies `point_type` is a shared concept? No, only `FB_PointOperations` uses it.
So, defining `point_type` inside `FB_PointOperations` is the safest bet to avoid global scope issues in this specific toolchain context.

Revised Plan:
1. Keep `FB_PointOperations`.
2. Move `TYPE point_type` definition *inside* `FB_PointOperations`, before the `VAR_INPUT` section.
3. Keep `FB_ExpandedPoint` as is (it doesn't use `point_type`).
4. Ensure `START_ST` and `END_ST` are present.
5. Ensure `END_VAR` is used correctly.

This avoids the "Global Type" ambiguity entirely.

START_ST
FUNCTION_BLOCK FB_PointOperations
VAR
    TYPE point_type :
        STRUCT
            X : INT;
            Y : INT;
        END_STRUCT;
    END_TYPE;

VAR_INPUT
    INPUT_VAR2 : INT := 7;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR1 : point_type;
    OUTPUT_VAR3 : point_type;
END_VAR

VAR
    VAR2 : INT;
END_VAR

BEGIN
    (* Assign input to internal variable *)
    VAR2 := INPUT_VAR2;

    (* Set OUTPUT_VAR1 coordinates *)
    OUTPUT_VAR1.X := 1;
    OUTPUT_VAR1.Y := 2;

    (* Set OUTPUT_VAR3 coordinates *)
    OUTPUT_VAR3.X := 100;
    OUTPUT_VAR3.Y := -7000;
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_ExpandedPoint
VAR_INPUT
    INPUT_VAR2 : INT;
    INPUT_VAR1_X : INT;
    INPUT_VAR1_Y : INT;
    INPUT_VAR3_X : INT := 1;
    INPUT_VAR3_Y : INT := 2;
END_VAR

VAR_OUTPUT
    OUTPUT_VAR2 : INT;
    OUTPUT_VAR1_X : INT;
    OUTPUT_VAR1_Y : INT;
    OUTPUT_VAR3_X : INT;
    OUTPUT_VAR3_Y : INT;
END_VAR

VAR
    state : INT;
END_VAR

BEGIN
    (* State Machine Logic *)
    (* STATE 0: INITIALIZE *)
    (* No outputs active, handled by sequential flow *)

    (* STATE 1: EXECUTE_POINT_OPERATIONS *)
    (* Logic: Assign inputs, set specific output values *)
    OUTPUT_VAR2 := INPUT_VAR2;
    OUTPUT_VAR1_X := 1;
    OUTPUT_VAR1_Y := 2;
    OUTPUT_VAR3_X := 100;
    OUTPUT_VAR3_Y := -7000;

    (* STATE 2: EXECUTE_EXPANDED_POINT_LOGIC *)
    (* Logic: Pass through expanded point inputs/outputs *)
    OUTPUT_VAR1_X := INPUT_VAR1_X;
    OUTPUT_VAR1_Y := INPUT_VAR1_Y;
    OUTPUT_VAR3_X := INPUT_VAR3_X;
    OUTPUT_VAR3_Y := INPUT_VAR3_Y;

    (* Note: In a real FSM, state transitions would be explicit.
       Here, the logic executes sequentially within the scan cycle
       as per the provided plan's transition requirements. *)
END_FUNCTION_BLOCK
END_ST