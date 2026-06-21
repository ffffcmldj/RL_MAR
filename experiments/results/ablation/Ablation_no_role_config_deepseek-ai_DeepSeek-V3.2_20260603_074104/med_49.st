FUNCTION_BLOCK SmartHVACSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Temperature sensor reading *)
    HumiditySensor : REAL; (* Humidity sensor reading *)
    Enable : BOOL := TRUE; (* System enable *)
    Reset : BOOL := FALSE; (* System reset *)
    ManualMode : BOOL := FALSE; (* Manual mode override *)
    ManualHVACMode : INT := 0; (* Manual HVAC mode: 0=Off, 1=Cooling, 2=Heating, 3=Ventilation *)
    ManualFanSpeed : INT := 0; (* Manual fan speed: 0=Off, 1=Low, 2=Medium, 3=High *)
END_VAR

VAR_OUTPUT
    HVACMode : INT := 0; (* HVAC operating mode: 0=Off, 1=Cooling, 2=Heating, 3=Ventilation *)
    HVACFanSpeed : INT := 0; (* Fan speed: 0=Off, 1=Low, 2=Medium, 3=High *)
    SystemActive : BOOL := FALSE; (* System active status *)
    Alarm : BOOL := FALSE; (* System alarm *)
END_VAR

VAR
    DesiredTemperature : REAL := 24.0; (* Desired temperature setting *)
    DesiredHumidity : REAL := 50.0; (* Desired humidity setting *)
    TemperatureThreshold : REAL := 1.0; (* Temperature tolerance threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity tolerance threshold *)
    
    AdjustedHumidity : REAL; (* Sanitized humidity input *)
    AdjustedTemperature : REAL; (* Sanitized temperature input *)
    
    NeedsVentilation : BOOL; (* Flag for ventilation requirement *)
    NeedsHeating : BOOL; (* Flag for heating requirement *)
    NeedsCooling : BOOL; (* Flag for cooling requirement *)
    
    TempSanitized : BOOL; (* Temperature sanitization status *)
    HumSanitized : BOOL; (* Humidity sanitization status *)
    
    ModeTimer : TON; (* Timer for mode changes *)
    FanTimer : TON; (* Timer for fan speed changes *)
    
    TempArray : ARRAY[1..10] OF REAL; (* Temperature history buffer *)
    HumArray : ARRAY[1..10] OF REAL; (* Humidity history buffer *)
    AvgTemperature : REAL; (* Average temperature *)
    AvgHumidity : REAL; (* Average humidity *)
    
    i : INT; (* Loop counter *)
    ArrayIndex : INT := 1; (* Current array index *)
    SampleCount : INT := 0; (* Number of samples collected *)
END_VAR

// Main execution logic
IF Reset THEN
    // Reset system
    HVACMode := 0;
    HVACFanSpeed := 0;
    SystemActive := FALSE;
    Alarm := FALSE;
    AdjustedHumidity := 0.0;
    AdjustedTemperature := 0.0;
    NeedsVentilation := FALSE;
    NeedsHeating := FALSE;
    NeedsCooling := FALSE;
    TempSanitized := FALSE;
    HumSanitized := FALSE;
    AvgTemperature := 0.0;
    AvgHumidity := 0.0;
    SampleCount := 0;
    ArrayIndex := 1;
    
    FOR i := 1 TO 10 DO
        TempArray[i] := 0.0;
        HumArray[i] := 0.0;
    END_FOR;
    
ELSIF Enable THEN
    SystemActive := TRUE;
    
    // 1. Input Sanitization
    // Sanitize humidity input
    IF HumiditySensor < 0.0 THEN
        AdjustedHumidity := 0.0;
        HumSanitized := TRUE;
    ELSIF HumiditySensor > 100.0 THEN
        AdjustedHumidity := 100.0;
        HumSanitized := TRUE;
    ELSE
        AdjustedHumidity := HumiditySensor;
        HumSanitized := TRUE;
    END_IF;
    
    // Sanitize temperature input
    IF TemperatureSensor < -50.0 THEN
        AdjustedTemperature := -50.0;
        TempSanitized := TRUE;
    ELSIF TemperatureSensor > 100.0 THEN
        AdjustedTemperature := 100.0;
        TempSanitized := TRUE;
    ELSE
        AdjustedTemperature := TemperatureSensor;
        TempSanitized := TRUE;
    END_IF;
    
    // Check for sensor alarm conditions
    Alarm := NOT (TempSanitized AND HumSanitized);
    
    // 2. Data averaging for stability
    TempArray[ArrayIndex] := AdjustedTemperature;
    HumArray[ArrayIndex] := AdjustedHumidity;
    
    ArrayIndex := ArrayIndex + 1;
    IF ArrayIndex > 10 THEN
        ArrayIndex := 1;
    END_IF;
    
    IF SampleCount < 10 THEN
        SampleCount := SampleCount + 1;
    END_IF;
    
    // Calculate averages
    AvgTemperature := 0.0;
    AvgHumidity := 0.0;
    FOR i := 1 TO SampleCount DO
        AvgTemperature := AvgTemperature + TempArray[i];
        AvgHumidity := AvgHumidity + HumArray[i];
    END_FOR;
    
    IF SampleCount > 0 THEN
        AvgTemperature := AvgTemperature / SampleCount;
        AvgHumidity := AvgHumidity / SampleCount;
    END_IF;
    
    // 3. Determine System Requirements using averaged values
    // Ventilation requirement
    IF AvgHumidity < (DesiredHumidity - HumidityThreshold) THEN
        NeedsVentilation := TRUE;
    ELSE
        NeedsVentilation := FALSE;
    END_IF;
    
    // Heating requirement
    IF AvgTemperature < (DesiredTemperature - TemperatureThreshold) THEN
        NeedsHeating := TRUE;
    ELSE
        NeedsHeating := FALSE;
    END_IF;
    
    // Cooling requirement
    IF AvgTemperature > (DesiredTemperature + TemperatureThreshold) THEN
        NeedsCooling := TRUE;
    ELSE
        NeedsCooling := FALSE;
    END_IF;
    
    // 4. Control Logic with prioritization
    IF ManualMode THEN
        // Manual mode override
        HVACMode := LIMIT(0, ManualHVACMode, 3);
        HVACFanSpeed := LIMIT(0, ManualFanSpeed, 3);
    ELSE
        // Automatic mode with prioritization
        IF NeedsHeating THEN
            HVACMode := 2; // Heating
            HVACFanSpeed := 3; // High
        ELSIF NeedsCooling THEN
            HVACMode := 1; // Cooling
            HVACFanSpeed := 3; // High
        ELSIF NeedsVentilation THEN
            HVACMode := 3; // Ventilation
            HVACFanSpeed := 3; // High
        ELSE
            HVACMode := 0; // Off
            HVACFanSpeed := 0; // Off
        END_IF;
    END_IF;
    
    // Apply timers for mode stability
    ModeTimer(IN := (HVACMode <> 0), PT := T#2S);
    FanTimer(IN := (HVACFanSpeed <> 0), PT := T#1S);
    
    // Ensure system only reports active when timers are done
    IF NOT ModeTimer.Q THEN
        HVACMode := 0;
    END_IF;
    
    IF NOT FanTimer.Q THEN
        HVACFanSpeed := 0;
    END_IF;
    
ELSE
    // System disabled
    SystemActive := FALSE;
    HVACMode := 0;
    HVACFanSpeed := 0;
    NeedsVentilation := FALSE;
    NeedsHeating := FALSE;
    NeedsCooling := FALSE;
END_IF;

END_FUNCTION_BLOCK