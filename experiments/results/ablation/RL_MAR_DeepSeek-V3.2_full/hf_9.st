FUNCTION_BLOCK ShellSortFB
    VAR_INPUT
        sortDirection : BOOL;
        arr : ARRAY[1..1000] OF DINT;
    END_VAR

    VAR_OUTPUT
        error : BOOL;
        status : WORD;
        sorted_arr : ARRAY[1..1000] OF DINT;
    END_VAR

    VAR
        gap : DINT;
        i : DINT;
        j : DINT;
        temp : DINT;
        n : DINT;
        continueLoop : BOOL;
    END_VAR

    n := 1000;
    error := FALSE;
    status := 16#0000;
    sorted_arr := arr;

    IF n <= 1 THEN
        error := TRUE;
        status := 16#8200;
        RETURN;
    END_IF;

    IF n > 1000 THEN
        error := TRUE;
        status := 16#8201;
        RETURN;
    END_IF;

    gap := n / 2;
    WHILE gap > 0 DO
        i := gap + 1;
        WHILE i <= n DO
            temp := sorted_arr[i];
            j := i;
            continueLoop := TRUE;
            WHILE (j > gap) AND continueLoop DO
                IF NOT sortDirection THEN
                    IF sorted_arr[j - gap] <= temp THEN
                        continueLoop := FALSE;
                    ELSE
                        sorted_arr[j] := sorted_arr[j - gap];
                        j := j - gap;
                    END_IF;
                ELSE
                    IF sorted_arr[j - gap] >= temp THEN
                        continueLoop := FALSE;
                    ELSE
                        sorted_arr[j] := sorted_arr[j - gap];
                        j := j - gap;
                    END_IF;
                END_IF;
            END_WHILE;
            sorted_arr[j] := temp;
            i := i + 1;
        END_WHILE;
        gap := gap / 2;
    END_WHILE;
END_FUNCTION_BLOCK;