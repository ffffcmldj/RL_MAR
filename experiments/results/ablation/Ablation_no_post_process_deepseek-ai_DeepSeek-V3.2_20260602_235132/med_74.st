(*
    Traffic Light Control System
    FUNCTION_BLOCK: TrafficManagementSystem
    Description: Controls two independent pairs of traffic lights based on vehicle count comparison.
                 Handles equal counts by maintaining the last state.
    Author: Senior PLC Commissioning Engineer
    Standard: IEC 61131-3
*)

FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    (* Primary vehicle count inputs *)
    VehicleCount1 : INT; (* Vehicle count at intersection 1 *)
    VehicleCount2 : INT; (* Vehicle count at intersection 2 *)
    VehicleCount3 : INT; (* Vehicle count at intersection 3 *)
    VehicleCount4 : INT; (* Vehicle count at intersection 4 *)
    
    (* System control inputs - from agent 3uSa *)
    EmergencyOverride : BOOL := FALSE; (* Emergency override active *)
    ManualMode : BOOL := FALSE; (* Manual control mode active *)
    ManualGreen1 : BOOL := FALSE; (* Manual green for intersection 1 *)
    ManualGreen2 : BOOL := FALSE; (* Manual green for intersection 2 *)
    ManualGreen3 : BOOL := FALSE; (* Manual green for intersection 3 *)
    ManualGreen4 : BOOL := FALSE; (* Manual green for intersection 4 *)
    SystemReset : BOOL := FALSE; (* System reset command *)
    MinimumGreenTime : TIME := T#5s; (* Minimum green time duration *)
    YellowBlinkTimer : TIME := T#1s; (* Yellow blink interval *)
END_VAR

VAR_OUTPUT
    (* Primary traffic light outputs *)
    TrafficLight1 : BOOL; (* Green light for intersection 1 *)
    TrafficLight2 : BOOL; (* Green light for intersection 2 *)
    TrafficLight3 : BOOL; (* Green light for intersection 3 *)
    TrafficLight4 : BOOL; (* Green light for intersection 4 *)
    
    (* Additional outputs - from agent 3uSa *)
    YellowLight1 : BOOL; (* Yellow light for intersection 1 *)
    YellowLight2 : BOOL; (* Yellow light for intersection 2 *)
    YellowLight3 : BOOL; (* Yellow light for intersection 3 *)
    YellowLight4 : BOOL; (* Yellow light for intersection 4 *)
    SystemFault : BOOL; (* System fault indicator *)
    CurrentActivePair : INT; (* Currently active pair (1 or 2) *)
END_VAR

VAR
    (* Internal state variables *)
    LastState1 : BOOL := FALSE; (* Last state for pair 1 *)
    LastState3 : BOOL := FALSE; (* Last state for pair 2 *)
    
    (* Timer instances - from agent 3uSa *)
    GreenTimer1 : TON;
    GreenTimer2 : TON;
    GreenTimer3 : TON;
    GreenTimer4 : TON;
    YellowTimer1 : TON;
    YellowTimer2 : TON;
    YellowTimer3 : TON;
    YellowTimer4 : TON;
    BlinkTimer : TON;
    FaultTimer : TON;
    
    (* System status flags - from agent 3uSa *)
    ManualOverrideActive : BOOL := FALSE;
    EmergencyActive : BOOL := FALSE;
    SystemInitialized : BOOL := FALSE;
    FaultCondition : BOOL := FALSE;
    BlinkState : BOOL := FALSE;
    TransitionInProgress : BOOL := FALSE;
    
    (* Vehicle count tracking - from agent 3uSa *)
    LastVehicleCount1 : INT := 0;
    LastVehicleCount2 : INT := 0;
    LastVehicleCount3 : INT := 0;
    LastVehicleCount4 : INT := 0;
    VehicleCountDelta1 : INT := 0;
    VehicleCountDelta2 : INT := 0;
    VehicleCountDelta3 : INT := 0;
    VehicleCountDelta4 : INT := 0;
    
    (* Control variables *)
    Pair1Green : BOOL := FALSE;
    Pair2Green : BOOL := FALSE;
    EqualCountFlag : BOOL := FALSE;
    PriorityThreshold : INT := 5; (* Minimum difference to change state *)
    
    (* Temporary variables for logic *)
    tmpLight1 : BOOL;
    tmpLight2 : BOOL;
    tmpLight3 : BOOL;
    tmpLight4 : BOOL;
