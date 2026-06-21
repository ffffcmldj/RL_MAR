START_ST
FUNCTION_BLOCK FB_ValueOut
VAR_INPUT
    valueIn : INT;
    conf : UINT;
END_VAR
VAR_OUTPUT
    ValueOut : INT;
END_VAR
VAR
BEGIN
    CASE conf OF
        1, 2:
            ValueOut := valueIn / 10;
        3:
            CASE valueIn OF
                0:
                    ValueOut := 0;
                300:
                    ValueOut := 163;
                600:
                    ValueOut := 331;
                ELSE:
                    ValueOut := 0;
            END_CASE;
        6, 7:
            CASE valueIn OF
                100:
                    ValueOut := 319;
                ELSE:
                    ValueOut := 0;
            END_CASE;
        4, 5, 8, 9, 10:
            ValueOut := 0;
        ELSE:
            ValueOut := 0;
    END_CASE;
END_VAR
END_FUNCTION_BLOCK
END_ST