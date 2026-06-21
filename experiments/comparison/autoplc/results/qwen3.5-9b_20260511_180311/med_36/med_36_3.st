TYPE POINT
    X : INT;
    Y : INT;
END_TYPE

FUNCTION_BLOCK FB_ExpandedPoint
    VAR_INPUT
        INPUT_VAR2 : INT;
        INPUT_VAR1_X : INT;
        INPUT_VAR1_Y : INT;
        INPUT_VAR3_X : INT := 1;
        INPUT_VAR3_Y : INT := 2;
    END_VAR

    VAR_OUTPUT
        OUTPUT_VAR2 : INT;
        OUTPUT_VAR1_X : INT;
        OUTPUT_VAR1_Y : INT;
        OUTPUT_VAR3_X : INT;
        OUTPUT_VAR3_Y : INT;
    END_VAR

    VAR
        VAR2 : INT;
        TempPoint1 : POINT;
        TempPoint3 : POINT;
    END_VAR

    VAR2 := INPUT_VAR2;

    TempPoint1.X := 1;
    TempPoint1.Y := 2;

    OUTPUT_VAR1_X := TempPoint1.X;
    OUTPUT_VAR1_Y := TempPoint1.Y;

    TempPoint3.X := 100;
    TempPoint3.Y := -7000;

    OUTPUT_VAR3_X := TempPoint3.X;
    OUTPUT_VAR3_Y := TempPoint3.Y;
END_FUNCTION_BLOCK