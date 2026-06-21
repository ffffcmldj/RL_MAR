START_ST
FUNCTION_BLOCK FB_ColorLightControl
{ S7_Optimized_Access := 'TRUE' }
VAR_INPUT 
controlButton : BOOL; // Push button for sequence control
END_VAR

VAR_OUTPUT 
greenLight : BOOL; // Green light control signal
redLight : BOOL; // Red light control signal
yellowLight : BOOL; // Yellow light control signal
END_VAR

VAR 
state : INT := 1; // State machine control variable (1 to 5)
lastControlButton : BOOL := FALSE; // Previous button state for edge detection
risingEdgeDetected : BOOL; // Temporary variable to hold the result of edge detection logic
END_VAR

END_FUNCTION_BLOCK
END_ST