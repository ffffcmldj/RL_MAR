START_REASON
The validation feedback from CODESYS indicates a syntax error: "应该用';' 替换'IF'" (Should replace 'IF' with ';').

In IEC 61131-3 Structured Text (ST), the `IF` statement is a control structure, not a simple assignment or expression. However, the error message often arises when the compiler expects a statement terminator or when the structure is malformed in a way that looks like a missing semicolon after a conditional check that was intended to be an assignment (which is invalid logic, but syntactically distinct).

Looking closely at the provided code, the logic uses `IF ... THEN ... END_IF;` blocks correctly. However, there is a specific pattern in the original code where `Current_State := X;` is placed inside an `IF` block.

Wait, re-reading the specific error "replace 'IF' with ';'". This is a very specific and unusual error message for standard ST unless:
1. The `IF` keyword is being used where an assignment or expression is expected (e.g., `IF := TRUE` which is invalid).
2. There is a missing semicolon causing a parsing cascade where the parser gets confused.
3. **Most likely scenario in this context**: The user might have inadvertently written code that looks like `IF Condition THEN Action` but the compiler is complaining about the `IF` keyword itself, often implying that the line preceding it or the structure is broken.

However, looking at the provided code block again, there is a subtle issue often caught by strict compilers regarding the `ELSIF` chain. If the `IF` condition is evaluated and the compiler expects a statement immediately following without a `THEN` (which isn't the case here), or if there are missing semicolons at the end of lines *before* the `IF`.

Let's look at the line: `IF StartButton = TRUE AND EmergencyStop = FALSE THEN`. This is correct.

Is it possible the error refers to the `END_IF`? No.

Let's reconsider the error message "replace 'IF' with ';'". This sometimes happens if the code was generated or copied such that `IF` was used as a variable name or in a context where it's not a keyword, OR if the previous line ended without a semicolon and the parser is confused.

Actually, there is a known issue in some versions of CODESYS/ANTLR parsers where if an `IF` statement is the very first thing in a block without a preceding statement, or if the indentation/structure is slightly off, it might throw this.

BUT, the most probable cause for "replace IF with ;" in a generated code context is that the code generator tried to output an assignment like `IF := TRUE` (treating IF as a variable) or there is a missing semicolon before the `IF` keyword on a line that was supposed to be a statement.

Let's look at the code structure again.
`IF StartButton = TRUE AND EmergencyStop = FALSE THEN`
This is valid.

Wait, could it be related to the `ELSIF`?
In ST, `ELSIF` must follow an `IF` or another `ELSIF` immediately.
The code has:
`END_IF;`
`(* --- STATE 1 ... *)`
`ELSIF Current_State = 1 THEN`
This is valid.

Let's look at the error again. "应该用';' 替换'IF'".
This implies the compiler saw `IF` where it expected a `;`.
This happens if the line before `IF` did not end with a `;`.
Example:
`X := 5 IF Y THEN` -> Error.
But the code has:
`END_IF;`
`(* Comment *)`
`IF ...`
The comment line does not need a semicolon.

Is it possible the error is about the `IF` inside the `ELSIF` block?
`IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN`
This is valid.

Hypothesis: The error message is a translation artifact or a specific parser quirk indicating that a line ending with `IF` (without `THEN` on the same line or proper structure) was detected.
However, the most common reason for this specific error message in automated toolchains is that the code contains a line like:
`IF Condition` (missing `THEN`)
OR
`Statement IF Condition` (missing semicolon before IF).

Let's check the provided code for `Statement IF`.
There are no such lines.

Alternative Hypothesis: The error is actually about the `END_FUNCTION_BLOCK` line or the `END_ST` markers interfering, but the feedback says "ST output failed CODESYS compiler validation".

Let's assume the standard fix for "replace IF with ;" is to ensure every statement before an `IF` ends with a semicolon, and that the `IF` is not being misinterpreted.
Actually, looking at the code, there is a potential issue with the `ELSIF` chain if the initial `IF` is not closed properly or if the compiler is strict about the `IF` keyword placement.

Wait, I see a potential issue in the logic flow description vs code.
The code has `END_IF;` after the first `IF`.
Then `ELSIF`.
This is valid.

Let's look at the error message again. "应该用';' 替换'IF'".
Could it be that the `IF` keyword is missing a semicolon *after* it in a specific dialect? No, `IF` is a keyword.

Let's try a different angle. Maybe the error is not about the `IF` keyword itself, but the toolchain is misinterpreting a line that looks like `IF` but is actually something else? No.

Let's assume the error is due to a missing semicolon on the line immediately preceding an `IF` statement in the parser's eyes, often caused by a comment or a declaration that wasn't terminated.
In the code:
`END_VAR`
`VAR`
...
`END_VAR`
`BEGIN`
`(* --- STATE 0 ... *)`
`IF Current_State = 0 THEN`
This is fine.

Is it possible the error is in the `ELSIF` chain where the compiler expects a semicolon after the `END_IF` of the previous block?
`END_IF;` is present.

Let's consider the possibility that the error message is a generic "Syntax Error" translated poorly, and the real issue is the `ELSIF` usage.
In some strict implementations, if the `IF` condition is complex, it might require parentheses.
`IF StartButton = TRUE AND EmergencyStop = FALSE THEN` -> `IF (StartButton = TRUE) AND (EmergencyStop = FALSE) THEN`? No, `AND` is fine.

Let's look at the `END_FUNCTION_BLOCK` line.
`END_FUNCTION_BLOCK`
`END_ST`
This is correct.

Okay, let's look at the specific error "replace IF with ;".
This error occurs if the code contains:
`X := IF Y THEN Z;` (Invalid)
Or if the parser thinks `IF` is a variable name.

Wait! I found a similar issue in other contexts. If the code has:
`IF Condition THEN`
And the line before it is not terminated.
But here, `END_IF;` terminates the previous block.

Let's try to simplify the code structure to ensure robustness.
Maybe the issue is the `ELSIF` chain. If the first `IF` is not closed, `ELSIF` fails. But it is closed.

What if the error is actually about the `IF` inside the `ELSIF` block?
`IF UpperLimit = TRUE AND EmergencyStop = FALSE THEN`
If the compiler expects a semicolon before this `IF` because the previous line `Current_State := 2;` is followed by a comment?
`Current_State := 2; (* Transition ... *)`
`IF ...`
This is fine.

Let's consider the possibility that the error message is referring to the `IF` keyword being used in a context where it should be a semicolon, implying the `IF` statement is incomplete or misplaced.
Actually, there is a known bug in some versions of the CODESYS compiler where if an `IF` statement is the first executable statement in a block, and there is a comment before it, it might complain. But `(* --- STATE 0 ... *)` is a comment.

Let's try to fix the code by ensuring every single line that is a statement ends with a semicolon, and removing any ambiguity.
Also, I will add parentheses to the boolean expressions to ensure precedence is clear, which sometimes helps parsers.
And I will ensure the `IF` statements are on their own lines without preceding statements that might confuse the parser (though the code looks fine).

Wait, I suspect the error might be related to the `ELSIF` keyword. In some dialects, `ELSIF` must be preceded by a semicolon if it's not part of a continuous `IF-ELSIF-ELSE-END_IF` block without intervening statements.
Here:
`END_IF;`
`(* Comment *)`
`ELSIF ...`
This is valid.

Let's look at the error message one more time: "应该用';' 替换'IF'".
This literally means "Replace 'IF' with ';'".
This implies the token `IF` is where a `;` is expected.
This happens if the line is:
`Statement IF Condition`
Instead of:
`Statement;`
`IF Condition`

Is there any line in the code like that?
`Current_State := 1; (* Transition ... *)`
`IF UpperLimit = TRUE ...`
No.

Maybe the error is in the `VAR` section?
`VAR_INPUT` ... `END_VAR`
`VAR_OUTPUT` ... `END_VAR`
`VAR` ... `END_VAR`
`BEGIN`
`IF ...`
No.

Okay, let's assume the error is a false positive due to the comment style or the specific version of the compiler, and the most robust fix is to ensure the `IF` conditions are wrapped in parentheses and ensure all statements are strictly terminated.
Also, I will remove the `(* --- STATE X --- *)` comments that are on separate lines immediately before `IF` or `ELSIF` just in case the parser is sensitive to the line break between a comment and the keyword, although standard ST allows it.
Actually, the safest bet is to ensure the `IF` is not preceded by anything that looks like a statement continuation.

Let's rewrite the code to be extremely clean:
1. Ensure all assignments end with `;`.
2. Ensure `IF` conditions are parenthesized.
3. Ensure `ELSIF` follows `END_IF` immediately (remove comments between them if possible, or keep them but ensure the `END_IF;` is the last thing).
4. Check for any `IF` used as a variable.

Wait, I see a potential issue in the `STATE 5` block.
`ELSIF Current_State = 5 THEN`
...
`END_IF;`
This is fine.

Let's try to generate the code with explicit parentheses and ensuring no ambiguity.
Also, I will check if `IF` was accidentally used as a variable name in the `VAR` section? No.

One specific thing: In some CODESYS versions, if you have:
`IF A THEN`
`B := 1;`
`END_IF;`
`IF C THEN`
It works.

What if the error is about the `START_ST` and `END_ST` markers? The prompt says "START YOUR CODE WITH 'START_ST' AND 'END_ST'". The provided code has them. The feedback says "ST output passed ANTLR syntax validation" but "failed CODESYS". This suggests the ANTLR grammar is loose, but the CODESYS compiler is strict.

The error "replace IF with ;" is extremely specific. It usually means the parser saw `IF` where it expected a statement terminator.
This happens if the previous line did not end with `;`.
Example:
`X := 5 IF Y THEN` -> Error.
But we don't have that.

Could it be that the `IF` keyword is missing a semicolon *after* the `THEN` clause? No.

Let's assume the issue is the `ELSIF` chain. If the compiler is very strict, it might require the `IF` to be the first thing.
Let's try to remove the comments between `END_IF` and `ELSIF` to be safe.
Also, I will add parentheses to all boolean expressions.

Revised Plan:
1. Keep the structure.
2. Add parentheses to all `IF` conditions.
3. Remove comments that appear immediately before `IF` or `ELSIF` to avoid parser confusion (though comments are usually fine, strict parsers might hate it).
4. Ensure every line ending with a statement has a semicolon.
5. Ensure `END_FUNCTION_BLOCK` is correct.

Wait, I just realized something. In the original code:
`IF StartButton = TRUE AND EmergencyStop = FALSE THEN`
If the compiler interprets `TRUE` and `FALSE` as variables (which they are not in ST, they are literals), it might complain. But `TRUE` and `FALSE` are standard.

Let's look at the error message again. "应该用';' 替换'IF'".
Maybe the code has `IF` instead of `:=`? No.

Okay, I will proceed with the "cleanest" version of the code, adding parentheses and removing intermediate comments between `END_IF` and `ELSIF` to ensure the flow is unambiguous for the strict CODESYS compiler.

START_ST
FUNCTION_BLOCK WindowCleaningSystem
VAR_INPUT
    StartButton : BOOL;
    EmergencyStop :