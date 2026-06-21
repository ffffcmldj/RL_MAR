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
    State : INT; (* State variable for state machine *);
    Tolerance : REAL := 0.05; (* Tolerance for weight check *);
END_VAR

(* State Definitions *)
CONST
    IDLE : INT := 0;
    CONVEYING : INT := 1;
    FILLING : INT := 2;
    CONVEYING_OUT : INT := 3;
    ERROR : INT := 4;
END_CONST

(* Initialization *)
FeederMotor := FALSE;
FillingMotor := FALSE;
ConveyorMotor := FALSE;
FillingInProgress := FALSE;
State := IDLE;

(* Main Control Logic *)
IF HopperEmpty THEN
    FeederMotor := FALSE;
    FillingMotor := FALSE;
    ConveyorMotor := FALSE;
    FillingInProgress := FALSE;
    State := ERROR; (* Transition to ERROR state *)
ELSE
    CASE State OF
        IDLE:
            IF CapsuleInPosition THEN
                ConveyorMotor := TRUE; (* Activate conveyor motor *)
                State := CONVEYING; (* Transition to CONVEYING state *)
            END_IF;

        CONVEYING:
            (* Assume some condition to check if conveying is done *)
            ConveyorMotor := FALSE; (* Deactivate conveyor motor *)
            State := FILLING; (* Transition to FILLING state *)

        FILLING:
            IF CapsuleWeight >= TargetWeight THEN
                FeederMotor := FALSE;
                FillingMotor := FALSE;
                FillingInProgress := FALSE;
                State := ERROR; (* Transition to ERROR state due to overfilling *)
            ELSE
                FillingMotor := TRUE; (* Activate filling motor *)
                FillingInProgress := TRUE; (* Set filling in progress *)
                
                (* Check if weight is within tolerance *)
                IF ABS(CapsuleWeight - TargetWeight) <= Tolerance THEN
                    FillingMotor := FALSE; (* Deactivate filling motor *)
                    State := CONVEYING_OUT; (* Transition to CONVEYING_OUT state *)
                END_IF;
            END_IF;

        CONVEYING_OUT:
            ConveyorMotor := TRUE; (* Activate conveyor motor to move out filled capsule *)
            (* Assume some condition to check if conveying out is done *)
            ConveyorMotor := FALSE; (* Deactivate conveyor motor *)
            FillingInProgress := FALSE; (* Filling is complete *)
            State := IDLE; (* Transition back to IDLE state *)

        ERROR:
            (* Handle error state, motors are already off *)
            (* Additional error handling can be implemented here *)
    END_CASE;
END_IF;

END_FUNCTION_BLOCK