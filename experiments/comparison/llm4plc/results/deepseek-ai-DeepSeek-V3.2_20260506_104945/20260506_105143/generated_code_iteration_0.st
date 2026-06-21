START_ST
FUNCTION_BLOCK MultiPumpCtrl
VAR_INPUT
    mode : BOOL;
    start : BOOL;
    stop : BOOL;
    priorities : ARRAY[1..5] OF INT;
    selections : ARRAY[1..5] OF BOOL;
END_VAR
VAR_OUTPUT
    RunComds : ARRAY[1..5] OF BOOL;
END_VAR
VAR
    state : INT;
    prevState : INT;
    i : INT;
    j : INT;
    maxPriority : INT;
    maxIndex : INT;
    runCount : INT;
    usedInAuto : ARRAY[1..5] OF BOOL;
    tempPriorities : ARRAY[1..5] OF INT;
    tempIndices : ARRAY[1..5] OF INT;
END_VAR

(* State definitions:
   0: IDLE
   1: MANUAL_OPERATION
   2: AUTOMATIC_OPERATION
*)

(* State transition logic *)
IF stop THEN
    state := 0; (* Stop overrides everything, go to IDLE *)
ELSIF NOT start THEN
    state := 0; (* No start command, go to IDLE *)
ELSE
    (* start = TRUE and stop = FALSE *)
    IF NOT mode THEN
        state := 1; (* Manual mode *)
    ELSE
        state := 2; (* Automatic mode *)
    END_IF;
END_IF;

(* State execution logic *)
CASE state OF
    0: (* IDLE *)
        FOR i := 1 TO 5 DO
            RunComds[i] := FALSE;
        END_FOR;

    1: (* MANUAL_OPERATION *)
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR;

    2: (* AUTOMATIC_OPERATION *)
        (* Initialize arrays *)
        FOR i := 1 TO 5 DO
            tempPriorities[i] := priorities[i];
            tempIndices[i] := i;
            usedInAuto[i] := FALSE;
            RunComds[i] := FALSE;
        END_FOR;

        (* Find 3 highest priority pumps *)
        runCount := 0;
        WHILE runCount < 3 DO
            maxPriority := tempPriorities[1];
            maxIndex := 1;
            
            (* Find maximum priority value *)
            FOR i := 2 TO 5 DO
                IF tempPriorities[i] > maxPriority THEN
                    maxPriority := tempPriorities[i];
                    maxIndex := i;
                END_IF;
            END_FOR;
            
            (* Mark the found pump as used *)
            usedInAuto[tempIndices[maxIndex]] := TRUE;
            RunComds[tempIndices[maxIndex]] := TRUE;
            
            (* Remove this pump from further consideration *)
            tempPriorities[maxIndex] := -32768; (* Smallest possible INT value *)
            
            runCount := runCount + 1;
        END_WHILE;

        (* Ensure remaining pumps are off *)
        FOR i := 1 TO 5 DO
            IF NOT usedInAuto[i] THEN
                RunComds[i] := FALSE;
            END_IF;
        END_FOR;

END_CASE;

(* Stop signal override - highest priority *)
IF stop THEN
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
END_IF;

(* Store previous state for tracking *)
prevState := state;

END_FUNCTION_BLOCK
END_ST