TYPE
    E_Status : (eIdle, eRunning, eDone, eError);
END_TYPE

TYPE
    ST_SumData :
    STRUCT
        maxValue : INT;
        wData : DWORD; (* Changed from WORD to DWORD to prevent overflow *)
        currentIndex : INT;
        status : E_Status;
    END_STRUCT
END_TYPE

FUNCTION_BLOCK FB_Sum
VAR_INPUT
    maxValue : INT;
    bExecute : BOOL; (* Added for stateful execution control *)
END_VAR
VAR_OUTPUT
    wData : DWORD; (* Changed from WORD to DWORD *)
    status : E_Status;
    bDone : BOOL;
    bError : BOOL;
END_VAR
VAR
    internalData : ST_SumData;
    bExecutePrev : BOOL;
END_VAR

(* Initialize on first execution or when not executing *)
IF NOT bExecute AND bExecutePrev THEN
    internalData.status := eIdle;
    internalData.wData := 0;
    internalData.currentIndex := 0;
    bDone := FALSE;
    bError := FALSE;
END_IF;

(* Main execution logic *)
CASE internalData.status OF
    eIdle:
        IF bExecute AND NOT bExecutePrev THEN
            (* Validate input *)
            IF maxValue < 0 THEN
                internalData.status := eError;
                bError := TRUE;
            ELSE
                internalData.maxValue := maxValue;
                internalData.wData := 0;
                internalData.currentIndex := 0;
                internalData.status := eRunning;
            END_IF;
        END_IF;
        
    eRunning:
        IF internalData.currentIndex <= internalData.maxValue THEN
            internalData.wData := internalData.wData + DWORD_TO_DWORD(internalData.currentIndex);
            internalData.currentIndex := internalData.currentIndex + 1;
        ELSE
            internalData.status := eDone;
            bDone := TRUE;
        END_IF;
        
    eDone:
        (* Maintain state until execution command is released *)
        IF NOT bExecute THEN
            internalData.status := eIdle;
            bDone := FALSE;
        END_IF;
        
    eError:
        (* Maintain error state until execution command is released *)
        IF NOT bExecute THEN
            internalData.status := eIdle;
            bError := FALSE;
        END_IF;
END_CASE;

(* Update outputs *)
wData := internalData.wData;
status := internalData.status;

(* Store previous execute state for edge detection *)
bExecutePrev := bExecute;

END_FUNCTION_BLOCK;