FUNCTION_BLOCK hf_7
VAR_INPUT
    count: INT;  (* Number of channels to be converted (max 10) *)
    analogValues: ARRAY[1..10] OF REAL;  (* Array of analog values (ADC counts) *)
END_VAR

VAR_OUTPUT
    channel_enable: ARRAY[1..10] OF BOOL;  (* Enable conversion for this channel *)
    channel_hiLIM: ARRAY[1..10] OF REAL;  (* Upper limit for scaling *)
    channel_loLIM: ARRAY[1..10] OF REAL;  (* Lower limit for scaling *)
    channel_bipolar: ARRAY[1..10] OF BOOL;  (* FALSE: Unipolar, TRUE: Bipolar *)
    channel_measuringMode: ARRAY[1..10] OF INT;  (* 0: Non-temperature, 1: Standard temperature, 2: Climatic temperature *)
    channel_retVal: ARRAY[1..10] OF WORD;  (* Status information *)
    channel_outputValue: ARRAY[1..10] OF REAL;  (* Converted output value *)
END_VAR

VAR
    i: INT;  (* Loop variable *)
    validCount: INT;  (* Valid channel count for processing *)
    analogInput: REAL;  (* Temporary variable for analog value *)
    hiLimit: REAL;  (* Temporary variable for high limit *)
    loLimit: REAL;  (* Temporary variable for low limit *)
    outputVal: REAL;  (* Temporary variable for output value *)
END_VAR

(* Initialize loop variable *)
i := 1;

(* Determine valid channel count - clamp to valid range 1..10 *)
IF count < 1 THEN
    validCount := 1;
ELSIF count > 10 THEN
    validCount := 10;
ELSE
    validCount := count;
END_IF;

(* Process each channel *)
FOR i := 1 TO validCount DO
    (* Reset temporary variables *)
    analogInput := analogValues[i];
    hiLimit := channel_hiLIM[i];
    loLimit := channel_loLIM[i];
    outputVal := 0.0;
    
    (* Check if channel is enabled *)
    IF channel_enable[i] THEN
        (* Validate measuring mode *)
        IF (channel_measuringMode[i] < 0) OR (channel_measuringMode[i] > 2) THEN
            (* Error: Invalid measuring mode *)
            channel_retVal[i] := 16#8001;
            CONTINUE;  (* Skip to next channel *)
        END_IF;
        
        (* Perform conversion based on measuring mode *)
        CASE channel_measuringMode[i] OF
            0:  (* Non-temperature measurement *)
                (* Validate scaling limits *)
                IF hiLimit <= loLimit THEN
                    (* Error: Invalid scaling limits *)
                    channel_retVal[i] := 16#8002;
                    CONTINUE;  (* Skip to next channel *)
                END_IF;
                
                (* Perform scaling based on bipolar setting *)
                IF channel_bipolar[i] THEN
                    (* Bipolar: Map from -27648.0 to 27648.0 *)
                    IF analogInput < -27648.0 THEN
                        analogInput := -27648.0;
                    ELSIF analogInput > 27648.0 THEN
                        analogInput := 27648.0;
                    END_IF;
                    
                    (* Linear mapping for bipolar *)
                    outputVal := loLimit + ((analogInput + 27648.0) / (27648.0 * 2.0)) * (hiLimit - loLimit);
                ELSE
                    (* Unipolar: Map from 0.0 to 27648.0 *)
                    IF analogInput < 0.0 THEN
                        analogInput := 0.0;
                    ELSIF analogInput > 27648.0 THEN
                        analogInput := 27648.0;
                    END_IF;
                    
                    (* Linear mapping for unipolar *)
                    outputVal := loLimit + (analogInput / 27648.0) * (hiLimit - loLimit);
                END_IF;
                
                (* Set success status *)
                channel_retVal[i] := 0;
                
            1:  (* Standard temperature measurement *)
                (* Set output to one-tenth of analog value *)
                outputVal := analogInput / 10.0;
                channel_retVal[i] := 0;
                
            2:  (* Climatic temperature measurement *)
                (* Set output to one-hundredth of analog value *)
                outputVal := analogInput / 100.0;
                channel_retVal[i] := 0;
                
        END_CASE;
        
        (* Store the converted value *)
        channel_outputValue[i] := outputVal;
        
    ELSE
        (* Channel disabled - set default values *)
        channel_outputValue[i] := 0.0;
        channel_retVal[i] := 0;
    END_IF;
    
END_FOR;

(* Handle remaining channels if count < 10 *)
FOR i := validCount + 1 TO 10 DO
    channel_outputValue[i] := 0.0;
    channel_retVal[i] := 0;
END_FOR;

END_FUNCTION_BLOCK