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
    tempArrangingMechanism : INT;
END_VAR

(* Determine ArrangingMechanism value based on sensor inputs *)
IF (FlowerTypeSensor = 1) AND (FlowerColorSensor = 1) THEN
    tempArrangingMechanism := 1;
ELSIF (FlowerTypeSensor = 1) AND (FlowerColorSensor = 2) THEN
    tempArrangingMechanism := 2;
ELSIF (FlowerTypeSensor = 2) AND (FlowerColorSensor = 1) THEN
    tempArrangingMechanism := 3;
ELSIF (FlowerTypeSensor = 2) AND (FlowerColorSensor = 2) THEN
    tempArrangingMechanism := 4;
ELSE
    tempArrangingMechanism := 0;
END_IF;

(* Assign the calculated value to the output *)
ArrangingMechanism := tempArrangingMechanism;

(* Control ConveyorBelt based on ArrangingMechanism *)
ConveyorBelt := (ArrangingMechanism <> 0);

END_FUNCTION_BLOCK