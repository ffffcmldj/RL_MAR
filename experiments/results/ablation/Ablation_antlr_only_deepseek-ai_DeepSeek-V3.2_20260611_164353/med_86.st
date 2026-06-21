FUNCTION_BLOCK FruitJuicingBottling
VAR_INPUT
    StartButton : BOOL;    (* Rising edge trigger to start the process *)
    StopButton : BOOL;     (* Level-sensitive command to stop the process *)
    FruitSelected : BOOL;  (* System readiness signal - must be TRUE to run *)
END_VAR

VAR_OUTPUT
    JuiceProcessing : BOOL;    (* Controls the juice extraction stage *)
    BottleFilling : BOOL;      (* Controls the bottle filling stage *)
    CapPlacement : BOOL;       (* Controls the cap placement stage *)
    Packaging : BOOL;          (* Controls the packaging stage *)
    ProcessInProgress : BOOL;  (* System status indicator *)
END_VAR

VAR
    bProcessActive : BOOL := FALSE;  (* Internal process state memory *)
END_VAR

(* Main Process State Machine *)
(* Start condition: Rising edge detection on StartButton with prerequisites *)
IF StartButton AND FruitSelected AND NOT bProcessActive THEN
    bProcessActive := TRUE;
END_IF;

(* Stop conditions: Level-sensitive stop commands *)
IF StopButton OR NOT FruitSelected THEN
    bProcessActive := FALSE;
END_IF;

(* Process Stage Outputs - All stages run concurrently when process is active *)
JuiceProcessing := bProcessActive;
BottleFilling := bProcessActive;
CapPlacement := bProcessActive;
Packaging := bProcessActive;

(* Process Status Output *)
ProcessInProgress := bProcessActive;

END_FUNCTION_BLOCK