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

(* Main execution logic *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        (* Display is active - validate content source *)
        IF (ContentSource[i] = 1) OR (ContentSource[i] = 2) OR (ContentSource[i] = 3) THEN
            CurrentContent[i] := ContentSource[i];
        ELSE
            CurrentContent[i] := 0; (* Invalid content code *)
        END_IF;
    ELSE
        (* Display is not active *)
        CurrentContent[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK