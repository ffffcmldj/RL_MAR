START_ST
FUNCTION_BLOCK WastewaterControl
VAR_INPUT
    InFlow : REAL;
    OutFlow : REAL;
    pH : REAL;
    TankLvl : REAL;
END_VAR

VAR_OUTPUT
    Pump1 : BOOL;
    Pump2 : BOOL;
    Valve1 : BOOL;
    Valve2 : BOOL;
END_VAR

VAR
    LowInFlow : REAL := 100.0;
    HighOutFlow : REAL := 90.0;
    DesiredPH : REAL := 7.0;
    HighTankLvl : REAL := 80.0;
    state : INT;
    prevState : INT;
END_VAR

(* State machine implementation *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        Pump1 := FALSE;
        Pump2 := FALSE;
        Valve1 := FALSE;
        Valve2 := FALSE;
        state := 1; (* Transition to control state *)
        
    1: (* STATE 1: CONTROL OPERATION *)
        (* Control Pump1 based on InFlow *)
        IF InFlow < LowInFlow THEN
            Pump1 := TRUE;
        ELSE
            Pump1 := FALSE;
        END_IF;
        
        (* Control Pump2 based on OutFlow *)
        IF OutFlow > HighOutFlow THEN
            Pump2 := TRUE;
        ELSE
            Pump2 := FALSE;
        END_IF;
        
        (* Control Valve1 based on pH *)
        IF pH < DesiredPH THEN
            Valve1 := TRUE;
        ELSE
            Valve1 := FALSE;
        END_IF;
        
        (* Control Valve2 based on TankLvl *)
        IF TankLvl > HighTankLvl THEN
            Valve2 := TRUE;
        ELSE
            Valve2 := FALSE;
        END_IF;
        
        (* Remain in control state *)
        state := 1;
        
    ELSE
        (* Fallback to initialization if state is invalid *)
        state := 0;
END_CASE;

(* Track previous state for debugging/monitoring if needed *)
prevState := state;

END_FUNCTION_BLOCK
END_ST