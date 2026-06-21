START_REASON  
The error occurred because the `FB_PID` type is not recognized by the CODESYS compiler. This indicates that either the `FB_PID` function block is not defined or imported in the code, or it is not a standard type available in the current environment. To resolve this, we need to either define the `FB_PID` function block explicitly or replace it with a standard or custom PID implementation that is compatible with the environment.  
END_REASON  

START_ST  
FUNCTION_BLOCK CapsuleFillingMachineControl  
VAR_INPUT  
    CapsuleWeight : REAL; (* Current capsule weight *)  
    TargetWeight : REAL; (* Target weight to achieve *)  
    CapsuleInPosition : BOOL; (* Capsule position sensor *)  
    HopperEmpty : BOOL; (* Hopper empty sensor *)  
END_VAR  

VAR_OUTPUT  
    FeederMotor : BOOL; (* Feeder motor control *)  
    FillingMotor : BOOL; (* Filling motor control *)  
    ConveyorMotor : BOOL; (* Conveyor motor control *)  
    FillingInProgress : BOOL; (* Filling status *)  
END_VAR  

VAR  
    state : INT; (* Current state of the state machine *)  
    prevState : INT; (* Previous state of the state machine *)  
    FillingTimeout : BOOL; (* Indicates if filling timeout occurred *)  
    CapsuleNotDetected : BOOL; (* Indicates if capsule was not detected in time *)  
    TimerConveying : TON; (* Timer for conveying stages *)  
    TimerFilling : TON; (* Timer for filling stage *)  
    PID_Output : REAL; (* Output of the PID controller *)  
    Error : REAL; (* Error for PID calculation *)  
    Integral : REAL; (* Integral term for PID calculation *)  
    Derivative : REAL; (* Derivative term for PID calculation *)  
    PreviousError : REAL; (* Previous error for PID calculation *)  
    Kp : REAL := 1.0; (* Proportional gain *)  
    Ki : REAL := 0.1; (* Integral gain *)  
    Kd : REAL := 0.01; (* Derivative gain *)  
    Tolerance : REAL := 0.01; (* Tolerance for weight comparison *)  
END_VAR  

(* State Machine Logic *)  
CASE state OF  

    (* STATE 0: IDLE *)  
    0:  
        FeederMotor := FALSE;  
        FillingMotor := FALSE;  
        ConveyorMotor := FALSE;  
        FillingInProgress := FALSE;  
        IF TRUE THEN  
            state := 1; (* Transition to SAFETY_CHECK *)  
        END_IF;  

    (* STATE 1: SAFETY_CHECK *)  
    1:  
        FeederMotor := FALSE;  
        FillingMotor := FALSE;  
        ConveyorMotor := FALSE;  
        FillingInProgress := FALSE;  
        IF HopperEmpty THEN  
            state := 6; (* Transition to ERROR_HANDLING *)  
        ELSE  
            state := 2; (* Transition to WEIGHT_VALIDATION *)  
        END_IF;  

    (* STATE 2: WEIGHT_VALIDATION *)  
    2:  
        FeederMotor := FALSE;  
        FillingMotor := FALSE;  
        ConveyorMotor := FALSE;  
        FillingInProgress := FALSE;  
        IF CapsuleWeight >= TargetWeight THEN  
            state := 6; (* Transition to ERROR_HANDLING to avoid overfilling *)  
        ELSE  
            state := 3; (* Transition to CONVEYING *)  
        END_IF;  

    (* STATE 3: CONVEYING *)  
    3:  
        FeederMotor := FALSE;  
        FillingMotor := FALSE;  
        ConveyorMotor := TRUE;  
        FillingInProgress := FALSE;  

        TimerConveying(IN := TRUE, PT := T#5S); (* Start conveying timer *)  
        IF TimerConveying.Q THEN  
            TimerConveying(IN := FALSE); (* Stop timer *)  
            IF CapsuleInPosition THEN  
                state := 4; (* Transition to FILLING *)  
            ELSE  
                CapsuleNotDetected := TRUE;  
                state := 6; (* Transition to ERROR_HANDLING *)  
            END_IF;  
        END_IF;  

    (* STATE 4: FILLING *)  
    4:  
        FeederMotor := TRUE;  
        ConveyorMotor := FALSE;  
        FillingInProgress := TRUE;  

        (* PID Control for Filling Motor *)  
        Error := TargetWeight - CapsuleWeight;  
        Integral := Integral + Error;  
        Derivative := Error - PreviousError;  
        PID_Output := (Kp * Error) + (Ki * Integral) + (Kd * Derivative);  
        PreviousError := Error;  
        FillingMotor := PID_Output > 0.0; (* Activate FillingMotor based on PID output *)  

        TimerFilling(IN := TRUE, PT := T#10S); (* Start filling timer *)  
        IF CapsuleWeight >= (TargetWeight - Tolerance) AND CapsuleWeight <= (TargetWeight + Tolerance) THEN  
            TimerFilling(IN := FALSE); (* Stop timer *)  
            FillingMotor := FALSE;  
            state := 5; (* Transition to CONVEYING_OUT *)  
        ELSIF TimerFilling.Q THEN  
            FillingTimeout := TRUE;  
            TimerFilling(IN := FALSE); (* Stop timer *)  
            state := 6; (* Transition to ERROR_HANDLING *)  
        END_IF;  

    (* STATE 5: CONVEYING_OUT *)  
    5:  
        FeederMotor := FALSE;  
        FillingMotor := FALSE;  
        ConveyorMotor := TRUE;  
        FillingInProgress := FALSE;  

        TimerConveying(IN := TRUE, PT := T#3S); (* Start conveying out timer *)  
        IF TimerConveying.Q THEN  
            TimerConveying(IN := FALSE); (* Stop timer *)  
            state := 0; (* Transition to IDLE *)  
        END_IF;  

    (* STATE 6: ERROR_HANDLING *)  
    6:  
        FeederMotor := FALSE;  
        FillingMotor := FALSE;  
        ConveyorMotor := FALSE;  
        FillingInProgress := FALSE;  

        (* Handle specific errors *)  
        IF HopperEmpty THEN  
            (* Handle hopper empty error *)  
        ELSIF CapsuleNotDetected THEN  
            (* Handle capsule not detected error *)  
        ELSIF FillingTimeout THEN  
            (* Handle filling timeout error *)  
        END_IF;  

        (* Reset error flags and return to IDLE *)  
        CapsuleNotDetected := FALSE;  
        FillingTimeout := FALSE;  
        state := 0;  

END_CASE;  
END_FUNCTION_BLOCK  
END_ST  