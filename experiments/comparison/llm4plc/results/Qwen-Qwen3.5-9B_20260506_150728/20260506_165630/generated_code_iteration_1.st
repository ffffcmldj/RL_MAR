START_REASON
The error "发现非预期的记号'END_VAR'" (Unexpected token 'END_VAR') occurs because of a structural violation in the Structured Text (ST) code.

1.  **Duplicate `END_VAR`**: In the `VAR` section, there is an `END_VAR` statement immediately after the variable declarations. However, the `END_VAR` that closes the `VAR` section is missing. Instead, the code jumps straight to the logic statements.
2.  **Incorrect Closing**: The code attempts to close the `VAR` section with `END_VAR`, but then immediately has another `END_VAR` at the very end of the function block. In IEC 61131-3 ST, the `VAR` section must be closed by a single `END_VAR` before any executable statements begin. The final `END_FUNCTION_BLOCK` is correct, but the internal structure is broken.
3.  **Logic Placement**: The executable logic (IF statements) must appear *after* the `END_VAR` that closes the `VAR` section.

To fix this:
- Remove the premature `END_VAR` inside the `VAR` block.
- Ensure the `VAR` block is properly closed with one `END_VAR`.
- Place all logic statements after the closed `VAR` block.
- Ensure the `END_FUNCTION_BLOCK` is present at the very end.
START_ST
FUNCTION_BLOCK SmartHVACSystem
VAR_INPUT
    TemperatureSensor : REAL; (* Temperature sensor reading *)
    HumiditySensor : REAL; (* Humidity sensor reading *)
END_VAR
VAR_OUTPUT
    HVACMode : INT := 0; (* HVAC operating mode: 0=Off, 1=Cooling, 2=Heating, 3=Ventilation *)
    HVACFanSpeed : INT := 0; (* Fan speed: 0=Off, 1=Low, 2=Medium, 3=High *)
END_VAR
VAR
    DesiredTemperature : REAL := 24.0; (* Desired temperature setting *)
    DesiredHumidity : REAL := 50.0; (* Desired humidity setting *)
    TemperatureThreshold : REAL := 1.0; (* Temperature tolerance threshold *)
    HumidityThreshold : REAL := 5.0; (* Humidity tolerance threshold *)
    AdjustedHumidity : REAL; (* Sanitized humidity input *)
    AdjustedTemperature : REAL; (* Sanitized temperature input *)
    NeedsVentilation : BOOL; (* Flag for ventilation requirement *)
    NeedsHeating : BOOL; (* Flag for heating requirement *)
    NeedsCooling : BOOL; (* Flag for cooling requirement *)
END_VAR

    (* Input Sanitization: Humidity *)
    IF HumiditySensor < 0.0 THEN
        AdjustedHumidity := 0.0;
    ELSIF HumiditySensor > 100.0 THEN
        AdjustedHumidity := 100.0;
    ELSE
        AdjustedHumidity := HumiditySensor;
    END_IF;

    (* Input Sanitization: Temperature *)
    IF TemperatureSensor < -50.0 THEN
        AdjustedTemperature := -50.0;
    ELSIF TemperatureSensor > 100.0 THEN
        AdjustedTemperature := 100.0;
    ELSE
        AdjustedTemperature := TemperatureSensor;
    END_IF;

    (* Determine System Requirements *)
    (* Ventilation: Humidity too low *)
    IF AdjustedHumidity < (DesiredHumidity - HumidityThreshold) THEN
        NeedsVentilation := TRUE;
    ELSE
        NeedsVentilation := FALSE;
    END_IF;

    (* Heating: Temperature too low *)
    IF AdjustedTemperature < (DesiredTemperature - TemperatureThreshold) THEN
        NeedsHeating := TRUE;
    ELSE
        NeedsHeating := FALSE;
    END_IF;

    (* Cooling: Temperature too high *)
    IF AdjustedTemperature > (DesiredTemperature + TemperatureThreshold) THEN
        NeedsCooling := TRUE;
    ELSE
        NeedsCooling := FALSE;
    END_IF;

    (* Control Logic: Priority Heating > Cooling > Ventilation *)
    IF NeedsHeating THEN
        HVACMode := 2; (* Heating *)
        HVACFanSpeed := 3; (* High *)
    ELSIF NeedsCooling THEN
        HVACMode := 1; (* Cooling *)
        HVACFanSpeed := 3; (* High *)
    ELSIF NeedsVentilation THEN
        HVACMode := 3; (* Ventilation *)
        HVACFanSpeed := 3; (* High *)
    ELSE
        HVACMode := 0; (* Off *)
        HVACFanSpeed := 0; (* Off *)
    END_IF;

END_FUNCTION_BLOCK
END_ST