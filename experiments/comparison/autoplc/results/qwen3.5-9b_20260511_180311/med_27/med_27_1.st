FUNCTION_BLOCK FlowerArrangingMachine
VAR_INPUT
    FlowerTypeSensor : INT;
    FlowerColorSensor : INT;
END_VAR
VAR_OUTPUT
    ArrangingMechanism : INT;
    ConveyorBelt : BOOL;
END_VAR
VAR
    TempMechanism : INT;
END_VAR

TempMechanism := 0;

IF FlowerTypeSensor = 1 AND FlowerColorSensor = 1 THEN
    TempMechanism := 1;
ELSIF FlowerTypeSensor = 1 AND FlowerColorSensor = 2 THEN
    TempMechanism := 2;
ELSIF FlowerTypeSensor = 2 AND FlowerColorSensor = 1 THEN
    TempMechanism := 3;
ELSIF FlowerTypeSensor = 2 AND FlowerColorSensor = 2 THEN
    TempMechanism := 4;
END_IF;

ArrangingMechanism := TempMechanism;

IF ArrangingMechanism <> 0 THEN
    ConveyorBelt := TRUE;
ELSE
    ConveyorBelt := FALSE;
END_IF;

END_FUNCTION_BLOCK