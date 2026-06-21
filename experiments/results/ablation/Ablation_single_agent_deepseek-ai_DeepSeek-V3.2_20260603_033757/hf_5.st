FUNCTION_BLOCK SelectSort
VAR_INPUT
    exe : BOOL;
    seq : ARRAY[1..100] OF INT;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
END_VAR
VAR
    i : INT;
    j : INT;
    minIndex : INT;
    temp : INT;
    n : INT := 100;
    seqLocal : ARRAY[1..100] OF INT;
    exePrev : BOOL;
    sortSuccessful : BOOL;
END_VAR

(* Initialize outputs *)
error := TRUE;
status := 16#8A01;
sortSuccessful := TRUE;

(* Execute sorting on rising edge of exe *)
IF exe AND NOT exePrev THEN
    (* Copy input array to local working array *)
    seqLocal := seq;
    
    (* Selection sort algorithm *)
    FOR i := 1 TO n-1 DO
        minIndex := i;
        
        FOR j := i+1 TO n DO
            IF seqLocal[j] < seqLocal[minIndex] THEN
                minIndex := j;
            END_IF;
        END_FOR;
        
        (* Swap elements if needed *)
        IF minIndex <> i THEN
            temp := seqLocal[i];
            seqLocal[i] := seqLocal[minIndex];
            seqLocal[minIndex] := temp;
        END_IF;
    END_FOR;
    
    (* Verify the array is sorted in ascending order *)
    sortSuccessful := TRUE;
    FOR i := 1 TO n-1 DO
        IF seqLocal[i] > seqLocal[i+1] THEN
            sortSuccessful := FALSE;
            EXIT;
        END_IF;
    END_FOR;
    
    (* Update outputs based on sorting result *)
    IF sortSuccessful THEN
        (* Copy sorted array back to output *)
        seq := seqLocal;
        error := FALSE;
        status := 16#0000;
    ELSE
        (* Sorting verification failed *)
        error := TRUE;
        status := 16#8A01;
    END_IF;
END_IF;

(* Store previous execution state *)
exePrev := exe;

END_FUNCTION_BLOCK