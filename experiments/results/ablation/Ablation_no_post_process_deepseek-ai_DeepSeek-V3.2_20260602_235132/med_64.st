(* ============================================================================
   Bakery Oven Control System
   FUNCTION_BLOCK: BakeryOvenControl
   Description: Implements temperature and humidity regulation with deadband
                control and a baking timer. Ensures safe, mutually exclusive
                operation of opposing control elements.
   Author: Senior PLC Commissioning Engineer
   IEC 61131-3 Compliant
============================================================================ *)

FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL;     (* Current oven temperature measurement (°C) *)
    HumiditySensor    : REAL;     (* Current oven humidity measurement (%RH) *)
END_VAR

VAR_OUTPUT
    HeatingElement    : BOOL;     (* Control output for heating element *)
    CoolingElement    : BOOL;     (* Control output for cooling element *)
    HumidityControl   : BOOL;     (* Control output for humidification system *)
    DehumidityControl : BOOL;     (* Control output for dehumidification system *)
    TimerRemaining    : TIME;     (* Remaining baking time for display/feedback *)
    OvenActive        : BOOL;     (* Status: TRUE when oven is on and timer > 0 *)
END_VAR

VAR
    (* Process Setpoints - Initialized when oven is off *)
    TemperatureSetpoint : REAL := 180.0;   (* Desired oven temperature (°C) *)
    HumiditySetpoint    : REAL := 60.0;    (* Desired oven humidity (%RH) *)
    BakingTimeSet       : TIME := T#30m;   (* Total baking duration *)
    
    (* Control Parameters *)
    TemperatureThreshold : REAL := 2.0;    (* Deadband for temperature control (°C) *)
    HumidityThreshold    : REAL := 5.0;    (* Deadband for humidity control (%RH) *)
    
    (* Internal State Variables *)
    OvenStatus      : BOOL := FALSE;       (* Master enable: TRUE=On, FALSE=Off *)
    TimerActive     : BOOL := FALSE;       (* Timer is currently counting down *)
    TimerOneSec     : TON;                 (* One-second interval timer *)
    
    (* Calculated Bounds for Control *)
    TempLowerBound  : REAL;
    TempUpperBound  : REAL;
    HumidLowerBound : REAL;
    HumidUpperBound : REAL;
    
    (* Internal Timer Variable *)
    internalTimerRemaining : TIME := T#0s;
END_VAR

(* ============================================================================
   Initialization and Timer Management
   - Setpoints can be configured when oven is off
   - Timer decrements at 1-second intervals when active
============================================================================ *)

(* Initialize setpoints and reset outputs when oven is turned off *)
IF NOT OvenStatus THEN
    (* Reset all control outputs *)
    HeatingElement    := FALSE;
    CoolingElement    := FALSE;
    HumidityControl   := FALSE;
    DehumidityControl := FALSE;
    
    (* Reset timer state *)
    TimerActive := FALSE;
    internalTimerRemaining := BakingTimeSet;
    TimerOneSec(IN:=FALSE, PT:=T#1s);
    
    (* Setpoints can be modified here when oven is off *)
    (* Note: In a real application, these would typically be set via HMI or recipe *)
ELSE
    (* Start timer when oven is turned on *)
    IF NOT TimerActive THEN
        TimerActive := TRUE;
        internalTimerRemaining := BakingTimeSet;
    END_IF;
END_IF;

(* One-second timer for decrementing baking time *)
TimerOneSec(IN:=TimerActive AND (internalTimerRemaining > T#0s), PT:=T#1s);

(* Decrement timer at one-second intervals *)
IF TimerOneSec.Q THEN
    IF internalTimerRemaining >= T#1s THEN
        internalTimerRemaining := internalTimerRemaining - T#1s;
    ELSE
        internalTimerRemaining := T#0s;
    END_IF;
    TimerOneSec(IN:=FALSE);  (* Reset timer for next interval *)
END_IF;

(* Stop timer and deactivate oven when time reaches zero *)
IF internalTimerRemaining = T#0s THEN
    TimerActive := FALSE;
    OvenStatus := FALSE;
END_IF;

(* Update output variable for remaining time *)
TimerRemaining := internalTimerRemaining;

(* Oven is considered active only when both enabled and timer is running *)
OvenActive := OvenStatus AND TimerActive AND (internalTimerRemaining > T#0s);

(* ============================================================================
   Safety Validation and Bound Calculation
   - Ensure thresholds are positive to prevent inverted control logic
   - Calculate control bounds with validated thresholds
============================================================================ *)

(* Validate thresholds are positive - use absolute value as safety measure *)
TemperatureThreshold := ABS(TemperatureThreshold);
HumidityThreshold := ABS(HumidityThreshold);

(* Ensure minimum threshold values to prevent excessive cycling *)
IF TemperatureThreshold < 0.1 THEN
    TemperatureThreshold := 0.1;
END_IF;

IF HumidityThreshold < 0.5 THEN
    HumidityThreshold := 0.5;
END_IF;

(* Calculate control bounds *)
TempLowerBound  := TemperatureSetpoint - TemperatureThreshold;
TempUpperBound  := TemperatureSetpoint + TemperatureThreshold;
HumidLowerBound := HumiditySetpoint - HumidityThreshold;
HumidUpperBound := HumiditySetpoint + HumidityThreshold;

(* ============================================================================
   Temperature Control Logic
   - Heating activates when temperature < lower bound
   - Cooling activates when temperature > upper bound
   - Explicit mutual exclusion between heating and cooling
   - Both off when within deadband
============================================================================ *)

IF OvenActive THEN
    (* Temperature Control with Explicit Mutual Exclusion *)
    IF TemperatureSensor < TempLowerBound THEN
        (* Temperature too low - activate heating *)
        HeatingElement := TRUE;
        CoolingElement := FALSE;
    ELSIF TemperatureSensor > TempUpperBound THEN
        (* Temperature too high - activate cooling *)
        HeatingElement := FALSE;
        CoolingElement := TRUE;
    ELSE
        (* Temperature within acceptable range *)
        HeatingElement := FALSE;
        CoolingElement := FALSE;
    END_IF;
    
    (* Humidity Control with Explicit Mutual Exclusion *)
    IF HumiditySensor < HumidLowerBound THEN
        (* Humidity too low - activate humidification *)
        HumidityControl := TRUE;
        DehumidityControl := FALSE;
    ELSIF HumiditySensor > HumidUpperBound THEN
        (* Humidity too high - activate dehumidification *)
        HumidityControl := FALSE;
        DehumidityControl := TRUE;
    ELSE
        (* Humidity within acceptable range *)
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
    END_IF;
ELSE
    (* Oven not active - force all outputs off *)
    HeatingElement    := FALSE;
    CoolingElement    := FALSE;
    HumidityControl   := FALSE;
    DehumidityControl := FALSE;
END_IF;

(* ============================================================================
   Final Safety Interlock
   - Redundant protection against simultaneous activation
   - Ensures outputs are forced off when oven is not active
============================================================================ *)

(* Final mutual exclusion check - redundant safety *)
IF HeatingElement AND CoolingElement THEN
    HeatingElement := FALSE;
    CoolingElement := FALSE;
END_IF;

IF HumidityControl AND DehumidityControl THEN
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
END_IF;

(* Master disable - final override *)
IF NOT OvenActive THEN
    HeatingElement    := FALSE;
    CoolingElement    := FALSE;
    HumidityControl   := FALSE;
    DehumidityControl := FALSE;
END_IF;

END_FUNCTION_BLOCK;