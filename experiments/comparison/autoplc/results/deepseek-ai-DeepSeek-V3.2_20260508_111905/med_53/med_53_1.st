FUNCTION_BLOCK PouchMachine
VAR_INPUT
    start_machine: BOOL;
    stop_machine: BOOL;
    heating_ready: BOOL; (* Confirmation that all 8 heating stations are at operating temperature *)
    cooling_ready: BOOL; (* Confirmation that all 8 cooling stations are operational *)
    tension_stable: BOOL; (* Confirmation that winding tension is stable within acceptable range *)
    cutter_ready: BOOL; (* Confirmation that both horizontal and vertical cutters are operational *)
    cutter_stopped: BOOL; (* Confirmation that both cutters are fully stopped *)
    feeder_stopped: BOOL; (* Confirmation that both feeders are fully stopped *)
    cooling_stopped: BOOL; (* Confirmation that all cooling stations are deactivated *)
    heating_safe: BOOL; (* Confirmation that all heating stations are deactivated and cooled to safe temperature *)
    emergency_stop: BOOL; (* Emergency stop input - immediately halts moving components *)
END_VAR

VAR_OUTPUT
    machine_ready: BOOL;
    feeder_running: BOOL;
    cutter_running: BOOL;
    heating_running: BOOL;
    cooling_running: BOOL;
    startup_in_progress: BOOL; (* Indicates startup sequence is active *)
    shutdown_in_progress: BOOL; (* Indicates shutdown sequence is active *)
END_VAR

VAR
    startup_complete: BOOL := FALSE;
    shutdown_complete: BOOL := FALSE;
    state: INT := 0; (* 0=Not Ready, 1=Startup, 2=Ready, 3=Shutdown *)
    startup_step: INT := 0; (* Current step in startup sequence (0-4) *)
    shutdown_step: INT := 0; (* Current step in shutdown sequence (0-4) *)
    start_prev: BOOL := FALSE;
    stop_prev: BOOL := FALSE;
    emergency_prev: BOOL := FALSE;
    step_timer: TON;
    step_timer_running: BOOL := FALSE;
    step_time: TIME := T#2s; (* Default time for each step if no confirmation available *)
END_VAR

(* State machine implementation *)
CASE state OF
    0: (* Not Ready State *)
        (* Reset all outputs *)
        machine_ready := FALSE;
        feeder_running := FALSE;
        cutter_running := FALSE;
        heating_running := FALSE;
        cooling_running := FALSE;
        startup_in_progress := FALSE;
        shutdown_in_progress := FALSE;
        
        (* Reset sequence steps *)
        startup_step := 0;
        shutdown_step := 0;
        
        (* Check for startup trigger *)
        IF start_machine AND NOT start_prev AND NOT emergency_stop THEN
            state := 1; (* Transition to Startup Sequence *)
            startup_in_progress := TRUE;
            startup_complete := FALSE;
        END_IF
        
    1: (* Startup Sequence State *)
        startup_in_progress := TRUE;
        shutdown_in_progress := FALSE;
        
        (* Check for emergency stop or stop command *)
        IF emergency_stop OR (stop_machine AND NOT stop_prev) THEN
            state := 3; (* Transition to Shutdown Sequence *)
            startup_in_progress := FALSE;
            shutdown_in_progress := TRUE;
            shutdown_step := 0;
        ELSE
            (* Execute startup sequence steps *)
            CASE startup_step OF
                0: (* Step 0: Activate Heating Stations *)
                    heating_running := TRUE;
                    
                    (* Wait for heating stations to be ready or use timer *)
                    IF heating_ready THEN
                        startup_step := 1;
                        step_timer_running := FALSE;
                    ELSIF NOT step_timer_running THEN
                        step_timer(IN:=TRUE, PT:=step_time);
                        step_timer_running := TRUE;
                    ELSIF step_timer.Q THEN
                        startup_step := 1;
                        step_timer_running := FALSE;
                        step_timer(IN:=FALSE);
                    END_IF
                    
                1: (* Step 1: Activate Cooling Stations *)
                    cooling_running := TRUE;
                    
                    (* Wait for cooling stations to be ready or use timer *)
                    IF cooling_ready THEN
                        startup_step := 2;
                        step_timer_running := FALSE;
                    ELSIF NOT step_timer_running THEN
                        step_timer(IN:=TRUE, PT:=step_time);
                        step_timer_running := TRUE;
                    ELSIF step_timer.Q THEN
                        startup_step := 2;
                        step_timer_running := FALSE;
                        step_timer(IN:=FALSE);
                    END_IF
                    
                2: (* Step 2: Start Feeders with Tension Control *)
                    feeder_running := TRUE;
                    
                    (* Wait for tension to stabilize *)
                    IF tension_stable THEN
                        startup_step := 3;
                        step_timer_running := FALSE;
                    ELSIF NOT step_timer_running THEN
                        step_timer(IN:=TRUE, PT:=step_time);
                        step_timer_running := TRUE;
                    ELSIF step_timer.Q THEN
                        startup_step := 3;
                        step_timer_running := FALSE;
                        step_timer(IN:=FALSE);
                    END_IF
                    
                3: (* Step 3: Activate Cutters *)
                    cutter_running := TRUE;
                    
                    (* Wait for cutters to be ready *)
                    IF cutter_ready THEN
                        startup_step := 4;
                        step_timer_running := FALSE;
                    ELSIF NOT step_timer_running THEN
                        step_timer(IN:=TRUE, PT:=step_time);
                        step_timer_running := TRUE;
                    ELSIF step_timer.Q THEN
                        startup_step := 4;
                        step_timer_running := FALSE;
                        step_timer(IN:=FALSE);
                    END_IF
                    
                4: (* Step 4: Set Ready State *)
                    machine_ready := TRUE;
                    startup_complete := TRUE;
                    startup_in_progress := FALSE;
                    state := 2; (* Transition to Ready State *)
                    startup_step := 0; (* Reset for next startup *)
            END_CASE
        END_IF
        
    2: (* Ready State *)
        startup_in_progress := FALSE;
        shutdown_in_progress := FALSE;
        
        (* Check for stop trigger or emergency stop *)
        IF (stop_machine AND NOT stop_prev) OR emergency_stop THEN
            state := 3; (* Transition to Shutdown Sequence *)
            shutdown_in_progress := TRUE;
            shutdown_step := 0;
        END_IF
        
    3: (* Shutdown Sequence State *)
        startup_in_progress := FALSE;
        shutdown_in_progress := TRUE;
        
        (* Execute shutdown sequence steps *)
        CASE shutdown_step OF
            0: (* Step 0: Stop Cutters *)
                cutter_running := FALSE;
                
                (* Wait for cutters to fully stop *)
                IF cutter_stopped THEN
                    shutdown_step := 1;
                    step_timer_running := FALSE;
                ELSIF NOT step_timer_running THEN
                    step_timer(IN:=TRUE, PT:=step_time);
                    step_timer_running := TRUE;
                ELSIF step_timer.Q THEN
                    shutdown_step := 1;
                    step_timer_running := FALSE;
                    step_timer(IN:=FALSE);
                END_IF
                
            1: (* Step 1: Stop Feeders *)
                feeder_running := FALSE;
                
                (* Wait for feeders to fully stop *)
                IF feeder_stopped THEN
                    shutdown_step := 2;
                    step_timer_running := FALSE;
                ELSIF NOT step_timer_running THEN
                    step_timer(IN:=TRUE, PT:=step_time);
                    step_timer_running := TRUE;
                ELSIF step_timer.Q THEN
                    shutdown_step := 2;
                    step_timer_running := FALSE;
                    step_timer(IN:=FALSE);
                END_IF
                
            2: (* Step 2: Deactivate Cooling Stations *)
                cooling_running := FALSE;
                
                (* Wait for cooling stations to deactivate *)
                IF cooling_stopped THEN
                    shutdown_step := 3;
                    step_timer_running := FALSE;
                ELSIF NOT step_timer_running THEN
                    step_timer(IN:=TRUE, PT:=step_time);
                    step_timer_running := TRUE;
                ELSIF step_timer.Q THEN
                    shutdown_step := 3;
                    step_timer_running := FALSE;
                    step_timer(IN:=FALSE);
                END_IF
                
            3: (* Step 3: Deactivate Heating Stations *)
                heating_running := FALSE;
                
                (* Wait for heating stations to be safe *)
                IF heating_safe THEN
                    shutdown_step := 4;
                    step_timer_running := FALSE;
                ELSIF NOT step_timer_running THEN
                    step_timer(IN:=TRUE, PT:=step_time);
                    step_timer_running := TRUE;
                ELSIF step_timer.Q THEN
                    shutdown_step := 4;
                    step_timer_running := FALSE;
                    step_timer(IN:=FALSE);
                END_IF
                
            4: (* Step 4: Set Not Ready State *)
                machine_ready := FALSE;
                shutdown_complete := TRUE;
                shutdown_in_progress := FALSE;
                state := 0; (* Transition to Not Ready State *)
                shutdown_step := 0; (* Reset for next shutdown *)
        END_CASE
        
        (* Emergency stop overrides normal shutdown - immediately stops moving components *)
        IF emergency_stop AND NOT emergency_prev THEN
            cutter_running := FALSE;
            feeder_running := FALSE;
            (* Continue with cooling and heating shutdown normally *)
        END_IF
END_CASE

(* Store previous values for edge detection *)
start_prev := start_machine;
stop_prev := stop_machine;
emergency_prev := emergency_stop;

(* Reset step timer if not in use *)
IF NOT step_timer_running THEN
    step_timer(IN:=FALSE);
END_IF

END_FUNCTION_BLOCK