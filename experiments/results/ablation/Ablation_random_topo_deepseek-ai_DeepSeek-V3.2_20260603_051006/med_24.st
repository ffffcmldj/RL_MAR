FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT; (* Time since door was last opened in milliseconds *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL;
END_VAR

VAR
    DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
    eState : (eDoorClosed, eDoorOpening, eDoorOpen, eDoorClosing) := eDoorClosed;
    rTrigSensor : R_TRIG;
    fTrigSensor : F_TRIG;
    tDoorTimer : TON;
    bTimerStarted : BOOL := FALSE;
    bProxPrev : BOOL := FALSE;
END_VAR

(* Detect rising and falling edges of proximity sensor *)
rTrigSensor(CLK := ProximitySensor);
fTrigSensor(CLK := ProximitySensor);

CASE eState OF
    eDoorClosed:
        DoorOpen := FALSE;
        bTimerStarted := FALSE;
        tDoorTimer(IN := FALSE);
        
        (* Open door when proximity sensor detects object *)
        IF rTrigSensor.Q THEN
            eState := eDoorOpening;
        END_IF;

    eDoorOpening:
        DoorOpen := TRUE;
        (* Start timer for door open duration *)
        tDoorTimer(IN := TRUE, PT := DINT_TO_TIME(DoorOpenDuration));
        bTimerStarted := TRUE;
        eState := eDoorOpen;

    eDoorOpen:
        DoorOpen := TRUE;
        
        (* Keep timer running while door is open *)
        IF bTimerStarted THEN
            tDoorTimer(IN := TRUE);
        END_IF;
        
        (* Close door if proximity sensor becomes inactive OR timer expires *)
        IF fTrigSensor.Q OR tDoorTimer.Q THEN
            eState := eDoorClosing;
            tDoorTimer(IN := FALSE);
            bTimerStarted := FALSE;
        END_IF;

    eDoorClosing:
        DoorOpen := FALSE;
        tDoorTimer(IN := FALSE);
        bTimerStarted := FALSE;
        
        (* Wait for elapsed time before allowing next open cycle *)
        (* This prevents rapid open/close cycles *)
        IF ElapsedTime >= 1000 THEN (* 1 second cooldown *)
            eState := eDoorClosed;
        END_IF;
END_CASE;

(* Store previous proximity sensor state for edge detection *)
bProxPrev := ProximitySensor;
END_FUNCTION_BLOCK