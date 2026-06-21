FUNCTION_BLOCK FlowerArrangingMachine
VAR_INPUT
    FlowerTypeSensor : INT; (* Input for detecting flower type *)
    FlowerColorSensor : INT; (* Input for detecting flower color *)
END_VAR
VAR_OUTPUT
    ArrangingMechanism : INT; (* Output for controlling arranging mechanism *)
    ConveyorBelt : BOOL; (* Output for controlling conveyor belt *)
END_VAR
VAR
    (* No internal variables required for this logic *)
END_VAR

(* Main control logic *)
IF (FlowerTypeSensor = 1) AND (FlowerColorSensor = 1) THEN
    ArrangingMechanism := 1; (* Red type 1 flower *)
ELSIF (FlowerTypeSensor = 1) AND (FlowerColorSensor = 2) THEN
    ArrangingMechanism := 2; (* Blue type 1 flower *)
ELSIF (FlowerTypeSensor = 2) AND (FlowerColorSensor = 1) THEN
    ArrangingMechanism := 3; (* Red type 2 flower *)
ELSIF (FlowerTypeSensor = 2) AND (FlowerColorSensor = 2) THEN
    ArrangingMechanism := 4; (* Blue type 2 flower *)
ELSE
    ArrangingMechanism := 0; (* Any other combination *)
END_IF;

(* Conveyor belt control based on arranging mechanism *)
ConveyorBelt := (ArrangingMechanism <> 0);

END_FUNCTION_BLOCK;