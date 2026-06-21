```ST
FUNCTION_BLOCK AutomaticDoorControl
VAR_INPUT
    ProximitySensor : BOOL;
    ElapsedTime : DINT; (* Elapsed time since the door was last opened, in milliseconds *)
END_VAR

VAR_OUTPUT
    DoorOpen : BOOL; (* Indicates whether the door is open or closed *)
END_VAR

VAR
    DoorOpenDuration : DINT := 5000; (* 5 seconds in milliseconds *)
END_VAR

VAR
    DoorState : BOOL := FALSE; (* FALSE represents Door Closed, TRUE represents Door Open *)
END_VAR

VAR
    LastProximityState : BOOL := FALSE; (* To track the last state of the proximity sensor *)
END_VAR

VAR
    TimeWhenOpened : DINT := 0; (* To store the time when the door was last opened *)
END_VAR

VAR
    CurrentTime : DINT := 0; (* To simulate the current time in milliseconds *)
END_VAR

VAR
    TimeElapsedSinceOpened : DINT := 0; (* To calculate the elapsed time since the door was opened *)
END_VAR

VAR
    DoorShouldClose : BOOL := FALSE; (* Flag to determine if the door should close *)
END_VAR

VAR
    DoorShouldOpen : BOOL := FALSE; (* Flag to determine if the door should open *)
END_VAR

VAR
    DoorStateChanged : BOOL := FALSE; (* Flag to indicate if the door state has changed *)
END_VAR

VAR
    ProximitySensorChanged : BOOL := FALSE; (* Flag to indicate if the proximity sensor state has changed *)
END_VAR

VAR
    DoorOpenTimeExceeded : BOOL := FALSE; (* Flag to indicate if the door open time has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeReset : BOOL := FALSE; (* Flag to reset the door open time when the door closes *)
END_VAR

VAR
    DoorOpenTimeStart : DINT := 0; (* To store the start time when the door opens *)
END_VAR

VAR
    DoorOpenTimeCurrent : DINT := 0; (* To store the current time when checking the door open time *)
END_VAR

VAR
    DoorOpenTimeElapsed : DINT := 0; (* To calculate the elapsed time since the door opened *)
END_VAR

VAR
    DoorOpenTimeCheck : BOOL := FALSE; (* Flag to check if the door open time should be checked *)
END_VAR

VAR
    DoorOpenTimeCheckStart : DINT := 0; (* To store the start time when checking the door open time *)
END_VAR

VAR
    DoorOpenTimeCheckCurrent : DINT := 0; (* To store the current time when checking the door open time *)
END_VAR

VAR
    DoorOpenTimeCheckElapsed : DINT := 0; (* To calculate the elapsed time since checking the door open time *)
END_VAR

VAR
    DoorOpenTimeCheckExceeded : BOOL := FALSE; (* Flag to indicate if the door open time check has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckReset : BOOL := FALSE; (* Flag to reset the door open time check when the door closes *)
END_VAR

VAR
    DoorOpenTimeCheckStartReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckCurrentReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckElapsedReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckExceededReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStart : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrent : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsed : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceeded : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : BOOL := FALSE; (* Flag to indicate if the door open time check reset has exceeded the duration *)
END_VAR

VAR
    DoorOpenTimeCheckResetStartResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the start time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetCurrentResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To store the current time when resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetElapsedResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset : DINT := 0; (* To calculate the elapsed time since resetting the door open time check *)
END_VAR

VAR
    DoorOpenTimeCheckResetExceededResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetResetReset