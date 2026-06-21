START_ST
FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL;
    StopButton : BOOL;
    SalinitySensor : REAL;
END_VAR
VAR_OUTPUT
    SeawaterInletValve : BOOL;
    FreshwaterOutletValve : BOOL;
    DesalinationInProgress : BOOL;
END_VAR
VAR
    MaxSalinity : REAL := 35.0;
    SalinityControlSeconds : INT := 0;
    state : INT := 0;
    prevState : INT := 0;
    internalTimer : TON;
    lastSalinityCheckTime : TIME;
    startButtonRisingEdge : BOOL;
    prevStartButton : BOOL;
END_VAR

    (* Edge detection for StartButton *)
    startButtonRisingEdge := StartButton AND NOT prevStartButton;
    prevStartButton := StartButton;

    (* State machine transitions *)
    CASE state OF
        0: (* IDLE *)
            IF startButtonRisingEdge AND NOT DesalinationInProgress THEN
                state := 1;
            END_IF;
            
        1: (* RUNNING *)
            (* Immediately transition to STATE 2 for salinity monitoring *)
            state := 2;
            
        2: (* RUNNING_WITH_SALINITY_CHECK *)
            (* Check if StopButton is pressed *)
            IF StopButton THEN
                state := 0;
            ELSE
                (* Check if 10 seconds have passed for salinity monitoring *)
                internalTimer(IN := TRUE, PT := T#10S);
                IF internalTimer.Q THEN
                    (* 10 seconds elapsed, check salinity *)
                    IF SalinitySensor > MaxSalinity THEN
                        FreshwaterOutletValve := FALSE;
                    ELSE
                        FreshwaterOutletValve := TRUE;
                    END_IF;
                    internalTimer(IN := FALSE);
                END_IF;
            END_IF;
    END_CASE;

    (* State machine outputs *)
    CASE state OF
        0: (* IDLE *)
            SeawaterInletValve := FALSE;
            FreshwaterOutletValve := FALSE;
            DesalinationInProgress := FALSE;
            SalinityControlSeconds := 0;
            internalTimer(IN := FALSE);
            
        1: (* RUNNING *)
            SeawaterInletValve := TRUE;
            FreshwaterOutletValve := TRUE;
            DesalinationInProgress := TRUE;
            
        2: (* RUNNING_WITH_SALINITY_CHECK *)
            SeawaterInletValve := TRUE;
            DesalinationInProgress := TRUE;
            (* FreshwaterOutletValve handled in transition logic *)
    END_CASE;

    (* Track previous state for debugging if needed *)
    prevState := state;

END_FUNCTION_BLOCK
END_ST