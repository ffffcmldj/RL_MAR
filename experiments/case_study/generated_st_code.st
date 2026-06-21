FUNCTION_BLOCK FB_StackerCrane_Controller
VAR_INPUT
    mode_switch : BOOL;
    start_cycle : BOOL;
    emergency_stop : BOOL;
    estop_ack : BOOL;
    target_row_src : INT;
    target_col_src : INT;
    target_row_dst : INT;
    target_col_dst : INT;
    sensor_cargo : ARRAY[0..2, 0..2] OF BOOL;
    limit_X_pos : BOOL;
    limit_X_neg : BOOL;
    limit_Y_pos : BOOL;
    limit_Y_neg : BOOL;
    limit_Z_pos : BOOL;
    limit_Z_neg : BOOL;
    hmi_jog_X_plus : BOOL;
    hmi_jog_X_minus : BOOL;
    hmi_jog_Y_plus : BOOL;
    hmi_jog_Y_minus : BOOL;
    hmi_jog_Z_plus : BOOL;
    hmi_jog_Z_minus : BOOL;
END_VAR

VAR_OUTPUT
    cmd_move_X : BOOL;
    cmd_dir_X : BOOL;
    cmd_move_Y : BOOL;
    cmd_dir_Y : BOOL;
    cmd_move_Z : BOOL;
    cmd_dir_Z : BOOL;
    current_pos_X : INT;
    current_pos_Y : INT;
    fork_extended : BOOL;
    cycle_complete : BOOL;
    cycle_fault : BOOL;
    fault_code : WORD;
    estop_active : BOOL;
    mode_indicator : BOOL;
    alarm_queue : ARRAY[0..9] OF WORD;
END_VAR

VAR
    current_step : INT := 0;
    estop_latched : BOOL := FALSE;
    alarm_index : INT := 0;
    i : INT;
    j : INT;
    start_cycle_rising : BOOL := FALSE;
    estop_ack_rising : BOOL := FALSE;
    prev_start_cycle : BOOL := FALSE;
    prev_estop_ack : BOOL := FALSE;
    sensor_debounced : ARRAY[0..2, 0..2] OF BOOL;
    debounce_timer : ARRAY[0..2, 0..2] OF TIME;
    debounce_time : TIME := T#50ms;
    limit_X_pos_prev : BOOL := FALSE;
    limit_X_neg_prev : BOOL := FALSE;
    limit_Y_pos_prev : BOOL := FALSE;
    limit_Y_neg_prev : BOOL := FALSE;
    limit_Z_pos_prev : BOOL := FALSE;
    limit_Z_neg_prev : BOOL := FALSE;
    alarm_count : INT := 0;
END_VAR

// Edge detection for start_cycle
IF start_cycle AND NOT prev_start_cycle THEN
    start_cycle_rising := TRUE;
ELSE
    start_cycle_rising := FALSE;
END_IF
prev_start_cycle := start_cycle;

// Edge detection for estop_ack
IF estop_ack AND NOT prev_estop_ack THEN
    estop_ack_rising := TRUE;
ELSE
    estop_ack_rising := FALSE;
END_IF
prev_estop_ack := estop_ack;

// Mode indicator
mode_indicator := mode_switch;

// E-Stop handling
IF emergency_stop THEN
    estop_latched := TRUE;
END_IF

IF estop_ack_rising AND NOT emergency_stop THEN
    estop_latched := FALSE;
END_IF

estop_active := emergency_stop OR estop_latched;

// Emergency stop override - stop all motion
IF estop_active THEN
    cmd_move_X := FALSE;
    cmd_move_Y := FALSE;
    cmd_move_Z := FALSE;
    cmd_dir_X := FALSE;
    cmd_dir_Y := FALSE;
    cmd_dir_Z := FALSE;
    current_step := 0;
    cycle_complete := FALSE;
    cycle_fault := TRUE;
    fault_code := 16#0001; // E-Stop fault code
END_IF

