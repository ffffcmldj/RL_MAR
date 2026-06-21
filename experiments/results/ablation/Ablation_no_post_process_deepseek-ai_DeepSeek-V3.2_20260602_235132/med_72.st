FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL; (* TRUE = Display online, FALSE = Display offline *)
    ContentSource : ARRAY[1..10] OF INT; (* Desired content: 1=News, 2=Weather, 3=Promo, 0/other=None *)
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT; (* Actual displayed content: 1=News, 2=Weather, 3=Promo, 0=None *)
END_VAR
VAR
    i : INT; (* Loop counter *)
END_VAR

(* Main processing loop: evaluates all 10 locations each scan cycle *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        (* Display is active: validate content code *)
        IF (ContentSource[i] = 1) OR (ContentSource[i] = 2) OR (ContentSource[i] = 3) THEN
            CurrentContent[i] := ContentSource[i]; (* Assign valid content *)
        ELSE
            CurrentContent[i] := 0; (* Invalid content code -> display nothing *)
        END_IF;
    ELSE
        (* Display is inactive: force no content *)
        CurrentContent[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK