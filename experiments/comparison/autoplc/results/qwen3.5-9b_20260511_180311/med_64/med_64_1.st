FUNCTION_BLOCK BakeryOvenControl
VAR_INPUT
    TemperatureSensor : REAL;
    HumiditySensor : REAL;
END_VAR
VAR_OUTPUT
    HeatingElement : BOOL;
    CoolingElement : BOOL;
    HumidityControl : BOOL;
    DehumidityControl : BOOL;
END_VAR
VAR
    OvenTemperature : REAL := 0.0;
    OvenHumidity : REAL := 0.0;
    BakingTime : TIME := T#0s;
    OvenStatus : BOOL := FALSE;
    HeatingThreshold : REAL := 2.0;
    HumidityThreshold : REAL := 5.0;
    LowerTempLimit : REAL;
    UpperTempLimit : REAL;
    LowerHumidityLimit : REAL;
    UpperHumidityLimit : REAL;
    TimeDecrement : TIME;
    CycleCount : DINT := 0;
END_VAR

IF OvenStatus = FALSE THEN
    OvenTemperature := 0.0;
    OvenHumidity := 0.0;
    BakingTime := T#0s;
    HeatingElement := FALSE;
    CoolingElement := FALSE;
    HumidityControl := FALSE;
    DehumidityControl := FALSE;
ELSE
    IF BakingTime > T#0s THEN
        CycleCount := CycleCount + 1;
        IF CycleCount >= 10 THEN
            TimeDecrement := T#1s;
            CycleCount := 0;
        ELSE
            TimeDecrement := T#100ms;
        END_IF;
        
        BakingTime := BakingTime - TimeDecrement;
        
        IF BakingTime <= T#0s THEN
            HeatingElement := FALSE;
            CoolingElement := FALSE;
            HumidityControl := FALSE;
            DehumidityControl := FALSE;
            BakingTime := T#0s;
        ELSE
            LowerTempLimit := OvenTemperature - HeatingThreshold;
            UpperTempLimit := OvenTemperature + HeatingThreshold;
            
            LowerHumidityLimit := OvenHumidity - HumidityThreshold;
            UpperHumidityLimit := OvenHumidity + HumidityThreshold;
            
            IF TemperatureSensor < LowerTempLimit THEN
                HeatingElement := TRUE;
                CoolingElement := FALSE;
            ELSIF TemperatureSensor > UpperTempLimit THEN
                HeatingElement := FALSE;
                CoolingElement := TRUE;
            ELSE
                HeatingElement := FALSE;
                CoolingElement := FALSE;
            END_IF;
            
            IF HumiditySensor < LowerHumidityLimit THEN
                HumidityControl := TRUE;
                DehumidityControl := FALSE;
            ELSIF HumiditySensor > UpperHumidityLimit THEN
                HumidityControl := FALSE;
                DehumidityControl := TRUE;
            ELSE
                HumidityControl := FALSE;
                DehumidityControl := FALSE;
            END_IF;
        END_IF;
    ELSE
        HeatingElement := FALSE;
        CoolingElement := FALSE;
        HumidityControl := FALSE;
        DehumidityControl := FALSE;
    END_IF;
END_IF;

END_FUNCTION_BLOCK