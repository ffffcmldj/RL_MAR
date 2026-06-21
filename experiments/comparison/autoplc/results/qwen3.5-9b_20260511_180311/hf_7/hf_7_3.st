FUNCTION_BLOCK hf_7
VAR_INPUT
    count : INT;
    analogValues : ARRAY[1..10] OF REAL;
    channel_enable : ARRAY[1..10] OF BOOL;
    channel_hiLIM : ARRAY[1..10] OF REAL;
    channel_loLIM : ARRAY[1..10] OF REAL;
    channel_bipolar : ARRAY[1..10] OF BOOL;
    channel_measuringMode : ARRAY[1..10] OF INT;
END_VAR
VAR_OUTPUT
    channel_retVal : ARRAY[1..10] OF WORD;
    channel_outputValue : ARRAY[1..10] OF REAL;
END_VAR;VAR
    i : INT;
    inputSpan : REAL;
    offset : REAL;
    tempMode : INT;
    isBipolar : BOOL;
    adcValue : REAL;
    loLim : REAL;
    hiLim : REAL;
    enable : BOOL;
    retVal : WORD;

    FOR i := 1 TO count DO
        enable := channel_enable[i];
        tempMode := channel_measuringMode[i];
        loLim := channel_loLIM[i];
        hiLim := channel_hiLIM[i];
        isBipolar := channel_bipolar[i];
        adcValue := analogValues[i];
        retVal := 0;

        IF NOT enable THEN
            channel_outputValue[i] := 0.0;
            channel_retVal[i] := 0;
            CONTINUE;
        END_IF;

        IF tempMode <> 0 AND tempMode <> 1 AND tempMode <> 2 THEN
            channel_retVal[i] := 16#8001;
            channel_outputValue[i] := 0.0;
            CONTINUE;
        END_IF;

        IF hiLim <= loLim THEN
            channel_retVal[i] := 16#8002;
            channel_outputValue[i] := 0.0;
            CONTINUE;
        END_IF;

        IF tempMode = 0 THEN
            IF isBipolar THEN
                inputSpan := 55296.0;
                offset := -27648.0;
                channel_outputValue[i] := ((adcValue - offset) / inputSpan) * (hiLim - loLim) + loLim;
            ELSE
                inputSpan := 27648.0;
                channel_outputValue[i] := (adcValue / inputSpan) * (hiLim - loLim) + loLim;
            END_IF;
        ELSIF tempMode = 1 THEN
            channel_outputValue[i] := adcValue / 10.0;
        ELSIF tempMode = 2 THEN
            channel_outputValue[i] := adcValue / 100.0;
        END_IF;

        channel_retVal[i] := retVal;
    END_FOR;
END_FUNCTION_BLOCK