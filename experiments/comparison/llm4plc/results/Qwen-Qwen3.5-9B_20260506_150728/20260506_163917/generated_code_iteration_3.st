START_REASON
The previous code failed CODESYS validation with the error: `应该用';' 替换'IF'` (Should replace 'IF' with ';').

This error message is slightly misleading in standard IEC 61131-3, where `IF` is a keyword and cannot be replaced by a semicolon. However, in the context of strict CODESYS parsing or specific toolchain configurations (especially when combined with previous encoding issues), this often indicates one of two things:
1.  **Missing Semicolons after Statements**: The toolchain expects every executable statement (assignments, function calls) to end with a semicolon (`;`). While `IF`, `ELSIF`, `ELSE`, and `END_IF` blocks themselves do not take a semicolon at the end of the line, the *statements inside* them must. In the previous code, the assignments like `Humidifier := TRUE;` were present, but the parser might be confused if the block structure isn't perfectly aligned with strict line-by-line tokenization.
2.  **Keyword Confusion due to Encoding/Formatting**: The previous encoding error (`gbk` codec) suggests hidden characters might have corrupted the `IF` keyword, making the parser think it's a variable name or a typo that needs fixing. The error "replace 'IF' with ';'" is a common hallucination or specific error message from certain Chinese-localized compilers or wrappers when they fail to parse a block structure correctly, often implying the block header is malformed.

To fix this definitively:
1.  Ensure **strict ASCII** encoding (no hidden Chinese characters).
2.  Verify that every single assignment statement inside the `IF` blocks ends with a semicolon (`;`).
3.  Ensure the `END_IF` keywords are on their own lines and properly closed.
4.  Remove any comments that might contain non-ASCII characters or complex formatting that triggers the parser.
5.  Double-check that `END_FUNCTION_BLOCK` is present and correctly terminated.

The logic remains:
- Humidity < 50 -> Humidifier ON, Dehumidifier OFF.
- Humidity > 50 -> Humidifier OFF, Dehumidifier ON.
- Humidity = 50 -> Both OFF.
- Light Sensor TRUE -> LightControl ON.
- HVAC System ON if either Humidifier or Dehumidifier is ON.

I will generate the code with clean, standard ASCII ST syntax, ensuring every assignment has a semicolon and the block structure is robust.
END_REASON

START_ST
FUNCTION_BLOCK MuseumClimateControl
VAR_INPUT
    HumiditySensor : REAL;
    TemperatureSensor : REAL;
    LightSensor : BOOL;
END_VAR;

VAR_OUTPUT
    HVACSystem : BOOL;
    Humidifier : BOOL;
    Dehumidifier : BOOL;
    LightControl : BOOL;
END_VAR;

VAR
    TargetHumidity : REAL := 50.0;
    TargetTemperature : REAL := 20.0;
    LightThreshold : BOOL := TRUE;
END_VAR;

BEGIN
    IF HumiditySensor < TargetHumidity THEN
        Humidifier := TRUE;
        Dehumidifier := FALSE;
    ELSIF HumiditySensor > TargetHumidity THEN
        Humidifier := FALSE;
        Dehumidifier := TRUE;
    ELSE
        Humidifier := FALSE;
        Dehumidifier := FALSE;
    END_IF;

    IF LightSensor = TRUE THEN
        LightControl := TRUE;
    ELSE
        LightControl := FALSE;
    END_IF;

    HVACSystem := Humidifier OR Dehumidifier;
END_FUNCTION_BLOCK;
END_ST