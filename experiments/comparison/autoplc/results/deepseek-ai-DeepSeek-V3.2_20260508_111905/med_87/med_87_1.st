FUNCTION_BLOCK WaterDesalination
VAR_INPUT
    StartButton : BOOL; (* Input for starting the desalination process *)
    StopButton : BOOL; (* Input for stopping the desalination process *)
    SalinitySensor : REAL; (* Input for salinity level measurement *)
END_VAR
VAR_OUTPUT
    SeawaterInletValve : BOOL; (* Output for seawater inlet valve control *)
    FreshwaterOutletValve : BOOL; (* Output for freshwater outlet valve control *)
    DesalinationInProgress : BOOL; (* Indicator for an ongoing desalination process *)
END_VAR
VAR
    MaxSalinity : REAL := 35.0; (* Maximum allowable salinity in ppm for freshwater *)
    SalinityControlSeconds : INT := 0; (* Timer for salinity control in seconds *)
    prevStartButton : BOOL := FALSE; (* Previous state of StartButton for edge detection *)
    prevStopButton : BOOL := FALSE; (* Previous state of StopButton for edge detection *)
END_VAR

(* Main control logic *)
(* Handle StartButton rising edge *)
IF StartButton AND NOT prevStartButton THEN
    (* Start process only if not already in progress *)
    IF NOT DesalinationInProgress THEN
        DesalinationInProgress := TRUE;
        SeawaterInletValve := TRUE;
        FreshwaterOutletValve := TRUE;
        SalinityControlSeconds := 0;
    END_IF;
END_IF;

(* Handle StopButton rising edge *)
IF StopButton AND NOT prevStopButton THEN
    DesalinationInProgress := FALSE;
    SeawaterInletValve := FALSE;
    FreshwaterOutletValve := FALSE;
    SalinityControlSeconds := 0;
END_IF;

(* Salinity monitoring and control - only when process is active *)
IF DesalinationInProgress THEN
    (* Increment timer *)
    SalinityControlSeconds := SalinityControlSeconds + 1;
    
    (* Check if 10 seconds have passed *)
    IF SalinityControlSeconds >= 10 THEN
        (* Compare salinity reading against maximum *)
        IF SalinitySensor > MaxSalinity THEN
            (* Close freshwater outlet valve if salinity is too high *)
            FreshwaterOutletValve := FALSE;
        ELSE
            (* Ensure freshwater outlet valve is open if salinity is acceptable *)
            FreshwaterOutletValve := TRUE;
        END_IF;
        
        (* Reset timer for next 10-second interval *)
        SalinityControlSeconds := 0;
    END_IF;
END_IF;

(* Update previous button states for next cycle *)
prevStartButton := StartButton;
prevStopButton := StopButton;

END_FUNCTION_BLOCK