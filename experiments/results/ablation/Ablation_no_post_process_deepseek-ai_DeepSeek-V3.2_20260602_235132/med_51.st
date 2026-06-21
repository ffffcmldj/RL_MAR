(*
FUNCTION_BLOCK: PizzaMakingMachine
DESCRIPTION: Oversees complete pizza production process with sequential control and safety interlocks.
AUTHOR: Senior PLC Commissioning Engineer
COMPLIANCE: IEC 61131-3 Structured Text
*)

FUNCTION_BLOCK PizzaMakingMachine
VAR_INPUT
    StartButton : BOOL;          (* Momentary start command *)
    StopButton : BOOL;           (* Emergency stop - stops all operations *)
    DoughReadySensor : BOOL;     (* TRUE when dough preparation complete *)
    ToppingsReadySensor : BOOL;  (* TRUE when toppings application complete *)
    BakingDoneSensor : BOOL;     (* TRUE when baking cycle complete *)
END_VAR

VAR_OUTPUT
    DoughRollerMotor : BOOL;     (* Controls dough roller mechanism *)
    ToppingDispenser : BOOL;     (* Controls topping application system *)
    ConveyorMotor : BOOL;        (* Controls pizza transfer to oven *)
    OvenHeater : BOOL;           (* Controls oven heating element *)
    OvenTemperature : INT;       (* Current oven temperature setpoint *)
END_VAR

VAR
    (* State Management *)
    MachineActive : BOOL;        (* Master enable for all operations *)
    BakingActive : BOOL;         (* Baking process active flag *)
    
    (* Timing Control *)
    BakeTimer : TON;             (* Baking duration timer *)
    BakeDuration : TIME := T#30S; (* Fixed 30-second baking time *)
    
    (* Safety Flags *)
    SafeToStart : BOOL;          (* System ready for start command *)
END_VAR

(*
MAIN LOGIC SEQUENCE:
1. Start/Stop Logic with safety interlocks
2. Dough Preparation Phase
3. Topping Application Phase  
4. Transfer & Baking Phase
5. Temperature Control
6. Emergency Stop Override
*)

(* --- SAFETY AND START/STOP CONTROL --- *)
(* Stop button has priority - immediately disables all operations *)
IF StopButton THEN
    MachineActive := FALSE;
ELSIF StartButton AND NOT MachineActive THEN
    (* Allow start only when system is stopped and start button is pressed *)
    MachineActive := TRUE;
END_IF;

(* --- MAIN OPERATIONAL SEQUENCE --- *)
IF MachineActive THEN
    (* PHASE 1: DOUGH PREPARATION *)
    IF NOT DoughReadySensor THEN
        DoughRollerMotor := TRUE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;
        BakingActive := FALSE;
        
    (* PHASE 2: TOPPING APPLICATION *)
    ELSIF DoughReadySensor AND NOT ToppingsReadySensor THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := TRUE;
        ConveyorMotor := FALSE;
        BakingActive := FALSE;
        
    (* PHASE 3: TRANSFER TO OVEN & BAKING *)
    ELSIF DoughReadySensor AND ToppingsReadySensor AND NOT BakingActive THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := TRUE;
        OvenHeater := TRUE;
        BakingActive := TRUE;
        
        (* Start baking timer when pizza enters oven *)
        BakeTimer(IN := TRUE, PT := BakeDuration);
        
    (* PHASE 4: BAKING IN PROGRESS *)
    ELSIF BakingActive THEN
        DoughRollerMotor := FALSE;
        ToppingDispenser := FALSE;
        ConveyorMotor := FALSE;  (* Conveyor stops during baking *)
        OvenHeater := TRUE;
        
        (* Continue timing the baking process *)
        BakeTimer(IN := TRUE, PT := BakeDuration);
        
        (* Check for baking completion - either by timer OR sensor *)
        IF BakeTimer.Q OR BakingDoneSensor THEN
            BakingActive := FALSE;
            OvenHeater := FALSE;
            BakeTimer(IN := FALSE);  (* Reset timer *)
        END_IF;
    END_IF;
    
    (* --- TEMPERATURE CONTROL --- *)
    IF OvenHeater THEN
        OvenTemperature := 220;  (* Baking temperature setpoint *)
    ELSE
        OvenTemperature := 0;    (* Oven off temperature *)
    END_IF;
    
ELSE
    (* --- EMERGENCY STOP / SYSTEM IDLE STATE --- *)
    DoughRollerMotor := FALSE;
    ToppingDispenser := FALSE;
    ConveyorMotor := FALSE;
    OvenHeater := FALSE;
    OvenTemperature := 0;
    BakingActive := FALSE;
    BakeTimer(IN := FALSE);  (* Ensure timer is reset *)
END_IF;

END_FUNCTION_BLOCK