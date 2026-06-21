FUNCTION_BLOCK MultiPumpCtrl
VAR_INPUT
    mode : BOOL;                    (* FALSE = Manual, TRUE = Automatic *)
    start : BOOL;                   (* Start button *)
    stop : BOOL;                    (* Stop button - highest priority *)
    priorities : ARRAY[1..5] OF INT; (* Priority of each pump *)
    selections : ARRAY[1..5] OF BOOL; (* Manual selection for each pump *)
END_VAR

VAR_OUTPUT
    RunComds : ARRAY[1..5] OF BOOL; (* Run command for each pump *)
END_VAR

VAR
    i : INT;                        (* Loop counter *)
    j : INT;                        (* Loop counter *)
    maxPriority : INT;              (* Temporary variable for finding max priority *)
    maxIndex : INT;                 (* Index of pump with max priority *)
    runCount : INT;                 (* Counter for pumps selected in auto mode *)
    usedInAuto : ARRAY[1..5] OF BOOL; (* Tracks pumps already selected in auto mode *)
END_VAR

(* Main logic *)
IF stop THEN
    (* Stop has highest priority - stop all pumps *)
    FOR i := 1 TO 5 DO
        RunComds[i] := FALSE;
    END_FOR;
ELSE
    IF start THEN
        IF NOT mode THEN            (* Manual mode *)
            FOR i := 1 TO 5 DO
                RunComds[i] := selections[i];
            END_FOR;
        ELSE                        (* Automatic mode *)
            (* Initialize arrays *)
            FOR i := 1 TO 5 DO
                usedInAuto[i] := FALSE;
                RunComds[i] := FALSE;
            END_FOR;
            
            (* Find and run 3 pumps with highest priorities *)
            runCount := 0;
            WHILE runCount < 3 DO
                maxPriority := -32768;  (* Minimum INT value *)
                maxIndex := 0;
                
                (* Find the highest priority pump not already selected *)
                FOR i := 1 TO 5 DO
                    IF (priorities[i] > maxPriority) AND NOT usedInAuto[i] THEN
                        maxPriority := priorities[i];
                        maxIndex := i;
                    END_IF;
                END_FOR;
                
                (* If a pump was found (should always be true if runCount < 3) *)
                IF maxIndex > 0 THEN
                    RunComds[maxIndex] := TRUE;
                    usedInAuto[maxIndex] := TRUE;
                    runCount := runCount + 1;
                END_IF;
            END_WHILE;
        END_IF;
    ELSE                            (* start is FALSE *)
        FOR i := 1 TO 5 DO
            RunComds[i] := FALSE;
        END_FOR;
    END_IF;
END_IF;

END_FUNCTION_BLOCK;