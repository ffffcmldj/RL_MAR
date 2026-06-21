START_ST
FUNCTION_BLOCK PizzaMakingMachine
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    DoughReadySensor : BOOL;
    ToppingsReadySensor : BOOL;
    BakingDoneSensor : BOOL;
END_VAR
VAR_OUTPUT
    DoughRollerMotor : BOOL;
    ToppingDispenser : BOOL;
    ConveyorMotor : BOOL;
    OvenHeater : BOOL;
    OvenTemperature : INT;
END_VAR
VAR
    state : INT;
    prevState : INT;
    ovenTempTarget : INT;
    doughReady : BOOL;
    toppingsReady : BOOL;
    bakingDone : BOOL;
    stopRequested : BOOL;
END_VAR

BEGIN
    (* 0. DECLARE THE NEEDED STATES - LOGIC IMPLEMENTATION *)
    (* State 0: IDLE *)
    (* State 1: ROLLING DOUGH *)
    (* State 2: DISPENSING TOPPINGS *)
    (* State 3: BAKING *)
    (* State 4: COOLING & RESET *)

    (* 3. DECLARE THE NEEDED VARIABLES - LOGIC IMPLEMENTATION *)
    (* Initialize variables on first execution or reset if needed, 
       though in FBs they persist unless reset. Assuming standard behavior. *)
    IF (StartButton = TRUE) AND (StopButton = FALSE) THEN
        stopRequested := FALSE;
    ELSE
        stopRequested := TRUE;
    END_IF;

    (* Handle Stop Button Priority: Force transition to Safe State (State 4) immediately *)
    IF StopButton = TRUE THEN
        state := 4;
        stopRequested := TRUE;
    END_IF;

    (* State Machine Logic *)
    CASE state OF
        0: (* STATE 0: IDLE *)
            (* Description: System is waiting for the Start Button. No motors or heaters are active. *)
            (* Inputs Monitored: StartButton, StopButton. *)
            
            (* Transition: STATE 0 -> STATE 1 *)
            (* Condition: IF StartButton = TRUE AND StopButton = FALSE *)
            IF StartButton = TRUE AND StopButton = FALSE THEN
                state := 1;
            END_IF;

            (* Output Assignments for STATE 0 *)
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := 0;

        1: (* STATE 1: ROLLING DOUGH *)
            (* Description: Dough Roller Motor is active. System waits for DoughReadySensor. *)
            (* Inputs Monitored: DoughReadySensor, StopButton. *)

            (* Transition: STATE 1 -> STATE 2 *)
            (* Condition: IF DoughReadySensor = TRUE AND StopButton = FALSE *)
            IF DoughReadySensor = TRUE AND StopButton = FALSE THEN
                state := 2;
            END_IF;

            (* Output Assignments for STATE 1 *)
            DoughRollerMotor := TRUE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := 0;

        2: (* STATE 2: DISPENSING TOPPINGS *)
            (* Description: Topping Dispenser is active. System waits for ToppingsReadySensor. *)
            (* Inputs Monitored: ToppingsReadySensor, StopButton. *)

            (* Transition: STATE 2 -> STATE 3 *)
            (* Condition: IF ToppingsReadySensor = TRUE AND StopButton = FALSE *)
            IF ToppingsReadySensor = TRUE AND StopButton = FALSE THEN
                state := 3;
            END_IF;

            (* Output Assignments for STATE 2 *)
            DoughRollerMotor := FALSE;
            ToppingDispenser := TRUE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := 0;

        3: (* STATE 3: BAKING *)
            (* Description: Conveyor Motor is active (moving pizza to oven), Oven Heater is active (set to 220°C). *)
            (* System waits for BakingDoneSensor. Inputs Monitored: BakingDoneSensor, StopButton. *)

            (* Transition: STATE 3 -> STATE 4 *)
            (* Condition: IF BakingDoneSensor = TRUE AND StopButton = FALSE *)
            IF BakingDoneSensor = TRUE AND StopButton = FALSE THEN
                state := 4;
            END_IF;

            (* Output Assignments for STATE 3 *)
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := TRUE;
            OvenHeater := TRUE;
            OvenTemperature := 220;

        4: (* STATE 4: COOLING & RESET *)
            (* Description: Conveyor Motor is OFF, Oven Heater is OFF (0°C). *)
            (* System waits for StopButton or StartButton to return to Idle. *)
            (* Inputs Monitored: StopButton, StartButton. *)

            (* Transition: STATE 4 -> STATE 0 *)
            (* Condition: IF StopButton = TRUE OR (StartButton = TRUE AND StopButton = FALSE) *)
            IF StopButton = TRUE OR (StartButton = TRUE AND StopButton = FALSE) THEN
                state := 0;
            END_IF;

            (* Output Assignments for STATE 4 *)
            DoughRollerMotor := FALSE;
            ToppingDispenser := FALSE;
            ConveyorMotor := FALSE;
            OvenHeater := FALSE;
            OvenTemperature := 0;
    ENDCASE

END_FUNCTION_BLOCK
END_ST