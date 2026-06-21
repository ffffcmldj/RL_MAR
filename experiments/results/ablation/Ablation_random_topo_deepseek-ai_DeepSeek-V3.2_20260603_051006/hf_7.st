FUNCTION_BLOCK AnalogBatchConverter
VAR_INPUT
    count : INT;
    analogValues : ARRAY[1..10] OF REAL;
END_VAR
VAR_OUTPUT
    channel_enable : ARRAY[1..10] OF BOOL;
    channel_hiLIM : ARRAY[1..10] OF REAL;
    channel_loLIM : ARRAY[1..10] OF REAL;
    channel_bipolar : ARRAY[1..10] OF BOOL;
    channel_measuringMode : ARRAY[1..10] OF INT;
    channel_retVal : ARRAY[1..10] OF WORD;
    channel_outputValue : ARRAY[1..10] OF REAL;
END_VAR
VAR
    idx : INT;
    actualCount : INT;
    rawVal : REAL;
    normalized : REAL;
    rangeSpan : REAL;
END_VAR

// Validate and limit the count parameter
actualCount := count;
IF actualCount < 1 THEN
    actualCount := 0;
ELSIF actualCount > 10 THEN
    actualCount := 10;
END_IF;

// Process each channel
FOR idx := 1 TO 10 DO
    // Initialize outputs for current channel
    channel_outputValue[idx] := 0.0;
    channel_retVal[idx] := 16#0000;
    
    // Only process if within active count range and enabled
    IF (idx <= actualCount) AND channel_enable[idx] THEN
        
        // Error Check 1: Validate measurement mode
        IF (channel_measuringMode[idx] < 0) OR (channel_measuringMode[idx] > 2) THEN
            channel_retVal[idx] := 16#8001;
            CONTINUE;
        END_IF;
        
        // Process based on measurement mode
        CASE channel_measuringMode[idx] OF
            0: // Non-temperature measurement
                // Error Check 2: Validate scaling limits
                IF channel_hiLIM[idx] <= channel_loLIM[idx] THEN
                    channel_retVal[idx] := 16#8002;
                    CONTINUE;
                END_IF;
                
                // Get raw value
                rawVal := analogValues[idx];
                
                // Calculate normalized value based on bipolar setting
                IF channel_bipolar[idx] THEN
                    // Bipolar: Map from -27648.0 to 27648.0
                    normalized := (rawVal + 27648.0) / 55296.0;
                ELSE
                    // Unipolar: Map from 0.0 to 27648.0
                    normalized := rawVal / 27648.0;
                END_IF;
                
                // Apply scaling to output range
                rangeSpan := channel_hiLIM[idx] - channel_loLIM[idx];
                channel_outputValue[idx] := channel_loLIM[idx] + (normalized * rangeSpan);
                
            1: // Standard temperature measurement (1/10 scaling)
                channel_outputValue[idx] := analogValues[idx] * 0.1;
                
            2: // Climatic temperature measurement (1/100 scaling)
                channel_outputValue[idx] := analogValues[idx] * 0.01;
                
        END_CASE;
    END_IF;
END_FOR;
END_FUNCTION_BLOCK