START_ST
FUNCTION_BLOCK SandwichMaker
VAR_INPUT
    BreadFeeder : BOOL; (* Input: Detects the presence of bread slices *)
    Ingredient1 : BOOL; (* Input: Detects the presence of Ingredient 1 (e.g., cheese) *)
    Ingredient2 : BOOL; (* Input: Detects the presence of Ingredient 2 (e.g., lettuce) *)
    Ingredient3 : BOOL; (* Input: Detects the presence of Ingredient 3 (e.g., tomatoes) *)
    Condiment1 : BOOL; (* Input: Detects the presence of Condiment 1 (e.g., mayo) *)
    Condiment2 : BOOL; (* Input: Detects the presence of Condiment 2 (e.g., mustard) *)
END_VAR
VAR_OUTPUT
    ConveyorMotor : BOOL; (* Output: Controls the conveyor belt motor *)
    AssembleMotor : BOOL; (* Output: Controls the sandwich assembly motor *)
END_VAR
VAR
    SliceCount : INT := 0; (* Counter for bread slices *)
    state : INT := 0; (* Current state of the FSM: 0=IDLE, 1=CONVEYOR_RUNNING, 2=ASSEMBLY_READY, 3=ASSEMBLY_ACTIVE *)
    prevState : INT := 0; (* Previous state for debugging *)
    breadFeederPrev : BOOL := FALSE; (* Previous value of BreadFeeder for edge detection *)
    breadFeederRising : BOOL; (* Rising edge detection for BreadFeeder *)
    allIngredientsPresent : BOOL; (* Combined condition for all ingredients and condiments *)
END_VAR

(* Edge detection for BreadFeeder *)
breadFeederRising := BreadFeeder AND NOT breadFeederPrev;
breadFeederPrev := BreadFeeder;

(* Combined condition for all ingredients and condiments *)
allIngredientsPresent := Ingredient1 AND Ingredient2 AND Ingredient3 AND Condiment1 AND Condiment2;

(* Main state machine logic *)
CASE state OF
    0: (* IDLE *)
        ConveyorMotor := FALSE;
        AssembleMotor := FALSE;
        SliceCount := 0; (* Reset slice counter in IDLE *)
        
        IF BreadFeeder THEN
            state := 1; (* Transition to CONVEYOR_RUNNING when bread is detected *)
        END_IF;
        
    1: (* CONVEYOR_RUNNING *)
        ConveyorMotor := TRUE;
        AssembleMotor := FALSE;
        
        (* Increment slice count on rising edge of BreadFeeder *)
        IF breadFeederRising THEN
            SliceCount := SliceCount + 1;
        END_IF;
        
        IF NOT BreadFeeder THEN
            state := 0; (* Transition to IDLE when no bread detected *)
        ELSIF SliceCount >= 2 THEN
            state := 2; (* Transition to ASSEMBLY_READY when enough slices *)
        END_IF;
        
    2: (* ASSEMBLY_READY *)
        ConveyorMotor := FALSE; (* Stop conveyor when ready for assembly *)
        AssembleMotor := FALSE;
        
        IF SliceCount < 2 THEN
            state := 1; (* Not enough slices, go back to counting *)
        ELSIF allIngredientsPresent THEN
            state := 3; (* All ingredients present, start assembly *)
        ELSE
            state := 0; (* Missing ingredients, return to IDLE *)
        END_IF;
        
    3: (* ASSEMBLY_ACTIVE *)
        ConveyorMotor := FALSE; (* Conveyor remains stopped during assembly *)
        AssembleMotor := TRUE;
        
        IF (SliceCount < 2) OR NOT allIngredientsPresent THEN
            state := 2; (* Conditions no longer met, go back to ASSEMBLY_READY *)
        ELSE
            (* Assembly complete when all conditions remain met - transition to IDLE *)
            (* Note: In a real system, this would typically have a timer or completion sensor *)
            state := 0;
        END_IF;
        
END_CASE;

(* Store previous state for debugging *)
prevState := state;

END_FUNCTION_BLOCK
END_ST