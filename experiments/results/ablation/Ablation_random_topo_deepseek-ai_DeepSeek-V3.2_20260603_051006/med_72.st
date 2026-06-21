FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL;    (* Display active status at each location *)
    ContentSource : ARRAY[1..10] OF INT;        (* Requested content for each location *)
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT;       (* Current displayed content: 1=News, 2=Weather, 3=Promo, 0=None *)
END_VAR
VAR
    i : INT;                                    (* Loop counter *)
END_VAR

(* Main logic: Update content for all locations immediately *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        (* Display is active - check content source *)
        CASE ContentSource[i] OF
            1: CurrentContent[i] := 1;          (* News *)
            2: CurrentContent[i] := 2;          (* Weather *)
            3: CurrentContent[i] := 3;          (* Promotional Content *)
        ELSE
            CurrentContent[i] := 0;             (* Invalid content code or 0 *)
        END_CASE;
    ELSE
        (* Display is inactive - show no content *)
        CurrentContent[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK