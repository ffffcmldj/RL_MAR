FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL;
    ContentSource : ARRAY[1..10] OF INT;
END_VAR

VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT;
END_VAR

VAR
    i : INT;
END_VAR

FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        CASE ContentSource[i] OF
            1:
                CurrentContent[i] := 1;
            2:
                CurrentContent[i] := 2;
            3:
                CurrentContent[i] := 3;
            ELSE
                CurrentContent[i] := 0;
        END_CASE;
    ELSE
        CurrentContent[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK;