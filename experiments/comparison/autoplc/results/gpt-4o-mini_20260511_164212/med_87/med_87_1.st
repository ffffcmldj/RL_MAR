FUNCTION_BLOCK WaterDesalination
    VAR_INPUT
        StartButton : BOOL; (* Input for starting the desalination process *)
        StopButton : BOOL;  (* Input for stopping the desalination process *)
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
        TimerCheck : INT := 0; (* Timer for checking salinity every 10 seconds *)
    END_VAR

    // Main control logic
    IF StartButton AND NOT DesalinationInProgress THEN
        // Start desalination process
        SeawaterInletValve := TRUE;
        FreshwaterOutletValve := TRUE;
        DesalinationInProgress := TRUE;
    END_IF;

    IF StopButton THEN
        // Stop desalination process
        SeawaterInletValve := FALSE;
        FreshwaterOutletValve := FALSE;
        DesalinationInProgress := FALSE;
        SalinityControlSeconds := 0;
    END_IF;

    // Increment timer every second
    TimerCheck := TimerCheck + 1;

    // Check salinity every 10 seconds
    IF TimerCheck >= 10 THEN
        TimerCheck := 0; // Reset timer

        // Salinity monitoring
        IF SalinitySensor > MaxSalinity THEN
            FreshwaterOutletValve := FALSE; // Close outlet valve if salinity is too high
        ELSE
            FreshwaterOutletValve := TRUE; // Keep outlet valve open if salinity is acceptable
        END_IF;

        // Increment salinity control seconds
        SalinityControlSeconds := SalinityControlSeconds + 10;
    END_IF;

END_FUNCTION_BLOCK