// Limit switch detection and alarm logging
IF limit_X_pos AND NOT limit_X_pos_prev THEN
    // Log alarm for X+ overtravel
    alarm_queue[alarm_index] := 16#0010;
    alarm_index := (alarm_index + 1) MOD 10;
    IF alarm_count < 10 THEN
        alarm_count := alarm_count + 1;
    END_IF
END_IF
limit_X_pos_prev := limit_X_pos;

IF limit_X_neg AND NOT limit_X_neg_prev THEN
    alarm_queue[alarm_index] := 16#0011;
    alarm_index := (alarm_index + 1) MOD 10;
    IF alarm_count < 10 THEN
        alarm_count := alarm_count + 1;
    END_IF
END_IF
limit_X_neg_prev := limit_X_neg;

IF limit_Y_pos AND NOT limit_Y_pos_prev THEN
    alarm_queue[alarm_index] := 16#0020;
    alarm_index := (alarm_index + 1) MOD 10;
    IF alarm_count < 10 THEN
        alarm_count := alarm_count + 1;
    END_IF
END_IF
limit_Y_pos_prev := limit_Y_pos;

IF limit_Y_neg AND NOT limit_Y_neg_prev THEN
    alarm_queue[alarm_index] := 16#0021;
    alarm_index := (alarm_index + 1) MOD 10;
    IF alarm_count < 10 THEN
        alarm_count := alarm_count + 1;
    END_IF
END_IF
limit_Y_neg_prev := limit_Y_neg;

IF limit_Z_pos AND NOT limit_Z_pos_prev THEN
    alarm_queue[alarm_index] := 16#0030;
    alarm_index := (alarm_index + 1) MOD 10;
    IF alarm_count < 10 THEN
        alarm_count := alarm_count + 1;
    END_IF
END_IF
limit_Z_pos_prev := limit_Z_pos;

IF limit_Z_neg AND NOT limit_Z_neg_prev THEN
    alarm_queue[alarm_index] := 16#0031;
    alarm_index := (alarm_index + 1) MOD 10;
    IF alarm_count < 10 THEN
        alarm_count := alarm_count + 1;
    END_IF
END_IF
limit_Z_neg_prev := limit_Z_neg;

// Sensor debouncing
FOR i := 0 TO 2 DO
    FOR j := 0 TO 2 DO
        IF sensor_cargo[i, j] THEN
            IF debounce_timer[i, j] < debounce_time THEN
                debounce_timer[i, j] := debounce_timer[i, j] + T#100ms;
            ELSE
                sensor_debounced[i, j] := TRUE;
            END_IF
        ELSE
            debounce_timer[i, j] := T#0ms;
            sensor_debounced[i, j] := FALSE;
        END_IF
    END_FOR
END_FOR

