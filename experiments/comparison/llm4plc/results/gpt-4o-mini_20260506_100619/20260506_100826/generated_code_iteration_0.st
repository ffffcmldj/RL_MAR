ructured-text
START_ST
FUNCTION_BLOCK FB_HexDigitAnalyzer
VAR_INPUT
    InputNumber: INT; // Input integer value
END_VAR_INPUT
VAR_OUTPUT
    Thousands: INT; // Thousands place digit
    Hundreds: INT; // Hundreds place digit
    Tens: INT; // Tens place digit
    Ones: INT; // Ones place digit
    Min: INT; // Minimum non-zero digit
    error: BOOL; // Error state indicator
    status: WORD; // Error code
END_VAR_OUTPUT
VAR
    minValue: INT; // Temporary variable for minimum value detection
END_VAR

// State declaration
VAR
    currentState: INT; // Current state of the function block
END_VAR

// State constants
CONST
    STATE_INPUT_VALIDATION: INT := 0;
    STATE_DIGIT_EXTRACTION: INT := 1;
    STATE_MINIMUM_VALUE_DETECTION: INT := 2;
    STATE_ERROR_HANDLING: INT := 3;
END_CONST

// Initialize state
currentState := STATE_INPUT_VALIDATION;

// Main execution loop
WHILE TRUE DO
    CASE currentState OF
        STATE_INPUT_VALIDATION:
            IF InputNumber >= 0 AND InputNumber <= 9999 THEN
                error := FALSE;
                status := 16#0000;
                currentState := STATE_DIGIT_EXTRACTION;
            ELSE
                error := TRUE;
                status := 16#8001;
                Thousands := 0;
                Hundreds := 0;
                Tens := 0;
                Ones := 0;
                Min := 0;
                currentState := STATE_ERROR_HANDLING;
            END_IF;

        STATE_DIGIT_EXTRACTION:
            Thousands := InputNumber / 1000;
            Hundreds := (InputNumber MOD 1000) / 100;
            Tens := (InputNumber MOD 100) / 10;
            Ones := InputNumber MOD 10;
            currentState := STATE_MINIMUM_VALUE_DETECTION;

        STATE_MINIMUM_VALUE_DETECTION:
            minValue := 32767; // Initialize minValue to maximum possible INT value

            // Compare non-zero digits
            IF Thousands > 0 THEN
                minValue := minimal(minValue, Thousands);
            END_IF;
            IF Hundreds > 0 THEN
                minValue := minimal(minValue, Hundreds);
            END_IF;
            IF Tens > 0 THEN
                minValue := minimal(minValue, Tens);
            END_IF;
            IF Ones > 0 THEN
                minValue := minimal(minValue, Ones);
            END_IF;

            // Set Min based on found minimum value
            IF minValue = 32767 THEN
                Min := 0; // All digits are zero
            ELSE
                Min := minValue; // Set Min to the found minimum value
            END_IF;

            // Remain in this state as final state
            currentState := STATE_MINIMUM_VALUE_DETECTION;

        STATE_ERROR_HANDLING:
            // Remain in error handling state until reset
            // Outputs are already set to zero in this state
            // No further action needed
    END_CASE;
END_WHILE;

END_FUNCTION_BLOCK
END_ST