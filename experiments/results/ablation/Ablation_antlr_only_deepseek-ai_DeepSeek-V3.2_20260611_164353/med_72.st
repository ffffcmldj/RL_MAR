FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL; (* TRUE = display active at location *)
    ContentSource : ARRAY[1..10] OF INT; (* Desired content: 1=News, 2=Weather, 3=Promo, 0/other=None *)
END_VAR

VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT; (* Actual displayed content: 1=News, 2=Weather, 3=Promo, 0=None *)
END_VAR

VAR
    i : INT; (* Loop counter *)
END_VAR

(* Main logic: Process all 10 locations each scan cycle *)
FOR i := 1 TO 10 DO
    IF DisplayLocations[i] THEN
        (* Display is active - validate and assign content *)
        CASE ContentSource[i] OF
            1: CurrentContent[i] := 1; (* News *)
            2: CurrentContent[i] := 2; (* Weather *)
            3: CurrentContent[i] := 3; (* Promotional Content *)
        ELSE
            CurrentContent[i] := 0; (* No Content for invalid code *)
        END_CASE;
    ELSE
        (* Display is inactive - force no content *)
        CurrentContent[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK