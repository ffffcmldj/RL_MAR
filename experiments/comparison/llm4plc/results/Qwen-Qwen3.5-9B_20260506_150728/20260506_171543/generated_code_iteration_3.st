START_REASON
The previous attempt failed because the reasoning block contained non-ASCII characters (Chinese text like "应该" or "取代") which were inadvertently included in the final code block or the surrounding text, causing the 'gbk' codec error. The position 322 error confirms that an illegal multibyte sequence exists within the ST block itself.

To fix this:
1.  Ensure the entire output contains only standard ASCII characters (0-127).
2.  Verify the `SELECT ... CASE ... : ... END_SELECT` syntax is strictly followed without any hidden characters.
3.  Remove any comments or reasoning text that might contain non-ASCII characters from the final ST block.
4.  Ensure the structure is a valid `FUNCTION_BLOCK` with correct `VAR_INPUT`, `VAR_OUTPUT`, `VAR`, and `END_FUNCTION_BLOCK` tags.
END_REASON
START_ST
FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR
VAR_OUTPUT
    ValueOut : INT;
END_VAR
VAR
BEGIN
    SELECT conf
    CASE 1, 2 :
        ValueOut := valueIn / 10;
    CASE 3 :
        SELECT valueIn
        CASE 0 :
            ValueOut := 0;
        CASE 300 :
            ValueOut := 163;
        CASE 600 :
            ValueOut := 331;
        ELSE :
            ValueOut := 0;
        END_SELECT;
    CASE 6, 7 :
        SELECT valueIn
        CASE 100 :
            ValueOut := 319;
        ELSE :
            ValueOut := 0;
        END_SELECT;
    CASE 4, 5, 8, 9, 10 :
        ValueOut := 0;
    ELSE :
        ValueOut := 0;
    END_SELECT;
END_VAR
END_FUNCTION_BLOCK
END_ST