END_VAR

(* Main program logic *)
METHOD MainLogic : BOOL
VAR_INPUT
    countA : INT;
    countB : INT;
    lastState : BOOL;
END_VAR
VAR_OUTPUT
    result : BOOL;
END_VAR
    (* Core comparison logic with equal count handling *)
    IF countA > countB THEN
        result := TRUE;
    ELSIF countB > countA THEN
        result := FALSE;
    ELSE
        (* Equal counts - maintain last state *)
        result := lastState;
    END_IF;
END_METHOD

(* System initialization *)
IF SystemReset OR NOT SystemInitialized THEN
    (* Reset all states *)
    LastState1 := FALSE;
    LastState3 := FALSE;
    TrafficLight1 := FALSE;
    TrafficLight2 := FALSE;
    TrafficLight3 := FALSE;
    TrafficLight4 := FALSE;
    YellowLight1 := FALSE;
    YellowLight2 := FALSE;
    YellowLight3 := FALSE;
    YellowLight4 := FALSE;
    SystemFault := FALSE;
    CurrentActivePair := 0;
    SystemInitialized := TRUE;
    ManualOverrideActive := FALSE;
    EmergencyActive := FALSE;
    FaultCondition := FALSE;
    TransitionInProgress := FALSE;
    
    (* Reset timers *)
    GreenTimer1(IN:=FALSE);
    GreenTimer2(IN:=FALSE);
    GreenTimer3(IN:=FALSE);
    GreenTimer4(IN:=FALSE);
    YellowTimer1(IN:=FALSE);
    YellowTimer2(IN:=FALSE);
    YellowTimer3(IN:=FALSE);
    YellowTimer4(IN:=FALSE);
    BlinkTimer(IN:=FALSE);
    FaultTimer(IN:=FALSE);
END_IF;

(* Check for emergency override *)
EmergencyActive := EmergencyOverride;
ManualOverrideActive := ManualMode AND NOT EmergencyOverride;

(* Process vehicle count deltas *)
VehicleCountDelta1 := VehicleCount1 - LastVehicleCount1;
VehicleCountDelta2 := VehicleCount2 - LastVehicleCount2;
VehicleCountDelta3 := VehicleCount3 - LastVehicleCount3;
VehicleCountDelta4 := VehicleCount4 - LastVehicleCount4;

(* Update last vehicle counts *)
LastVehicleCount1 := VehicleCount1;
LastVehicleCount2 := VehicleCount2;
LastVehicleCount3 := VehicleCount3;
LastVehicleCount4 := VehicleCount4;

(* Main control logic *)
IF EmergencyActive THEN
    (* Emergency mode: all red *)
    tmpLight1 := FALSE;
    tmpLight2 := FALSE;
    tmpLight3 := FALSE;
    tmpLight4 := FALSE;
    YellowLight1 := FALSE;
    YellowLight2 := FALSE;
    YellowLight3 := FALSE;
    YellowLight4 := FALSE;
    CurrentActivePair := 0;
    
ELSIF ManualOverrideActive THEN
    (* Manual mode *)
    tmpLight1 := ManualGreen1;
    tmpLight2 := ManualGreen2;
    tmpLight3 := ManualGreen3;
    tmpLight4 := ManualGreen4;
    CurrentActivePair := 0;
    
    (* Ensure only one light per pair is green in manual mode *)
    IF ManualGreen1 AND ManualGreen2 THEN
        tmpLight1 := TRUE;
        tmpLight2 := FALSE;
    END_IF;
    IF ManualGreen3 AND ManualGreen4 THEN
        tmpLight3 := TRUE;
        tmpLight4 := FALSE;
    END_IF;
    
ELSE
    (* Automatic mode - apply core logic with equal count handling *)
    
    (* Process pair 1: Intersections 1 and 2 *)
    tmpLight1 := MainLogic(
        countA := VehicleCount1,
        countB := VehicleCount2,
        lastState := LastState1
    );
    tmpLight2 := NOT tmpLight1;
    
    (* Process pair 2: Intersections 3 and 4 *)
    tmpLight3 := MainLogic(
        countA := VehicleCount3,
        countB := VehicleCount4,
        lastState := LastState3
    );
    tmpLight4 := NOT tmpLight3;
    
    (* Update last states *)
    LastState1 := tmpLight1;
    LastState3 := tmpLight3;
    
    (* Set current active pair indicator *)
    IF tmpLight1 OR tmpLight2 THEN
        CurrentActivePair := 1;
    ELSIF tmpLight3 OR tmpLight4 THEN
        CurrentActivePair := 2;
    ELSE
        CurrentActivePair := 0;
    END_IF;
    
    (* Check for equal counts flag *)
    EqualCountFlag := (VehicleCount1 = VehicleCount2) OR (VehicleCount3 = VehicleCount4);
END_IF;

(* Apply minimum green time logic *)
(* Pair 1 *)
IF tmpLight1 THEN
    GreenTimer1(IN:=TRUE, PT:=MinimumGreenTime);
    IF NOT GreenTimer1.Q THEN
        tmpLight1 := FALSE;
        tmpLight2 := FALSE;
        YellowLight1 := TRUE;
    ELSE
        YellowLight1 := FALSE;
    END_IF;
ELSE
    GreenTimer1(IN:=FALSE);
    YellowLight1 := FALSE;
END_IF;

IF tmpLight2 THEN
    GreenTimer2(IN:=TRUE, PT:=MinimumGreenTime);
    IF NOT GreenTimer2.Q THEN
        tmpLight1 := FALSE;
        tmpLight2 := FALSE;
        YellowLight2 := TRUE;
    ELSE
        YellowLight2 := FALSE;
    END_IF;
ELSE
    GreenTimer2(IN:=FALSE);
    YellowLight2 := FALSE;
END_IF;

(* Pair 2 *)
IF tmpLight3 THEN
    GreenTimer3(IN:=TRUE, PT:=MinimumGreenTime);
    IF NOT GreenTimer3.Q THEN
        tmpLight3 := FALSE;
        tmpLight4 := FALSE;
        YellowLight3 := TRUE;
    ELSE
        YellowLight3 := FALSE;
    END_IF;
ELSE
    GreenTimer3(IN:=FALSE);
    YellowLight3 := FALSE;
END_IF;

IF tmpLight4 THEN
    GreenTimer4(IN:=TRUE, PT:=MinimumGreenTime);
    IF NOT GreenTimer4.Q THEN
        tmpLight3 := FALSE;
        tmpLight4 := FALSE;
        YellowLight4 := TRUE;
    ELSE
        YellowLight4 := FALSE;
    END_IF;
ELSE
    GreenTimer4(IN:=FALSE);
    YellowLight4 := FALSE;
END_IF;

(* Apply yellow blink timer *)
BlinkTimer(IN:=TRUE, PT:=YellowBlinkTimer);
IF BlinkTimer.Q THEN
    BlinkState := NOT BlinkState;
    BlinkTimer(IN:=FALSE);
END_IF;

(* Apply blinking to yellow lights *)
YellowLight1 := YellowLight1 AND BlinkState;
YellowLight2 := YellowLight2 AND BlinkState;
YellowLight3 := YellowLight3 AND BlinkState;
YellowLight4 := YellowLight4 AND BlinkState;

(* Final output assignment *)
TrafficLight1 := tmpLight1;
TrafficLight2 := tmpLight2;
TrafficLight3 := tmpLight3;
TrafficLight4 := tmpLight4;

(* Fault detection *)
FaultCondition := (VehicleCount1 < 0) OR (VehicleCount2 < 0) OR 
                  (VehicleCount3 < 0) OR (VehicleCount4 < 0);
                  
FaultTimer(IN:=FaultCondition, PT:=T#2s);
SystemFault := FaultTimer.Q;

END_FUNCTION_BLOCK;