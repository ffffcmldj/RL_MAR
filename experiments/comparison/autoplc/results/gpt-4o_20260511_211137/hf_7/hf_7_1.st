FUNCTION_BLOCK hf_7
    VAR_INPUT
        count : INT; // Number of channels to be converted (max 10)
        analogValues : ARRAY[1..10] OF REAL; // Array of analog values (ADC counts)
        channel_enable : ARRAY[1..10] OF BOOL; // Enable conversion for this channel
        channel_hiLIM : ARRAY[1..10] OF REAL; // Upper limit for scaling
        channel_loLIM : ARRAY[1..10] OF REAL; // Lower limit for scaling
        channel_bipolar : ARRAY[1..10] OF BOOL; // FALSE: Unipolar, TRUE: Bipolar
        channel_measuringMode : ARRAY[1..10] OF INT; // Measurement mode
    END_VAR

    VAR_OUTPUT
        channel_retVal : ARRAY[1..10] OF WORD; // Status information
        channel_outputValue : ARRAY[1..10] OF REAL; // Converted output value
    END_VAR

    VAR
        i : INT; // Loop index
        scaleFactor : REAL; // Scaling factor for conversion
    END_VAR

    // Initialization
    FOR i := 1 TO 10 DO
        channel_retVal[i] := 0; // Default status
        channel_outputValue[i] := 0.0; // Default output value
    END_FOR

    // Process each channel
    FOR i := 1 TO count DO
        IF channel_enable[i] THEN
            // Error Check 1: Invalid Measuring Mode
            IF (channel_measuringMode[i] < 0) OR (channel_measuringMode[i] > 2) THEN
                channel_retVal[i] := 16#8001; // Invalid mode error
                CONTINUE;
            END_IF

            // Error Check 2: Invalid Scaling Limits
            IF channel_hiLIM[i] <= channel_loLIM[i] THEN
                channel_retVal[i] := 16#8002; // Invalid scaling range error
                CONTINUE;
            END_IF

            CASE channel_measuringMode[i] OF
                0: // Non-Temperature Measurement
                    IF NOT channel_bipolar[i] THEN
                        // Unipolar Conversion
                        scaleFactor := (channel_hiLIM[i] - channel_loLIM[i]) / 27648.0;
                        channel_outputValue[i] := channel_loLIM[i] + analogValues[i] * scaleFactor;
                    ELSE
                        // Bipolar Conversion
                        scaleFactor := (channel_hiLIM[i] - channel_loLIM[i]) / (2 * 27648.0);
                        channel_outputValue[i] := channel_loLIM[i] + (analogValues[i] + 27648.0) * scaleFactor;
                    END_IF
                1: // Standard Temperature Measurement
                    channel_outputValue[i] := analogValues[i] * 0.1;
                2: // Climatic Temperature Measurement
                    channel_outputValue[i] := analogValues[i] * 0.01;
            END_CASE
        END_IF
    END_FOR
END_FUNCTION_BLOCK