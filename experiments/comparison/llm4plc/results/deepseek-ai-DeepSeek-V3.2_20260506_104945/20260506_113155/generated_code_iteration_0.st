START_ST
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
    state : INT; (* Current state: 0 = IDLE, 1 = ARRANGING *)
    prevState : INT; (* Previous state for internal tracking *)
    isValidCombination : BOOL; (* Flag to indicate valid sensor input combination *)
END_VAR

    (* Determine if the current sensor inputs represent a valid flower combination *)
    isValidCombination := (FlowerTypeSensor = 1 AND FlowerColorSensor = 1)
                       OR (FlowerTypeSensor = 1 AND FlowerColorSensor = 2)
                       OR (FlowerTypeSensor = 2 AND FlowerColorSensor = 1)
                       OR (FlowerTypeSensor = 2 AND FlowerColorSensor = 2);

    (* State machine execution per PLC cycle *)
    CASE state OF
        0: (* IDLE State *)
            ArrangingMechanism := 0;
            ConveyorBelt := FALSE;
            
            (* Transition to ARRANGING if a valid flower combination is detected *)
            IF isValidCombination THEN
                state := 1;
            END_IF;
            
        1: (* ARRANGING State *)
            ConveyorBelt := TRUE;
            
            (* Set ArrangingMechanism based on sensor inputs *)
            IF FlowerTypeSensor = 1 AND FlowerColorSensor = 1 THEN
                ArrangingMechanism := 1;
            ELSIF FlowerTypeSensor = 1 AND FlowerColorSensor = 2 THEN
                ArrangingMechanism := 2;
            ELSIF FlowerTypeSensor = 2 AND FlowerColorSensor = 1 THEN
                ArrangingMechanism := 3;
            ELSIF FlowerTypeSensor = 2 AND FlowerColorSensor = 2 THEN
                ArrangingMechanism := 4;
            ELSE
                ArrangingMechanism := 0; (* Fallback, though state should transition *)
            END_IF;
            
            (* Transition back to IDLE if the flower combination is no longer valid *)
            IF NOT isValidCombination THEN
                state := 0;
            END_IF;
            
        ELSE
            (* Default case: reset to IDLE state if state variable is corrupted *)
            state := 0;
            ArrangingMechanism := 0;
            ConveyorBelt := FALSE;
    END_CASE;
    
    (* Update previous state for the next cycle (if needed for future logic) *)
    prevState := state;

END_FUNCTION_BLOCK
END_ST