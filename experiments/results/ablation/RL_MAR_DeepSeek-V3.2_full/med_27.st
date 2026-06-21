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
    (* No internal variables required for this combinational logic *)
END_VAR

(* Main logic body *)
IF (FlowerTypeSensor = 1) AND (FlowerColorSensor = 1) THEN
    ArrangingMechanism := 1;
ELSIF (FlowerTypeSensor = 1) AND (FlowerColorSensor = 2) THEN
    ArrangingMechanism := 2;
ELSIF (FlowerTypeSensor = 2) AND (FlowerColorSensor = 1) THEN
    ArrangingMechanism := 3;
ELSIF (FlowerTypeSensor = 2) AND (FlowerColorSensor = 2) THEN
    ArrangingMechanism := 4;
ELSE
    ArrangingMechanism := 0;
END_IF;

ConveyorBelt := ArrangingMechanism <> 0;

END_FUNCTION_BLOCK;