FUNCTION_BLOCK AnalogConverter
VAR_INPUT
    count : INT;                                (* Number of channels to process (1-10) *)
    analogValues : ARRAY[1..10] OF REAL;        (* Raw ADC values for each channel *)
END_VAR
VAR_OUTPUT
    channel_enable : ARRAY[1..10] OF BOOL;      (* Enable conversion for each channel *)
    channel_hiLIM : ARRAY[1..10] OF REAL;       (* Upper scaling limit *)
    channel_loLIM : ARRAY[1..10] OF REAL;       (* Lower scaling limit *)
    channel_bipolar : ARRAY[1..10] OF BOOL;     (* FALSE=Unipolar, TRUE=Bipolar *)
    channel_measuringMode : ARRAY[1..10] OF INT;(* 0=Non-temp, 1=Std temp, 2=Climatic temp *)
    channel_retVal : ARRAY[1..10] OF WORD;      (* Status/error code for each channel *)
    channel_outputValue : ARRAY[1..10] OF REAL; (* Converted output values *)
END_VAR
VAR
    i : INT;                                    (* Loop counter *)
    normalizedValue : REAL;                     (* Normalized value for scaling *)
END_VAR

(* Process each channel up to specified count *)
FOR i := 1 TO 10 DO
    IF i <= count THEN
        IF channel_enable[i] THEN
            (* Reset status for enabled channels *)
            channel_retVal[i] := 0;
            
            (* Validate measuring mode *)
            IF (channel_measuringMode[i] < 0) OR (channel_measuringMode[i] > 2) THEN
                channel_retVal[i] := 16#8001;   (* Invalid measuring mode *)
                channel_outputValue[i] := 0.0;
            ELSE
                (* Perform conversion based on measuring mode *)
                CASE channel_measuringMode[i] OF
                    0: (* Non-temperature measurement *)
                        (* Validate scaling limits *)
                        IF channel_hiLIM[i] <= channel_loLIM[i] THEN
                            channel_retVal[i] := 16#8002; (* Invalid limits *)
                            channel_outputValue[i] := 0.0;
                        ELSE
                            (* Perform scaling based on bipolar setting *)
                            IF channel_bipolar[i] THEN
                                (* Bipolar: -27648.0 to 27648.0 maps to loLIM to hiLIM *)
                                normalizedValue := (analogValues[i] + 27648.0) / (2.0 * 27648.0);
                            ELSE
                                (* Unipolar: 0.0 to 27648.0 maps to loLIM to hiLIM *)
                                normalizedValue := analogValues[i] / 27648.0;
                            END_IF;
                            
                            (* Clamp normalized value to 0.0-1.0 range *)
                            IF normalizedValue < 0.0 THEN
                                normalizedValue := 0.0;
                            ELSIF normalizedValue > 1.0 THEN
                                normalizedValue := 1.0;
                            END_IF;
                            
                            (* Apply linear scaling *)
                            channel_outputValue[i] := 
                                channel_loLIM[i] + normalizedValue * (channel_hiLIM[i] - channel_loLIM[i]);
                        END_IF;
                        
                    1: (* Standard temperature measurement *)
                        channel_outputValue[i] := analogValues[i] / 10.0;
                        
                    2: (* Climatic temperature measurement *)
                        channel_outputValue[i] := analogValues[i] / 100.0;
                END_CASE;
            END_IF;
        ELSE
            (* Channel disabled - maintain previous output value *)
            (* Note: channel_retVal remains unchanged for disabled channels *)
        END_IF;
    ELSE
        (* Beyond specified count - clear outputs *)
        channel_outputValue[i] := 0.0;
        channel_retVal[i] := 0;
    END_IF;
END_FOR;
END_FUNCTION_BLOCK