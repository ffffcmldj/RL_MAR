(*
    FUNCTION_BLOCK: FB_BottleProcessing
    PURPOSE: Sequential control for a bottle processing line with five stages.
    STATES: 0=Waiting, 1=Cleaning, 2=Filling, 3=Capping, 4=Packing, 5=Completed.
    AUTHOR: Senior PLC Commissioning Engineer
    STANDARD: IEC 61131-3
*)

FUNCTION_BLOCK FB_BottleProcessing
VAR_INPUT
    bottleSensor : BOOL;             (* Detects presence of a bottle at the start *)
    cleaningConfirmButton : BOOL;    (* Manual confirmation: Cleaning stage complete *)
    fillingConfirmButton : BOOL;     (* Manual confirmation: Filling stage complete *)
    cappingConfirmButton : BOOL;     (* Manual confirmation: Capping stage complete *)
    packingConfirmButton : BOOL;     (* Manual confirmation: Packing stage complete *)
    finishedButton : BOOL;           (* Manual confirmation: Process ready for next bottle *)
END_VAR

VAR_OUTPUT
    Pump_Motor : BOOL;       (* Controls the cleaning pump *)
    Filling_Valve : BOOL;    (* Controls the liquid filling valve *)
    Capping_Machine : BOOL;  (* Controls the capping mechanism *)
    Packing_Machine : BOOL;  (* Controls the packing system *)
    Completion_Light : BOOL; (* Indicates the entire process is complete *)
END_VAR

VAR
    State : INT := 0; (* 0=Waiting, 1=Cleaning, 2=Filling, 3=Capping, 4=Packing, 5=Completed *)
END_VAR

(* Main State Machine Logic *)
CASE State OF
    0: (* STATE: Waiting for a bottle *)
        (* Deactivate all outputs while waiting *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* TRANSITION: A bottle is detected, start cleaning *)
        IF bottleSensor THEN
            Pump_Motor := TRUE;
            State := 1;
        END_IF;

    1: (* STATE: Cleaning *)
        (* ACTION: Pump is running. Ensure other outputs are off. *)
        Pump_Motor := TRUE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* TRANSITION: Operator confirms cleaning is done *)
        IF cleaningConfirmButton THEN
            Pump_Motor := FALSE;
            Filling_Valve := TRUE;
            State := 2;
        END_IF;

    2: (* STATE: Filling *)
        (* ACTION: Filling valve is open. Ensure other outputs are off. *)
        Pump_Motor := FALSE;
        Filling_Valve := TRUE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* TRANSITION: Operator confirms filling is done *)
        IF fillingConfirmButton THEN
            Filling_Valve := FALSE;
            Capping_Machine := TRUE;
            State := 3;
        END_IF;

    3: (* STATE: Capping *)
        (* ACTION: Capping machine is active. Ensure other outputs are off. *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := TRUE;
        Packing_Machine := FALSE;
        Completion_Light := FALSE;

        (* TRANSITION: Operator confirms capping is done *)
        IF cappingConfirmButton THEN
            Capping_Machine := FALSE;
            Packing_Machine := TRUE;
            State := 4;
        END_IF;

    4: (* STATE: Packing *)
        (* ACTION: Packing machine is active. Ensure other outputs are off. *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := TRUE;
        Completion_Light := FALSE;

        (* TRANSITION: Operator confirms packing is done *)
        IF packingConfirmButton THEN
            Packing_Machine := FALSE;
            Completion_Light := TRUE;
            State := 5;
        END_IF;

    5: (* STATE: Completed *)
        (* ACTION: Light is on to signal completion. Ensure process outputs are off. *)
        Pump_Motor := FALSE;
        Filling_Valve := FALSE;
        Capping_Machine := FALSE;
        Packing_Machine := FALSE;
        Completion_Light := TRUE;

        (* TRANSITION: Operator acknowledges completion, reset for next cycle *)
        IF finishedButton THEN
            Completion_Light := FALSE;
            (* All outputs are already FALSE, explicit reset is redundant but clear *)
            State := 0;
        END_IF;
END_CASE;

END_FUNCTION_BLOCK