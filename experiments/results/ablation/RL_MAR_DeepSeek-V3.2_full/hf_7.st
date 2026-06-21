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
        IF i <= count AND channel_enable[i] THEN
            channel_retVal[i] := 16#0000;
            rawValue := analogValues[i];
            
            CASE channel_measuringMode[i] OF
                0:
                    IF channel_hiLIM[i] <= channel_loLIM[i] THEN
                        channel_retVal[i] := 16#8002;
                        channel_outputValue[i] := 0.0;
                    ELSE
                        IF channel_bipolar[i] THEN
                            scaleFactor := (rawValue + 27648.0) / 55296.0;
                        ELSE
                            scaleFactor := rawValue / 27648.0;
                        END_IF;
                        channel_outputValue[i] := channel_loLIM[i] + scaleFactor * (channel_hiLIM[i] - channel_loLIM[i]);
                    END_IF;
                1:
                    channel_outputValue[i] := rawValue / 10.0;
                2:
                    channel_outputValue[i] := rawValue / 100.0;
                ELSE
                    channel_retVal[i] := 16#8001;
                    channel_outputValue[i] := 0.0;
            END_CASE;
        ELSE
            channel_outputValue[i] := 0.0;
            channel_retVal[i] := 16#0000;
        END_IF;
    END_FOR;
END_FUNCTION_BLOCK;