// Main control logic (only if not in E-Stop)
IF NOT estop_active THEN
    // Manual mode
    IF NOT mode_switch THEN
        // Reset automatic cycle outputs
        cycle_complete := FALSE;
        cycle_fault := FALSE;
        current_step := 0;
        
        // Manual jog X axis with limit switch protection
        IF hmi_jog_X_plus AND NOT limit_X_pos THEN
            cmd_move_X := TRUE;
            cmd_dir_X := TRUE;
        ELSIF hmi_jog_X_minus AND NOT limit_X_neg THEN
            cmd_move_X := TRUE;
            cmd_dir_X := FALSE;
        ELSE
            cmd_move_X := FALSE;
            cmd_dir_X := FALSE;
        END_IF
        
        // Manual jog Y axis with limit switch protection
        IF hmi_jog_Y_plus AND NOT limit_Y_pos THEN
            cmd_move_Y := TRUE;
            cmd_dir_Y := TRUE;
        ELSIF hmi_jog_Y_minus AND NOT limit_Y_neg THEN
            cmd_move_Y := TRUE;
            cmd_dir_Y := FALSE;
        ELSE
            cmd_move_Y := FALSE;
            cmd_dir_Y := FALSE;
        END_IF
        
        // Manual jog Z axis with limit switch protection
        IF hmi_jog_Z_plus AND NOT limit_Z_pos THEN
            cmd_move_Z := TRUE;
            cmd_dir_Z := TRUE;
        ELSIF hmi_jog_Z_minus AND NOT limit_Z_neg THEN
            cmd_move_Z := TRUE;
            cmd_dir_Z := FALSE;
        ELSE
            cmd_move_Z := FALSE;
            cmd_dir_Z := FALSE;
        END_IF
        
        // Update fork status
        fork_extended := limit_Z_pos;
        
    // Automatic mode
    ELSE
        // Automatic state machine
        CASE current_step OF
            0: // Idle state
                cycle_complete := FALSE;
                cycle_fault := FALSE;
                cmd_move_X := FALSE;
                cmd_move_Y := FALSE;
                cmd_move_Z := FALSE;
                cmd_dir_X := FALSE;
                cmd_dir_Y := FALSE;
                cmd_dir_Z := FALSE;
                
                IF start_cycle_rising THEN
                    // Validate source and destination positions
                    IF target_row_src >= 0 AND target_row_src <= 2 AND
                       target_col_src >= 0 AND target_col_src <= 2 AND
                       target_row_dst >= 0 AND target_row_dst <= 2 AND
                       target_col_dst >= 0 AND target_col_dst <= 2 THEN
                        
                        // Check if source has cargo
                        IF sensor_debounced[target_row_src, target_col_src] THEN
                            current_step := 10; // Move to source position
                        ELSE
                            // No cargo at source - fault
                            fault_code := 16#0100; // No cargo at source
                            cycle_fault := TRUE;
                            alarm_queue[alarm_index] := 16#0100;
                            alarm_index := (alarm_index + 1) MOD 10;
                            IF alarm_count < 10 THEN
                                alarm_count := alarm_count + 1;
                            END_IF
                        END_IF
                    ELSE
                        // Invalid target positions
                        fault_code := 16#0200; // Invalid position
                        cycle_fault := TRUE;
                        alarm_queue[alarm_index] := 16#0200;
                        alarm_index := (alarm_index + 1) MOD 10;
                        IF alarm_count < 10 THEN
                            alarm_count := alarm_count + 1;
                        END_IF
                    END_IF
                END_IF
                
            10: // Move X to source column
                IF current_pos_X < target_col_src THEN
                    cmd_move_X := TRUE;
                    cmd_dir_X := TRUE;
                ELSIF current_pos_X > target_col_src THEN
                    cmd_move_X := TRUE;
                    cmd_dir_X := FALSE;
                ELSE
                    cmd_move_X := FALSE;
                    current_step := 20;
                END_IF
                
            20: // Move Y to source row
                IF current_pos_Y < target_row_src THEN
                    cmd_move_Y := TRUE;
                    cmd_dir_Y := TRUE;
                ELSIF current_pos_Y > target_row_src THEN
                    cmd_move_Y := TRUE;
                    cmd_dir_Y := FALSE;
                ELSE
                    cmd_move_Y := FALSE;
                    current_step := 30;
                END_IF
                
            30: // Extend fork to pick cargo
                IF NOT limit_Z_pos THEN
                    cmd_move_Z := TRUE;
                    cmd_dir_Z := TRUE;
                ELSE
                    cmd_move_Z := FALSE;
                    fork_extended := TRUE;
                    current_step := 40;
                END_IF
                
            40: // Verify cargo picked
                IF sensor_debounced[target_row_src, target_col_src] THEN
                    // Cargo still present - good
                    current_step := 50;
                ELSE
                    // Cargo missing - fault
                    fault_code := 16#0300; // Cargo pick failed
                    cycle_fault := TRUE;
                    alarm_queue[alarm_index] := 16#0300;
                    alarm_index := (alarm_index + 1) MOD 10;
                    IF alarm_count < 10 THEN
                        alarm_count := alarm_count + 1;
                    END_IF
                END_IF
                
            50: // Retract fork
                IF NOT limit_Z_neg THEN
                    cmd_move_Z := TRUE;
                    cmd_dir_Z := FALSE;
                ELSE
                    cmd_move_Z := FALSE;
                    fork_extended := FALSE;
                    current_step := 60;
                END_IF
                
            60: // Move X to destination column
                IF current_pos_X < target_col_dst THEN
                    cmd_move_X := TRUE;
                    cmd_dir_X := TRUE;
                ELSIF current_pos_X > target_col_dst THEN
                    cmd_move_X := TRUE;
                    cmd_dir_X := FALSE;
                ELSE
                    cmd_move_X := FALSE;
                    current_step := 70;
                END_IF
                
            70: // Move Y to destination row
                IF current_pos_Y < target_row_dst THEN
                    cmd_move_Y := TRUE;
                    cmd_dir_Y := TRUE;
                ELSIF current_pos_Y > target_row_dst THEN
                    cmd_move_Y := TRUE;
                    cmd_dir_Y := FALSE;
                ELSE
                    cmd_move_Y := FALSE;
                    current_step := 80;
                END_IF
                
            80: // Verify destination is empty
                IF NOT sensor_debounced[target_row_dst, target_col_dst] THEN
                    current_step := 90;
                ELSE
                    // Destination occupied - fault
                    fault_code := 16#0400; // Destination occupied
                    cycle_fault := TRUE;
                    alarm_queue[alarm_index] := 16#0400;
                    alarm_index := (alarm_index + 1) MOD 10;
                    IF alarm_count < 10 THEN
                        alarm_count := alarm_count + 1;
                    END_IF
                END_IF
                
            90: // Extend fork to place cargo
                IF NOT limit_Z_pos THEN
                    cmd_move_Z := TRUE;
                    cmd_dir_Z := TRUE;
                ELSE
                    cmd_move_Z := FALSE;
                    fork_extended := TRUE;
                    current_step := 100;
                END_IF
                
            100: // Verify cargo placed
                IF sensor_debounced[target_row_dst, target_col_dst] THEN
                    // Cargo placed successfully
                    current_step := 110;
                ELSE
                    // Cargo placement failed
                    fault_code := 16#0500; // Cargo place failed
                    cycle_fault := TRUE;
                    alarm_queue[alarm_index] := 16#0500;
                    alarm_index := (alarm_index + 1) MOD 10;
                    IF alarm_count < 10 THEN
                        alarm_count := alarm_count + 1;
                    END_IF
                END_IF
                
            110: // Retract fork
                IF NOT limit_Z_neg THEN
                    cmd_move_Z := TRUE;
                    cmd_dir_Z := FALSE;
                ELSE
                    cmd_move_Z := FALSE;
                    fork_extended := FALSE;
                    current_step := 120;
                END_IF
                
            120: // Cycle complete
                cycle_complete := TRUE;
                current_step := 0;
                
        END_CASE
        
        // Limit switch override during automatic mode
        IF limit_X_pos THEN
            cmd_move_X := FALSE;
            cmd_dir_X := FALSE;
        END_IF
        IF limit_X_neg THEN
            cmd_move_X := FALSE;
            cmd_dir_X := FALSE;
        END_IF
        IF limit_Y_pos THEN
            cmd_move_Y := FALSE;
            cmd_dir_Y := FALSE;
        END_IF
        IF limit_Y_neg THEN
            cmd_move_Y := FALSE;
            cmd_dir_Y := FALSE;
        END_IF
        IF limit_Z_pos THEN
            cmd_move_Z := FALSE;
            cmd_dir_Z := FALSE;
        END_IF
        IF limit_Z_neg THEN
            cmd_move_Z := FALSE;
            cmd_dir_Z := FALSE;
        END_IF
    END_IF
END_IF

END_FUNCTION_BLOCK