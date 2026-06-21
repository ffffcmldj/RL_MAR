FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL; (* Inputs for display status at various locations *)
    ContentSource : ARRAY[1..10] OF INT; (* Inputs for content sources at various locations *)
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT; (* Current content being displayed: 1=News, 2=Weather, 3=Promo, 0=None *)
END_VAR
VAR
    i : INT; (* Loop counter *)
END_VAR

(* Initialize CurrentContent array to zero *)
FOR i := 1 TO 10 DO
    CurrentContent[i] := 0; (* Default to no content *)
END_FOR

(* Content Assignment Logic *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN (* Check if display is active *)
        IF ContentSource[i] = 1 OR ContentSource[i] = 2 OR ContentSource[i] = 3 THEN
            CurrentContent[i] := ContentSource[i]; (* Assign valid content *)
        ELSE
            CurrentContent[i] := 0; (* Assign no content for invalid codes *)
        END_IF
    END_IF
END_FOR

END_FUNCTION_BLOCK