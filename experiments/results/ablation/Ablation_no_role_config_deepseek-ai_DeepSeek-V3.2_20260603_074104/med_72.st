FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL;    (* Display active status per location *)
    ContentSource : ARRAY[1..10] OF INT;        (* Requested content per location *)
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT;       (* Actual displayed content per location *)
END_VAR
VAR
    i : INT;                                    (* Loop index *)
END_VAR

(* Process all 10 display locations *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        (* Display is active - validate content code *)
        CASE ContentSource[i] OF
            1: CurrentContent[i] := 1;          (* News *)
            2: CurrentContent[i] := 2;          (* Weather *)
            3: CurrentContent[i] := 3;          (* Promotional Content *)
        ELSE
            CurrentContent[i] := 0;             (* Invalid code - show no content *)
        END_CASE;
    ELSE
        (* Display is inactive - always show no content *)
        CurrentContent[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK