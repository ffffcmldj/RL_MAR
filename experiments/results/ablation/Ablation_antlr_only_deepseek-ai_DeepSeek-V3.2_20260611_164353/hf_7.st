(* ========================================================================
   FUNCTION_BLOCK: FB_AnalogBatchConverter
   Description: Batch converter for analog input signals with configurable
                scaling and temperature modes. Processes up to 10 channels
                in parallel using configuration arrays.
   Author: Senior PLC Commissioning Engineer
   IEC 61131-3 Compliant
   ======================================================================== *)

FUNCTION_BLOCK FB_AnalogBatchConverter
VAR_INPUT
    (* Number of active channels to process (1..10) *)
    count : INT;
    (* Array of raw analog input values (ADC counts) *)
    analogValues : ARRAY[1..10] OF REAL;
END_VAR

VAR_OUTPUT
    (* Parallel configuration and result arrays *)
    channel_enable : ARRAY[1..10] OF BOOL;
    channel_hiLIM : ARRAY[1..10] OF REAL;
    channel_loLIM : ARRAY[1..10] OF REAL;
    channel_bipolar : ARRAY[1..10] OF BOOL;
    channel_measuringMode : ARRAY[1..10] OF INT;
    channel_retVal : ARRAY[1..10] OF WORD;
    channel_outputValue : ARRAY[1..10] OF REAL;
END_VAR

VAR
    i : INT;                    (* Loop counter *)
    rawValue : REAL;            (* Temporary storage for raw input *)
    normalizedValue : REAL;     (* Normalized value for scaling *)
    rangeInput : REAL;          (* Input range span *)
    rangeOutput : REAL;         (* Output range span *)
    tempOutput : REAL;          (* Temporary output calculation *)
END_VAR

(* Main processing loop *)
FOR i := 1 TO 10 DO
    (* Only process if within active count range AND channel is enabled *)
    IF (i <= count) AND channel_enable[i] THEN
        (* Initialize return value for this channel *)
        channel_retVal[i] := 0;
        rawValue := analogValues[i];
        
        CASE channel_measuringMode[i] OF
            0: (* Non-temperature measurement *)
                (* Error Check 2: Validate limits *)
                IF channel_hiLIM[i] <= channel_loLIM[i] THEN
                    channel_retVal[i] := 16#8002;  (* Limit violation error *)
                    channel_outputValue[i] := 0.0;  (* Clear output on error *)
                ELSE
                    (* Calculate input range based on bipolar setting *)
                    IF channel_bipolar[i] THEN
                        rangeInput := 55296.0;  (* -27648 to +27648 *)
                        normalizedValue := (rawValue + 27648.0) / rangeInput;
                    ELSE
                        rangeInput := 27648.0;  (* 0 to 27648 *)
                        normalizedValue := rawValue / rangeInput;
                    END_IF;
                    
                    (* Clamp normalized value to valid range [0,1] *)
                    IF normalizedValue < 0.0 THEN
                        normalizedValue := 0.0;
                    ELSIF normalizedValue > 1.0 THEN
                        normalizedValue := 1.0;
                    END_IF;
                    
                    (* Calculate scaled output *)
                    rangeOutput := channel_hiLIM[i] - channel_loLIM[i];
                    channel_outputValue[i] := channel_loLIM[i] + (normalizedValue * rangeOutput);
                END_IF;
                
            1: (* Standard temperature measurement *)
                channel_outputValue[i] := rawValue / 10.0;
                
            2: (* Climatic temperature measurement *)
                channel_outputValue[i] := rawValue / 100.0;
                
            ELSE
                (* Error Check 1: Invalid measuring mode *)
                channel_retVal[i] := 16#8001;  (* Invalid mode error *)
                channel_outputValue[i] := 0.0;  (* Clear output on error *)
        END_CASE;
    ELSE
        (* Channel not enabled or outside active count range *)
        channel_outputValue[i] := 0.0;
        channel_retVal[i] := 0;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK;