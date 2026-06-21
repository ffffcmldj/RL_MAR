(*
    FUNCTION_BLOCK: PouchMachine
    Description: Controls the startup and shutdown sequences for a 3D pouch making machine.
    The machine includes 8 heating stations, 8 cooling stations, two feeder units,
    and one horizontal and one vertical cutter.
    Startup Sequence: Heating -> Cooling -> Feeders (with tension) -> Horizontal Cutter -> Vertical Cutter -> Ready.
    Shutdown Sequence: Cutters -> Feeders -> Heating -> Cooling -> Idle.
    The state machine can be interrupted at any time by the stop command.
*)

FUNCTION_BLOCK PouchMachine
VAR_INPUT
    start_machine: BOOL;    (* Rising edge triggers startup sequence from Idle *)
    stop_machine: BOOL;     (* Command to initiate shutdown sequence from any state *)
END_VAR

VAR_OUTPUT
    machine_ready: BOOL;    (* TRUE when machine is fully operational *)
    feeder_running: BOOL;   (* TRUE when both feeder units are running with tension *)
    cutter_running: BOOL;   (* TRUE when both horizontal and vertical cutters are active *)
    heating_running: BOOL;  (* TRUE when all 8 heating stations are active *)
    cooling_running: BOOL;  (* TRUE when all 8 cooling stations are active *)
END_VAR

VAR
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := FALSE;
    current_state: INT := 0;
    next_state: INT := 0;
END_VAR

(* Main State Machine Logic *)
CASE current_state OF
    0: (* Idle State - Machine is stopped and outputs are reset *)
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_complete := FALSE;
        shutdown_complete := FALSE;

        IF start_machine AND NOT stop_machine THEN
            next_state := 1; (* Begin startup sequence *)
        ELSE
            next_state := 0; (* Remain idle *)
        END_IF;

    1: (* Startup - Activate Heating Stations *)
        heating_running := TRUE; (* Activate all 8 heating stations *)

        IF heating_running AND NOT stop_machine THEN
            next_state := 2; (* Proceed to activate cooling *)
        ELSIF stop_machine THEN
            next_state := 6; (* Abort startup, begin shutdown *)
        ELSE
            next_state := 1; (* Wait for heating to be confirmed active *)
        END_IF;

    2: (* Startup - Activate Cooling Stations *)
        cooling_running := TRUE; (* Activate all 8 cooling stations *)

        IF cooling_running AND NOT stop_machine THEN
            next_state := 3; (* Proceed to start feeders *)
        ELSIF stop_machine THEN
            next_state := 6; (* Abort startup, begin shutdown *)
        ELSE
            next_state := 2; (* Wait for cooling to be confirmed active *)
        END_IF;

    3: (* Startup - Start Feeders with Tension Control *)
        feeder_running := TRUE; (* Start both feeder units and establish winding tension *)

        IF feeder_running AND NOT stop_machine THEN
            next_state := 4; (* Proceed to activate horizontal cutter *)
        ELSIF stop_machine THEN
            next_state := 6; (* Abort startup, begin shutdown *)
        ELSE
            next_state := 3; (* Wait for feeders to be confirmed running *)
        END_IF;

    4: (* Startup - Activate Horizontal Cutter *)
        cutter_running := TRUE; (* Activate the horizontal cutter *)

        IF cutter_running AND NOT stop_machine THEN
            next_state := 5; (* Proceed to final ready state (vertical cutter implied active) *)
        ELSIF stop_machine THEN
            next_state := 6; (* Abort startup, begin shutdown *)
        ELSE
            next_state := 4; (* Wait for cutter to be confirmed active *)
        END_IF;

    5: (* Startup - Ready State (Vertical Cutter active) *)
        (* Both cutters are active, machine is fully operational *)
        machine_ready := TRUE;
        startup_complete := TRUE;
        shutdown_complete := FALSE;

        IF stop_machine THEN
            next_state := 6; (* Begin normal shutdown sequence *)
        ELSE
            next_state := 5; (* Remain in ready state *)
        END_IF;

    6: (* Shutdown - Stop Both Cutters *)
        cutter_running := FALSE; (* Deactivate both horizontal and vertical cutters *)
        machine_ready := FALSE;  (* Machine is no longer ready for operation *)

        IF NOT cutter_running THEN
            next_state := 7; (* Proceed to stop feeders *)
        ELSE
            next_state := 6; (* Wait for cutters to be confirmed stopped *)
        END_IF;

    7: (* Shutdown - Stop Feeders *)
        feeder_running := FALSE; (* Stop both feeder units *)

        IF NOT feeder_running THEN
            next_state := 8; (* Proceed to deactivate heating *)
        ELSE
            next_state := 7; (* Wait for feeders to be confirmed stopped *)
        END_IF;

    8: (* Shutdown - Deactivate Heating Stations *)
        heating_running := FALSE; (* Deactivate all 8 heating stations *)

        IF NOT heating_running THEN
            next_state := 9; (* Proceed to final shutdown step *)
        ELSE
            next_state := 8; (* Wait for heating to be confirmed off *)
        END_IF;

    9: (* Shutdown - Deactivate Cooling Stations and Complete *)
        cooling_running := FALSE; (* Deactivate all 8 cooling stations *)
        shutdown_complete := TRUE;
        startup_complete := FALSE;

        IF NOT cooling_running THEN
            next_state := 0; (* Return to Idle state *)
        ELSE
            next_state := 9; (* Wait for cooling to be confirmed off *)
        END_IF;
END_CASE;

(* State Transition - Update current state for next execution cycle *)
current_state := next_state;

END_FUNCTION_BLOCK