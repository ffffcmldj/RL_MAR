plaintext
START_ST
FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL; (* Inputs for display status at various locations *)
    ContentSource : ARRAY[1..10] OF INT;    (* Inputs for content sources at various locations *)
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT;   (* Current content being displayed: 1=News, 2=Weather, 3=Promo, 0=None *)
END_VAR
VAR
    i : INT; (* Loop counter *)
END_VAR

(* Initialize CurrentContent to all zeros at the start of the program *)
FOR i := 1 TO 10 DO
    CurrentContent[i] := 0;
END_FOR

(* Iterate through each location and assign content based on the specified rules *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        (* Check if ContentSource[i] is valid (1, 2, or 3) *)
        IF (ContentSource[i] = 1) OR (ContentSource[i] = 2) OR (ContentSource[i] = 3) THEN
            CurrentContent[i] := ContentSource[i]; (* Assign valid content code *)
        ELSE
            CurrentContent[i] := 0; (* Assign 0 for invalid content code *)
        END_IF;
    ELSE
        CurrentContent[i] := 0; (* Assign 0 if the display is offline *)
    END_IF;
END_FOR

END_FUNCTION_BLOCK
END_ST