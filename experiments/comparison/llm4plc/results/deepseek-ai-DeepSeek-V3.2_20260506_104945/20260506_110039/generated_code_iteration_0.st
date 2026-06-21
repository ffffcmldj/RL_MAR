START_ST
FUNCTION_BLOCK FB_AnalogBatchConverter
VAR_INPUT
    count : INT; (* Number of channels to process (1..10) *)
    analogValues : ARRAY[1..10] OF REAL; (* Input analog values (ADC counts) *)
    channel_enable : ARRAY[1..10] OF BOOL; (* Enable conversion per channel *)
    channel_hiLIM : ARRAY[1..10] OF REAL; (* Upper scaling limit *)
    channel_loLIM : ARRAY[1..10] OF REAL; (* Lower scaling limit *)
    channel_bipolar : ARRAY[1..10] OF BOOL; (* FALSE=Unipolar, TRUE=Bipolar *)
    channel_measuringMode : ARRAY[1..10] OF INT; (* 0=Non-temp, 1=Std temp, 2=Climatic temp *)
END_VAR
VAR_OUTPUT
    channel_retVal : ARRAY[1..10] OF WORD; (* Status/error code per channel *)
    channel_outputValue : ARRAY[1..10] OF REAL; (* Converted output value per channel *)
END_VAR
VAR
    i : INT; (* Loop index *)
    tempAnalog : REAL; (* Temporary analog value *)
    tempBipolar : BOOL; (* Temporary bipolar flag *)
    tempHiLim : REAL; (* Temporary high limit *)
    tempLoLim : REAL; (* Temporary low limit *)
    tempMode : INT; (* Temporary measuring mode *)
    tempEnable : BOOL; (* Temporary enable flag *)
END_VAR

(* Main processing loop *)
FOR i := 1 TO 10 DO
    (* Initialize temporary variables for current channel *)
    tempAnalog := analogValues[i];
    tempBipolar := channel_bipolar[i];
    tempHiLim := channel_hiLIM[i];
    tempLoLim := channel_loLIM[i];
    tempMode := channel_measuringMode[i];
    tempEnable := channel_enable[i];
    
    (* Process only if channel index is within 'count' and enabled *)
    IF (i <= count) AND tempEnable THEN
        (* Validate measuring mode *)
        IF (tempMode < 0) OR (tempMode > 2) THEN
            channel_retVal[i] := 16#8001; (* Invalid mode error *)
            channel_outputValue[i] := 0.0;
            CONTINUE; (* Proceed to next channel *)
        END_IF
        
        (* Validate scaling limits for non-temperature mode *)
        IF (tempMode = 0) AND (tempHiLim <= tempLoLim) THEN
            channel_retVal[i] := 16#8002; (* Invalid limits error *)
            channel_outputValue[i] := 0.0;
            CONTINUE; (* Proceed to next channel *)
        END_IF
        
        (* Perform conversion based on measuring mode *)
        CASE tempMode OF
            0: (* Non-temperature measurement *)
                IF tempBipolar THEN
                    (* Bipolar: map from -27648.0..27648.0 to loLIM..hiLIM *)
                    channel_outputValue[i] := tempLoLim + ((tempAnalog + 27648.0) / (2 * 27648.0)) * (tempHiLim - tempLoLim);
                ELSE
                    (* Unipolar: map from 0.0..27648.0 to loLIM..hiLIM *)
                    channel_outputValue[i] := tempLoLim + (tempAnalog / 27648.0) * (tempHiLim - tempLoLim);
                END_IF
                channel_retVal[i] := 0; (* Success *)
                
            1: (* Standard temperature measurement *)
                channel_outputValue[i] := tempAnalog / 10.0; (* One-tenth *)
                channel_retVal[i] := 0; (* Success *)
                
            2: (* Climatic temperature measurement *)
                channel_outputValue[i] := tempAnalog / 100.0; (* One-hundredth *)
                channel_retVal[i] := 0; (* Success *)
                
        END_CASE
        
    ELSE
        (* Channel disabled or beyond 'count' *)
        channel_outputValue[i] := 0.0;
        channel_retVal[i] := 0; (* Default status for disabled/out-of-range *)
    END_IF
    
END_FOR

END_FUNCTION_BLOCK
END_ST