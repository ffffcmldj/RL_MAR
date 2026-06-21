FUNCTION_BLOCK hf_7
VAR_INPUT
    count : INT; // Number of channels to be converted (max 10)
    analogValues : ARRAY[1..10] OF REAL; // Array of analog values (ADC counts)
END_VAR_INPUT

VAR_OUTPUT
    channel_enable : ARRAY[1..10] OF BOOL; // Enable conversion for this channel
    channel_hiLIM : ARRAY[1..10] OF REAL; // Upper limit for scaling
    channel_loLIM : ARRAY[1..10] OF REAL; // Lower limit for scaling
    channel_bipolar : ARRAY[1..10] OF BOOL; // FALSE: Unipolar, TRUE: Bipolar
    channel_measuringMode : ARRAY[1..10] OF INT; // Measurement mode
    channel_retVal : ARRAY[1..10] OF WORD; // Status information
    channel_outputValue : ARRAY[1..10] OF REAL; // Converted output value
END_VAR_OUTPUT

VAR
    i : INT; // Loop variable
    mappedValue : REAL; // Temporary variable for mapped value
END_VAR

// Initialization
FOR i := 1 TO 10 DO
    channel_retVal[i] := 0; // Initialize status information
    channel_outputValue[i] := 0.0; // Initialize output value
END_FOR

// Loop through channels
FOR i := 1 TO count DO
    // Check if the channel is enabled
    IF channel_enable[i] THEN
        // Retrieve necessary parameters
        VAR
            currentAnalogValue : REAL := analogValues[i];
            currentBipolar : BOOL := channel_bipolar[i];
            currentMeasuringMode : INT := channel_measuringMode[i];
            currentHiLIM : REAL := channel_hiLIM[i];
            currentLoLIM : REAL := channel_loLIM[i];
        END_VAR
        
        // Error Check 1: Validate measuring mode
        IF (currentMeasuringMode < 0) OR (currentMeasuringMode > 2) THEN
            channel_retVal[i] := 16#8001; // Invalid measuring mode
            CONTINUE; // Skip to next channel
        END_IF
        
        // Error Check 2: Validate limits
        IF currentHiLIM <= currentLoLIM THEN
            channel_retVal[i] := 16#8002; // Invalid limits
            CONTINUE; // Skip to next channel
        END_IF
        
        // Measurement Mode Handling
        CASE currentMeasuringMode OF
            0: // Non-temperature
                IF currentBipolar THEN // Bipolar
                    IF currentAnalogValue < 0 THEN
                        mappedValue := currentLoLIM + ((currentAnalogValue + 27648.0) / 55296.0) * (currentHiLIM - currentLoLIM);
                    ELSE // Unipolar
                        mappedValue := currentLoLIM + (currentAnalogValue / 27648.0) * (currentHiLIM - currentLoLIM);
                    END_IF
                ELSE // Unipolar
                    mappedValue := currentLoLIM + (currentAnalogValue / 27648.0) * (currentHiLIM - currentLoLIM);
                END_IF
                channel_outputValue[i] := mappedValue;
                
            1: // Standard temperature
                channel_outputValue[i] := currentAnalogValue / 10.0;
                
            2: // Climatic temperature
                channel_outputValue[i] := currentAnalogValue / 100.0;
        END_CASE
    END_IF
END_FOR
END_FUNCTION_BLOCK