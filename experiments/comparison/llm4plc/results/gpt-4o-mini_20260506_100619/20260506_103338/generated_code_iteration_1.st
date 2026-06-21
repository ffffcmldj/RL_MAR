START_REASON
The errors in the original Structured Text (ST) code occurred due to the incorrect use of the `IN` operator in the conditional statement. In CODESYS, the correct syntax for checking if a value matches a set of values is to use the `THEN` keyword instead of `IN`. This caused the code to fail during compilation. I will correct this issue and ensure that the code adheres to the required structure.
END_REASON

START_ST
FUNCTION_BLOCK DigitalSignageManagement
VAR_INPUT
    DisplayLocations : ARRAY[1..10] OF BOOL; (* Inputs for display status at various locations *)
    ContentSource : ARRAY[1..10] OF INT; (* Inputs for content sources at various locations *)
END_VAR
VAR_OUTPUT
    CurrentContent : ARRAY[1..10] OF INT; (* Current content being displayed: 1=News, 2=Weather, 3=Promo, 0=None *)
END_VAR
VAR
    state : INT; (* Current state of the FSM *)
    i : INT; (* Loop counter *)
END_VAR

(* Initialize state *)
state := 0;

(* State machine logic *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        FOR i := 1 TO 10 DO
            CurrentContent[i] := 0; (* Initialize all outputs to 0 *)
        END_FOR;
        state := 1; (* Transition to STATE 1 to update content based on inputs *)

    1: (* STATE 1: UPDATE CONTENT BASED ON DISPLAY LOCATIONS *)
        FOR i := 1 TO 10 DO
            IF DisplayLocations[i] THEN
                IF ContentSource[i] = 1 OR ContentSource[i] = 2 OR ContentSource[i] = 3 THEN
                    CurrentContent[i] := ContentSource[i]; (* Assign valid content *)
                ELSE
                    CurrentContent[i] := 0; (* Assign no content for invalid codes *)
                END_IF;
            ELSE
                CurrentContent[i] := 0; (* If display is not online, no content is displayed *)
            END_IF;
        END_FOR;
        (* Remain in STATE 1 to continuously update CurrentContent based on DisplayLocations and ContentSource *)
END_CASE;

END_FUNCTION_BLOCK
END_ST