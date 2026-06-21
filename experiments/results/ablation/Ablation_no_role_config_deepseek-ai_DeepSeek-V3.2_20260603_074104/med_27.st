FUNCTION_BLOCK FlowerArrangingMachine
VAR_INPUT
    FlowerTypeSensor : INT; (* Input for detecting flower type *)
    FlowerColorSensor : INT; (* Input for detecting flower color *)
END_VAR
VAR_OUTPUT
    ArrangingMechanism : INT; (* Output for controlling arranging mechanism *)
    ConveyorBelt : BOOL; (* Output for controlling conveyor belt *)
END_VAR

(* Main logic body *)
IF FlowerTypeSensor = 1 AND FlowerColorSensor = 1 THEN
    ArrangingMechanism := 1; (* red type 1 flower *)
ELSIF FlowerTypeSensor = 1 AND FlowerColorSensor = 2 THEN
    ArrangingMechanism := 2; (* blue type 1 flower *)
ELSIF FlowerTypeSensor = 2 AND FlowerColorSensor = 1 THEN
    ArrangingMechanism := 3; (* red type 2 flower *)
ELSIF FlowerTypeSensor = 2 AND FlowerColorSensor = 2 THEN
    ArrangingMechanism := 4; (* blue type 2 flower *)
ELSE
    ArrangingMechanism := 0; (* any other combination *)
END_IF;

(* Control conveyor belt based on arranging mechanism *)
ConveyorBelt := ArrangingMechanism <> 0;

END_FUNCTION_BLOCK