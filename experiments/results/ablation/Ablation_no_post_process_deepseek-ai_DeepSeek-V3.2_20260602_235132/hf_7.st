(*
    FUNCTION_BLOCK AnalogBatchConverter
    Purpose: Batch conversion of analog input signals to engineering units.
    Processes up to 10 channels in parallel based on configuration arrays.
    
    Inputs:
        count (INT): Number of active channels to process (1..10).
        analogValues (ARRAY[1..10] OF REAL): Raw ADC input values per channel.
    
    Configuration/Output Arrays (Index 1..10):
        channel_enable (BOOL): Enable conversion for this channel.
        channel_hiLIM (REAL): Upper scaling limit for non-temperature mode.
        channel_loLIM (REAL): Lower scaling limit for non-temperature mode.
        channel_bipolar (BOOL): Input range flag (FALSE=Unipolar, TRUE=Bipolar).
        channel_measuringMode (INT): Conversion mode (0=Non-temp, 1=Std temp, 2=Climatic temp).
        channel_retVal (WORD): Status/error code per channel (0=OK).
        channel_outputValue (REAL): Converted output value in engineering units.
    
    Error Codes:
        16#8001: Invalid measuringMode value (not 0, 1, or 2).
        16#8002: Invalid scaling range (channel_hiLIM <= channel_loLIM).
*)

FUNCTION_BLOCK AnalogBatchConverter
VAR_INPUT
    count : INT;                            (* Number of channels to process (1..10) *)
    analogValues : ARRAY[1..10] OF REAL;    (* Raw ADC input values per channel *)
END_VAR

VAR_OUTPUT
    channel_enable : ARRAY[1..10] OF BOOL;      (* Enable flag per channel *)
    channel_hiLIM : ARRAY[1..10] OF REAL;       (* Upper scaling limit per channel *)
    channel_loLIM : ARRAY[1..10] OF REAL;       (* Lower scaling limit per channel *)
    channel_bipolar : ARRAY[1..10] OF BOOL;     (* Input range flag per channel *)
    channel_measuringMode : ARRAY[1..10] OF INT;(* Conversion mode per channel *)
    channel_retVal : ARRAY[1..10] OF WORD;      (* Status/error code per channel *)
    channel_outputValue : ARRAY[1..10] OF REAL; (* Converted output value per channel *)
END_VAR

VAR
    i : INT;                (* Loop counter *)
    rawValue : REAL;        (* Temporary storage for analog input *)
    hiLIM : REAL;           (* Temporary storage for high limit *)
    loLIM : REAL;           (* Temporary storage for low limit *)
    bipolar : BOOL;         (* Temporary storage for bipolar flag *)
    measuringMode : INT;    (* Temporary storage for measuring mode *)
    enable : BOOL;          (* Temporary storage for enable flag *)
    retVal : WORD;          (* Temporary storage for return value *)
    outputValue : REAL;     (* Temporary storage for output value *)
END_VAR

(* Main processing loop for all 10 channels *)
FOR i := 1 TO 10 DO
    (* Load configuration and input values for current channel *)
    enable := channel_enable[i];
    hiLIM := channel_hiLIM[i];
    loLIM := channel_loLIM[i];
    bipolar := channel_bipolar[i];
    measuringMode := channel_measuringMode[i];
    rawValue := analogValues[i];
    
    (* Initialize temporary variables for this channel *)
    retVal := 0;
    outputValue := 0.0;
    
    (* Process only if channel is within active count and enabled *)
    IF (i <= count) AND enable THEN
        CASE measuringMode OF
            0:  (* Non-temperature measurement - perform linear scaling *)
                IF hiLIM <= loLIM THEN
                    retVal := 16#8002;  (* Invalid scaling range error *)
                ELSE
                    IF bipolar THEN
                        (* Bipolar scaling: -27648.0 to 27648.0 maps to loLIM to hiLIM *)
                        outputValue := loLIM + ((rawValue + 27648.0) / (27648.0 * 2.0)) * (hiLIM - loLIM);
                    ELSE
                        (* Unipolar scaling: 0.0 to 27648.0 maps to loLIM to hiLIM *)
                        outputValue := loLIM + (rawValue / 27648.0) * (hiLIM - loLIM);
                    END_IF;
                END_IF;
                
            1:  (* Standard temperature measurement - divide by 10 *)
                outputValue := rawValue / 10.0;
                
            2:  (* Climatic temperature measurement - divide by 100 *)
                outputValue := rawValue / 100.0;
                
            ELSE
                (* Invalid measuring mode *)
                retVal := 16#8001;
        END_CASE;
    END_IF;
    
    (* Store results back to output arrays *)
    channel_retVal[i] := retVal;
    channel_outputValue[i] := outputValue;
END_FOR;

END_FUNCTION_BLOCK;