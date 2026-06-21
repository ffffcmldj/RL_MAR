(* ===================================================================== *)
(* FUNCTION_BLOCK: AutomaticDoorControl                                  *)
(* Description: Controls an automatic door for a retail environment.     *)
(*              The door opens on a rising edge of the proximity sensor  *)
(*              and remains open while the sensor is active or until a   *)
(*              fixed timer expires after the sensor becomes inactive.   *)
(* ===================================================================== *)
FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL; (* TRUE when an object is detected near the door *)
    ElapsedTime : DINT;     (* Time in milliseconds since the door was last opened *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;        (* TRUE to command the door open, FALSE to close *)
END_VAR

VAR
    (* Configuration Constant *)
    DoorOpenDuration : DINT := 5000; (* Time door stays open after sensor goes inactive [ms] *)

    (* Internal State Variables *)
    eCurrentState : (STATE_CLOSED, STATE_OPENING, STATE_OPEN, STATE_CLOSING) := STATE_CLOSED;
    tonOpenTimer : TON; (* Timer to manage the hold-open duration *)
    rTrigSensor : R_TRIG; (* Edge detector for the proximity sensor *)
END_VAR

(* --------------------------------------------------------------------- *)
(* Main State Machine Logic                                              *)
(* --------------------------------------------------------------------- *)
(* Detect rising edge of the sensor for clean activation *)
rTrigSensor(CLK := ProximitySensor);

CASE eCurrentState OF
    STATE_CLOSED:
        DoorOpen := FALSE;
        tonOpenTimer(IN := FALSE, PT := DINT_TO_TIME(DoorOpenDuration));

        (* Transition to OPENING on a rising edge of the sensor *)
        IF rTrigSensor.Q THEN
            eCurrentState := STATE_OPENING;
        END_IF;

    STATE_OPENING:
        (* Command the door to open and start the hold-open timer *)
        DoorOpen := TRUE;
        tonOpenTimer(IN := TRUE, PT := DINT_TO_TIME(DoorOpenDuration));
        eCurrentState := STATE_OPEN;

    STATE_OPEN:
        DoorOpen := TRUE;

        (* Check exit conditions from the OPEN state *)
        IF NOT ProximitySensor AND tonOpenTimer.Q THEN
            (* Sensor is inactive AND the hold timer has expired *)
            eCurrentState := STATE_CLOSING;
        ELSIF ProximitySensor THEN
            (* Sensor is still active: reset and restart the hold timer *)
            tonOpenTimer(IN := FALSE);
            tonOpenTimer(IN := TRUE, PT := DINT_TO_TIME(DoorOpenDuration));
        END_IF;
        (* If sensor is inactive but timer is still running, remain in STATE_OPEN *)

    STATE_CLOSING:
        (* Command the door to close and reset internal logic *)
        DoorOpen := FALSE;
        tonOpenTimer(IN := FALSE);
        eCurrentState := STATE_CLOSED;

END_CASE;

END_FUNCTION_BLOCK