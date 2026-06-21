FUNCTION_BLOCK FlowerArrangingMachine
VAR_INPUT
    FlowerTypeSensor : INT; (* Input for detecting flower type *)
    FlowerColorSensor : INT; (* Input for detecting flower color *)
END_VAR
VAR_OUTPUT
    ArrangingMechanism : INT; (* Output for controlling arranging mechanism *)
    ConveyorBelt : BOOL; (* Output for controlling conveyor belt *)
END_VAR

(* Initialization of outputs *)
ArrangingMechanism := 0; (* Default state *)
ConveyorBelt := FALSE; (* Default state *)

(* Control Logic Execution *)
IF FlowerTypeSensor = 1 THEN
    IF FlowerColorSensor = 1 THEN
        ArrangingMechanism := 1; (* red type 1 flower *)
    ELSIF FlowerColorSensor = 2 THEN
        ArrangingMechanism := 2; (* blue type 1 flower *)
    ELSE
        ArrangingMechanism := 0; (* any other combination *)
    END_IF;
ELSIF FlowerTypeSensor = 2 THEN
    IF FlowerColorSensor = 1 THEN
        ArrangingMechanism := 3; (* red type 2 flower *)
    ELSIF FlowerColorSensor = 2 THEN
        ArrangingMechanism := 4; (* blue type 2 flower *)
    ELSE
        ArrangingMechanism := 0; (* any other combination *)
    END_IF;
ELSE
    ArrangingMechanism := 0; (* any other combination *)
END_IF;

(* Conveyor Belt Control *)
IF ArrangingMechanism <> 0 THEN
    ConveyorBelt := TRUE; (* Activate conveyor belt *)
ELSE
    ConveyorBelt := FALSE; (* Deactivate conveyor belt *)
END_IF;

END_FUNCTION_BLOCK