FUNCTION_BLOCK FB_ProductionLineControl
VAR_INPUT
    Mode : BOOL; (* FALSE: Manual, TRUE: Automatic *)
    ForwardButton : BOOL; (* Manual forward control button *)
    ReverseButton : BOOL; (* Manual reverse control button *)
    SensorA : BOOL; (* Position sensor at station A *)
    SensorB : BOOL; (* Position sensor at station B *)
    SensorC : BOOL; (* Position sensor at station C *)
    ButtonA : BOOL; (* Process activation button at station A *)
    ButtonB : BOOL; (* Process activation button at station B *)
    ButtonC : BOOL; (* Process activation button at station C *)
END_VAR

VAR_OUTPUT
    MotorForward : BOOL; (* Forward motor control signal *)
    MotorReverse : BOOL; (* Reverse motor control signal *)
    CompletionLight : BOOL; (* Process completion indicator *)
END_VAR

VAR
    State : INT := 0; (* State machine control variable *)
END_VAR

(* Main execution logic *)
CASE State OF
    0: (* Initialization state *)
        MotorForward := FALSE;
        MotorReverse := FALSE;
        CompletionLight := FALSE;
        State := 1;
        
    1: (* State 1: Manual mode OR Automatic mode waiting at Station A *)
        IF NOT Mode THEN (* Manual Mode *)
            (* Forward motion *)
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            (* Reverse motion *)
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            (* Stop condition - both buttons pressed or neither pressed *)
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE;
        ELSE (* Automatic Mode - State 1: Waiting at Station A *)
            MotorForward := FALSE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            IF SensorA THEN
                State := 2; (* Transition to State 2 *)
            END_IF;
        END_IF;
        
    2: (* State 2: Manual mode OR Automatic mode processing at Station A *)
        IF NOT Mode THEN (* Manual Mode *)
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE;
        ELSE (* Automatic Mode - State 2: Processing at Station A *)
            MotorForward := FALSE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            IF ButtonA THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 3; (* Transition to State 3 *)
            END_IF;
        END_IF;
        
    3: (* State 3: Manual mode OR Automatic mode moving to Station B *)
        IF NOT Mode THEN (* Manual Mode *)
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE;
        ELSE (* Automatic Mode - State 3: Moving to Station B *)
            MotorForward := TRUE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            IF SensorB THEN
                MotorForward := FALSE;
                State := 4; (* Transition to State 4 *)
            END_IF;
        END_IF;
        
    4: (* State 4: Manual mode OR Automatic mode processing at Station B *)
        IF NOT Mode THEN (* Manual Mode *)
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE;
        ELSE (* Automatic Mode - State 4: Processing at Station B *)
            MotorForward := FALSE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            IF ButtonB THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
                State := 5; (* Transition to State 5 *)
            END_IF;
        END_IF;
        
    5: (* State 5: Manual mode OR Automatic mode moving to Station C *)
        IF NOT Mode THEN (* Manual Mode *)
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE;
        ELSE (* Automatic Mode - State 5: Moving to Station C *)
            MotorForward := TRUE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            IF SensorC THEN
                MotorForward := FALSE;
                State := 6; (* Transition to State 6 *)
            END_IF;
        END_IF;
        
    6: (* State 6: Manual mode OR Automatic mode processing at Station C *)
        IF NOT Mode THEN (* Manual Mode *)
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE;
        ELSE (* Automatic Mode - State 6: Processing at Station C *)
            MotorForward := FALSE;
            MotorReverse := FALSE;
            CompletionLight := FALSE;
            IF ButtonC THEN
                CompletionLight := TRUE;
                State := 7; (* Transition to State 7 *)
            END_IF;
        END_IF;
        
    7: (* State 7: Manual mode OR Automatic mode cycle completion *)
        IF NOT Mode THEN (* Manual Mode *)
            IF ForwardButton AND NOT ReverseButton THEN
                MotorForward := TRUE;
                MotorReverse := FALSE;
            ELSIF ReverseButton AND NOT ForwardButton THEN
                MotorForward := FALSE;
                MotorReverse := TRUE;
            ELSE
                MotorForward := FALSE;
                MotorReverse := FALSE;
            END_IF;
            CompletionLight := FALSE;
        ELSE (* Automatic Mode - State 7: Cycle Completion *)
            MotorForward := FALSE;
            MotorReverse := FALSE;
            IF NOT SensorC THEN
                CompletionLight := FALSE;
                State := 1; (* Return to State 1 *)
            END_IF;
        END_IF;
        
END_CASE;

END_FUNCTION_BLOCK