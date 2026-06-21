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
    i : INT;
    rawValue : REAL;
    scaleFactor : REAL;
END_VAR

FOR i := 1 TO 10 DO
    channel_retVal[i] := 16#0000;
    channel_outputValue[i] := 0.0;
    
    IF (i <= count) AND channel_enable[i] THEN
        rawValue := analogValues[i];
        
        CASE channel_measuringMode[i] OF
            0:  // Non-temperature measurement
                IF channel_hiLIM[i] <= channel_loLIM[i] THEN
                    channel_retVal[i] := 16#8002;
                ELSE
                    IF channel_bipolar[i] THEN
                        // Bipolar: map from -27648.0 to 27648.0
                        scaleFactor := (rawValue + 27648.0) / (2.0 * 27648.0);
                    ELSE
                        // Unipolar: map from 0.0 to 27648.0
                        scaleFactor := rawValue / 27648.0;
                    END_IF
                    channel_outputValue[i] := channel_loLIM[i] + scaleFactor * (channel_hiLIM[i] - channel_loLIM[i]);
                END_IF
                
            1:  // Standard temperature measurement
                channel_outputValue[i] := rawValue / 10.0;
                
            2:  // Climatic temperature measurement
                channel_outputValue[i] := rawValue / 100.0;
                
            ELSE
                channel_retVal[i] := 16#8001;
        END_CASE
    END_IF
END_FOR
END_FUNCTION_BLOCK