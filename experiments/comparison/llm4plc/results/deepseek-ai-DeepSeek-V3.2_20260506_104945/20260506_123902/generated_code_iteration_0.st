START_ST
FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL;
    ContentSource : ARRAY[1..10] OF INT;
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT;
END_VAR
VAR
    state : INT;
    prevState : INT;
    i : INT;
END_VAR

(* State machine execution *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        (* Set all CurrentContent array elements to 0 *)
        FOR i := 1 TO 10 DO
            CurrentContent[i] := 0;
        END_FOR;
        (* Transition to PROCESS_DISPLAYS state *)
        state := 1;
        prevState := 0;

    1: (* STATE 1: PROCESS_DISPLAYS *)
        (* Process each display location *)
        FOR i := 1 TO 10 DO
            IF DisplayLocations[i] THEN
                (* Check for valid content code *)
                IF (ContentSource[i] = 1) OR (ContentSource[i] = 2) OR (ContentSource[i] = 3) THEN
                    CurrentContent[i] := ContentSource[i];
                ELSE
                    CurrentContent[i] := 0;
                END_IF;
            ELSE
                CurrentContent[i] := 0;
            END_IF;
        END_FOR;
        (* Remain in PROCESS_DISPLAYS state *)
        state := 1;
        prevState := 1;

    ELSE
        (* Default case: reset to INITIALIZE state *)
        state := 0;
        prevState := state;
END_CASE;
END_FUNCTION_BLOCK
END_ST