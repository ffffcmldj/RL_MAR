FUNCTION_BLOCK HomeBrewingSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Input for temperature measurement (°C) *)
    WaterFlowSensor : REAL; (* Input for water flow measurement (L/min) *)
    BrewingStartTime : TIME; (* Input for brewing process start time *)
    BrewingDuration : TIME; (* Input for total brewing duration *)
END_VAR

VAR_OUTPUT
    HeatingElement : BOOL; (* Output to control heating element *)
    AgitationMotor : BOOL; (* Output to control agitation motor *)
    HopsDispenser : BOOL; (* Output to control hops dispenser *)
    FermentationTank : BOOL; (* Output to control fermentation tank *)
END_VAR

VAR
    ElapsedTime : TIME;
    HopsTriggerTime : TIME := T#5h;
    FermentationTriggerTime : TIME := T#48h;
END_VAR

(* Main logic body *)
ElapsedTime := BrewingDuration;

(* Temperature control: heating element ON when temperature is below 65°C *)
HeatingElement := TemperatureSensor < 65.0;

(* Agitation motor control: motor ON when water flow exceeds 0.5 L/min *)
AgitationMotor := WaterFlowSensor > 0.5;

(* Hops dispenser: activate after 5 hours of brewing *)
HopsDispenser := ElapsedTime >= HopsTriggerTime;

(* Fermentation tank transfer: activate after 48 hours of brewing *)
FermentationTank := ElapsedTime >= FermentationTriggerTime;

END_FUNCTION_BLOCK;