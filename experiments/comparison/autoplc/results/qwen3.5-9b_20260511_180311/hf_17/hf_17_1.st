FUNCTION_BLOCK FB_WarehouseManagement
VAR_INPUT
requestIn : Bool := FALSE;
requestOut : Bool := FALSE;
END_VAR
VAR_OUTPUT
productNum : Int := 0;
libFreeNum : Int := 9;
error : Bool := FALSE;
status : Word := 16#0000;
END_VAR
VAR_IN_OUT
library : Array[1..9] of Bool;
END_VAR
VAR
i : INT;
tempPos : INT;
foundIn : BOOL;
foundOut : BOOL;
END_VAR

error := FALSE;
status := 16#0000;

IF requestIn = TRUE THEN
    IF productNum >= 9 THEN
        error := TRUE;
        status := 16#8001;
    ELSE
        foundIn := FALSE;
        tempPos := 9;
        WHILE (tempPos >= 1) AND (foundIn = FALSE) DO
            IF library[tempPos] = FALSE THEN
                library[tempPos] := TRUE;
                productNum := productNum + 1;
                libFreeNum := libFreeNum - 1;
                foundIn := TRUE;
            END_IF;
            tempPos := tempPos - 1;
        END_WHILE;
    END_IF;
END_IF;

IF requestOut = TRUE THEN
    IF productNum <= 0 THEN
        error := TRUE;
        status := 16#8002;
    ELSE
        foundOut := FALSE;
        tempPos := 1;
        WHILE (tempPos <= 9) AND (foundOut = FALSE) DO
            IF library[tempPos] = TRUE THEN
                library[tempPos] := FALSE;
                productNum := productNum - 1;
                libFreeNum := libFreeNum + 1;
                foundOut := TRUE;
            END_IF;
            tempPos := tempPos + 1;
        END_WHILE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK