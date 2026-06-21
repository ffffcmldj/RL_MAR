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

i := 1;
WHILE i <= 10 DO
    IF DisplayLocations[i] THEN
        IF ContentSource[i] = 1 OR ContentSource[i] = 2 OR ContentSource[i] = 3 THEN
            CurrentContent[i] := ContentSource[i];
        ELSE
            CurrentContent[i] := 0;
        END_IF;
    ELSE
        CurrentContent[i] := 0;
    END_IF;
    i := i + 1;
END_WHILE;

END_FUNCTION_BLOCK