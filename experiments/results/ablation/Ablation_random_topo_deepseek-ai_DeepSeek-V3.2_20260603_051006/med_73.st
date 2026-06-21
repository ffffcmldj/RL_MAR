FUNCTION_BLOCK RoboticWeldingSystem
VAR_INPUT
    RobotArm1Ready : BOOL;    (* Input for robot arm 1 ready status *)
    RobotArm2Ready : BOOL;    (* Input for robot arm 2 ready status *)
    WeldingGunReady : BOOL;   (* Input for welding gun ready status *)
    StartButton : BOOL;       (* Input for start button press *)
    StopButton : BOOL;        (* Input for stop button press *)
END_VAR

VAR_OUTPUT
    WeldingTrigger : BOOL;    (* Output to trigger welding *)
    WeldingComplete : BOOL;   (* Output indicating welding completion *)
END_VAR

VAR
    CurrentState : INT;       (* 0=Idle, 1=Welding, 2=Stopped *)
    AllReady : BOOL;          (* Combined ready status *)
    ReadyLost : BOOL;         (* Flag for lost readiness during welding *)
END_VAR

(* Calculate combined conditions *)
AllReady := RobotArm1Ready AND RobotArm2Ready AND WeldingGunReady;
ReadyLost := NOT AllReady;

(* State machine implementation *)
CASE CurrentState OF
    0: (* Idle State *)
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;
        
        IF StopButton THEN
            CurrentState := 2;  (* Go to Stopped state *)
        ELSIF StartButton AND AllReady THEN
            CurrentState := 1;  (* Go to Welding state *)
        ELSE
            CurrentState := 0;  (* Remain in Idle *)
        END_IF;
    
    1: (* Welding State *)
        WeldingTrigger := TRUE;
        WeldingComplete := FALSE;
        
        IF StopButton THEN
            CurrentState := 2;  (* Go to Stopped state *)
        ELSIF ReadyLost THEN
            CurrentState := 0;  (* Go to Idle state *)
        ELSE
            CurrentState := 1;  (* Remain in Welding *)
        END_IF;
    
    2: (* Stopped State *)
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;
        
        IF NOT StopButton THEN
            CurrentState := 0;  (* Go to Idle state *)
        ELSE
            CurrentState := 2;  (* Remain in Stopped *)
        END_IF;
    
    ELSE
        (* Default to Idle state if invalid state *)
        CurrentState := 0;
        WeldingTrigger := FALSE;
        WeldingComplete := TRUE;
END_CASE;

END_FUNCTION_BLOCK