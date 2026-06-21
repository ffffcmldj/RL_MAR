FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL;    (* Display status at each location *)
    ContentSource : ARRAY[1..10] OF INT;        (* Desired content for each location *)
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT;       (* Current displayed content *)
END_VAR
VAR
    i : INT;                                    (* Loop counter *)
END_VAR

(* Main logic: Update content immediately based on inputs *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        (* Check if content code is valid (1, 2, or 3) *)
        CASE ContentSource[i] OF
            1: CurrentContent[i] := 1;    (* News *)
            2: CurrentContent[i] := 2;    (* Weather *)
            3: CurrentContent[i] := 3;    (* Promotional Content *)
        ELSE
            CurrentContent[i] := 0;       (* Invalid code or 0 = No Content *)
        END_CASE;
    ELSE
        (* Display is offline *)
        CurrentContent[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK