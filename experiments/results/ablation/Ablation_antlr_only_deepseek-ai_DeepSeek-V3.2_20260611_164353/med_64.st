(* ======================================================================= *)
(* BAKERY OVEN CONTROL SYSTEM - FINAL PRODUCTION CODE                      *)
(* IEC 61131-3 Structured Text                                             *)
(* Senior PLC Commissioning Engineer - Final Authority                     *)
(* ======================================================================= *)
(* FUNCTION_BLOCK: BakeryOvenControl                                       *)
(* Purpose: Regulates oven temperature and humidity within configurable    *)
(*          deadbands and manages a baking timer.                          *)
(* Safety: Ensures mutual exclusion of opposing control actions and        *)
(*         forces safe shutdown when timer expires or oven is off.         *)
(* ======================================================================= *)

FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    (* --- Process Inputs --- *)
    TemperatureSensor : REAL;        (* Current oven temperature [°C] *)
    HumiditySensor    : REAL;        (* Current oven humidity [%RH] *)
    
    (* --- Configuration & Command Inputs --- *)
    SetTemperature    : REAL;        (* Desired temperature setpoint [°C] *)
    SetHumidity       : REAL;        (* Desired humidity setpoint [%RH] *)
    SetBakingTime     : TIME;        (* Desired baking duration [TIME] *)
    OvenEnable        : BOOL;        (* Master enable command *)
    
    (* --- Tuning Parameters --- *)
    TempThreshold     : REAL := 2.0; (* Temperature deadband [°C] *)
    HumidThreshold    : REAL := 5.0; (* Humidity deadband [%RH] *)
END_VAR

VAR_OUTPUT
    (* --- Actuator Outputs --- *)
    HeatingElement    : BOOL;        (* Control signal for heating *)
    CoolingElement    : BOOL;        (* Control signal for cooling *)
    HumidityControl   : BOOL;        (* Control signal for humidification *)
    DehumidityControl : BOOL;        (* Control signal for dehumidification *)
    
    (* --- Status Outputs --- *)
    TimerRemaining    : TIME;        (* Remaining baking time *)
    OvenActive        : BOOL;        (* TRUE when oven is regulating *)
    BakingComplete    : BOOL;        (* TRUE when timer reaches zero *)
END_VAR

VAR
    (* --- Internal Process Variables --- *)
    rTempSetpoint     : REAL;        (* Active temperature setpoint *)
    rHumidSetpoint    : REAL;        (* Active humidity setpoint *)
    tBakingTimePreset : TIME;        (* Active baking time preset *)
    
    (* --- Control Calculation Variables --- *)
    rTempLowerBound   : REAL;        (* Lower temperature threshold *)
    rTempUpperBound   : REAL;        (* Upper temperature threshold *)
    rHumidLowerBound  : REAL;        (* Lower humidity threshold *)
    rHumidUpperBound  : REAL;        (* Upper humidity threshold *)
    
    (* --- Timer Infrastructure --- *)
    tonOneSecond      : TON;         (* Standard one-shot timer *)
    bTimerEnable      : BOOL;        (* Timer enable flag *)
    tTimeCounter      : TIME;        (* Countdown timer *)
    
    (* --- Edge Detection --- *)
    bOvenEnablePrev   : BOOL;        (* Previous state for edge detection *)
END_VAR

(* ======================================================================= *)
(* MAIN EXECUTION LOGIC                                                    *)
(* ======================================================================= *)

(* --- Initialization & Setpoint Management --- *)
(* Setpoints can only be updated when the oven is disabled (safe state).   *)
(* This prevents runtime changes that could disrupt the baking process.    *)
IF NOT OvenEnable THEN
    rTempSetpoint := SetTemperature;
    rHumidSetpoint := SetHumidity;
    tBakingTimePreset := SetBakingTime;
END_IF;

(* --- Oven State Machine --- *)
IF OvenEnable AND (tTimeCounter > T#0s) THEN
    OvenActive := TRUE;
    BakingComplete := FALSE;
    
    (* --- Calculate Control Bounds --- *)
    rTempLowerBound := rTempSetpoint - TempThreshold;
    rTempUpperBound := rTempSetpoint + TempThreshold;
    rHumidLowerBound := rHumidSetpoint - HumidThreshold;
    rHumidUpperBound := rHumidSetpoint + HumidThreshold;
    
    (* --- Temperature Control with Mutual Exclusion --- *)
    IF TemperatureSensor < rTempLowerBound THEN
        HeatingElement := TRUE;
        CoolingElement := FALSE;
    ELSIF TemperatureSensor > rTempUpperBound THEN
        HeatingElement := FALSE;
        CoolingElement := TRUE;
    ELSE
        HeatingElement := FALSE;
        CoolingElement := FALSE;
    END_IF;
    
    (* --- Humidity Control with Mutual Exclusion --- *)
    IF HumiditySensor < rHumidLowerBound THEN
        HumidityControl := TRUE;
        DehumidityControl := FALSE;
    ELSIF HumiditySensor > rHumidUpperBound THEN
        HumidityControl := FALSE;
        DehumidityControl := TRUE;
    ELSE
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
    END_IF;
    
    (* --- Baking Timer Logic --- *)
    (* Detect rising edge of OvenEnable to load the timer preset. *)
    IF (OvenEnable AND NOT bOvenEnablePrev) THEN
        tTimeCounter := tBakingTimePreset;
        bTimerEnable := TRUE;
    END_IF;
    
    (* Use standard TON timer for precise one-second intervals. *)
    tonOneSecond(IN:= bTimerEnable, PT:= T#1s);
    
    (* Decrement counter on each timer completion. *)
    IF tonOneSecond.Q THEN
        IF tTimeCounter >= T#1s THEN
            tTimeCounter := tTimeCounter - T#1s;
        ELSE
            tTimeCounter := T#0s;
        END_IF;
        (* Reset the one-shot timer for the next interval. *)
        tonOneSecond(IN:= FALSE, PT:= T#1s);
    END_IF;
    
    (* --- Timer Expiry Handling --- *)
    IF tTimeCounter <= T#0s THEN
        BakingComplete := TRUE;
        OvenActive := FALSE;
        bTimerEnable := FALSE;
        (* Force safe shutdown of all actuators. *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
    END_IF;
    
ELSE
    (* --- Oven Disabled or Timer Expired State --- *)
    OvenActive := FALSE;
    
    (* Force deactivation of all control outputs. *)
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
    
    (* Reset timer infrastructure when oven is disabled. *)
    IF NOT OvenEnable THEN
        tTimeCounter := T#0s;
        bTimerEnable := FALSE;
        tonOneSecond(IN:= FALSE, PT:= T#1s);
        BakingComplete := FALSE;
    END_IF;
END_IF;

(* --- Update Status Outputs --- *)
TimerRemaining := tTimeCounter;

(* --- Store previous state for edge detection --- *)
bOvenEnablePrev := OvenEnable;

END_FUNCTION_BLOCK