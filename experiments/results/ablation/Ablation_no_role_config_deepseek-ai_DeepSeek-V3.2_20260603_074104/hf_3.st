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
    i : INT;
    j : INT;
    maxPriority : INT;
    maxIndex : INT;
    runCount : INT;
    usedInAuto : ARRAY[1..5] OF BOOL;
END_VAR

(* Main logic *)
IF stop THEN
    (* Highest priority: stop signal *)
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
ELSIF start THEN
    IF NOT mode THEN
        (* Manual mode *)
        FOR i := 1 TO 5 DO
            RunComds[i] := selections[i];
        END_FOR;
    ELSE
        (* Automatic mode - find 3 highest priority pumps *)
        (* Initialize tracking array *)
        FOR i := 1 TO 5 DO
            usedInAuto[i] := FALSE;
        END_FOR;
        
        runCount := 0;
        WHILE runCount < 3 DO
            maxPriority := -32768; (* Minimum INT value *)
            maxIndex := 1;
            
            (* Find highest priority pump not yet selected *)
            FOR i := 1 TO 5 DO
                IF (priorities[i] > maxPriority) AND NOT usedInAuto[i] THEN
                    maxPriority := priorities[i];
                    maxIndex := i;
                END_IF;
            END_FOR;
            
            (* Mark pump as selected *)
            usedInAuto[maxIndex] := TRUE;
            runCount := runCount + 1;
        END_WHILE;
        
        (* Set run commands based on selected pumps *)
        FOR i := 1 TO 5 DO
            RunComds[i] := usedInAuto[i];
        END_FOR;
    END_IF;
ELSE
    (* start is FALSE - stop all pumps *)
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
END_IF;

END_FUNCTION_BLOCK