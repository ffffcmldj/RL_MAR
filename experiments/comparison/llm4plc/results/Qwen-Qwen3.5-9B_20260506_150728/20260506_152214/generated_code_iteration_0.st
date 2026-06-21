START_ST
FUNCTION_BLOCK AnalogInputConverter
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
    currentChannel : INT;
    maxChannels : INT;
    tempOutputValue : REAL;
    errorFlag : BOOL;
    tempHiLim : REAL;
    tempLoLim : REAL;
    scaleFactor : REAL;
    MAX_ADC_COUNT : REAL := 27648.0;
END_VAR

// STATE 0: INITIALIZE
// Reset state variables and prepare for execution
currentChannel := 1;
maxChannels := count;

// STATE 1: PROCESS_CHANNELS
// Iterate through each channel and perform logic
FOR currentChannel FROM 1 TO maxChannels DO
    // Evaluate Error Check 2 (Limits)
    // If channel_hiLIM <= channel_loLIM, set error and continue
    IF channel_hiLIM[currentChannel] <= channel_loLIM[currentChannel] THEN
        channel_retVal[currentChannel] := 16#8002;
        channel_outputValue[currentChannel] := 0.0; // Default value on error
        CONTINUE;
    END_IF;

    // Evaluate Error Check 1 (Mode)
    // If channel_measuringMode is not 0, 1, or 2, set error and continue
    IF channel_measuringMode[currentChannel] <> 0 AND channel_measuringMode[currentChannel] <> 1 AND channel_measuringMode[currentChannel] <> 2 THEN
        channel_retVal[currentChannel] := 16#8001;
        channel_outputValue[currentChannel] := 0.0; // Default value on error
        CONTINUE;
    END_IF;

    // Perform Conversion Logic based on Mode and Bipolar setting
    IF channel_measuringMode[currentChannel] = 0 THEN
        // Non-temperature measurement
        IF channel_bipolar[currentChannel] = FALSE THEN
            // Unipolar: Map analogValues from 0.0 to 27648.0 to channel_loLIM to channel_hiLIM
            scaleFactor := (channel_hiLIM[currentChannel] - channel_loLIM[currentChannel]) / MAX_ADC_COUNT;
            tempOutputValue := (analogValues[currentChannel] * scaleFactor) + channel_loLIM[currentChannel];
        ELSE
            // Bipolar: Map analogValues from -27648.0 to 27648.0 to channel_loLIM to channel_hiLIM
            scaleFactor := (channel_hiLIM[currentChannel] - channel_loLIM[currentChannel]) / (2.0 * MAX_ADC_COUNT);
            tempOutputValue := (analogValues[currentChannel] * scaleFactor) + channel_loLIM[currentChannel];
        END_IF;
    ELSIF channel_measuringMode[currentChannel] = 1 THEN
        // Standard temperature measurement: set channel_outputValue to one-tenth of analogValues
        tempOutputValue := analogValues[currentChannel] / 10.0;
    ELSIF channel_measuringMode[currentChannel] = 2 THEN
        // Climatic temperature measurement: set channel_outputValue to one-hundredth of analogValues
        tempOutputValue := analogValues[currentChannel] / 100.0;
    END_IF;

    // Assign results to Output Arrays
    channel_outputValue[currentChannel] := tempOutputValue;
    channel_retVal[currentChannel] := 0; // Success code
END_FOR;

// STATE 2: FINALIZE
// End of cycle logic; state machine resets for next scan (handled by loop reset in next scan)
END_FUNCTION_BLOCK
END_ST