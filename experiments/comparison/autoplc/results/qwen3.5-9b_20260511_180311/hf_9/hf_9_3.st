FUNCTION_BLOCK hf_9
VAR_INPUT
    arr : ARRAY[1..1000] OF DINT;
    sortDirection : BOOL;
END_VAR
VAR_OUTPUT
    error : BOOL;
    status : WORD;
    sorted_arr : ARRAY[1..1000] OF DINT;
END_VAR
VAR
    N : DINT;
    gap : DINT;
    i : DINT;
    j : DINT;
    temp : DINT;
    k : DINT;
    comparisonResult : BOOL;
END_VAR

N := 1000;

IF N <= 1 THEN
    error := TRUE;
    status := 16#8200;
    FOR i := 1 TO N DO
        sorted_arr[i] := arr[i];
    END_FOR;
ELSIF N > 1000 THEN
    error := TRUE;
    status := 16#8201;
    FOR i := 1 TO N DO
        sorted_arr[i] := arr[i];
    END_FOR;
ELSE
    error := FALSE;
    status := 16#0000;
    
    FOR i := 1 TO N DO
        sorted_arr[i] := arr[i];
    END_FOR;

    gap := N DIV 2;
    WHILE gap > 0 DO
        FOR i := gap + 1 TO N DO
            temp := sorted_arr[i];
            j := i;
            
            IF sortDirection = FALSE THEN
                comparisonResult := FALSE;
                WHILE j > gap DO
                    IF sorted_arr[j - gap] > temp THEN
                        comparisonResult := TRUE;
                    ELSE
                        comparisonResult := FALSE;
                    END_IF;
                    
                    IF comparisonResult = TRUE THEN
                        sorted_arr[j] := sorted_arr[j - gap];
                        j := j - gap;
                    ELSE
                        comparisonResult := FALSE;
                    END_IF;
                END_WHILE;
            ELSE
                comparisonResult := FALSE;
                WHILE j > gap DO
                    IF sorted_arr[j - gap] < temp THEN
                        comparisonResult := TRUE;
                    ELSE
                        comparisonResult := FALSE;
                    END_IF;
                    
                    IF comparisonResult = TRUE THEN
                        sorted_arr[j] := sorted_arr[j - gap];
                        j := j - gap;
                    ELSE
                        comparisonResult := FALSE;
                    END_IF;
                END_WHILE;
            END_IF;
            
            sorted_arr[j] := temp;
        END_FOR;
        
        gap := gap DIV 2;
    END_WHILE;
END_IF;
END_FUNCTION_BLOCK