START_ST
FUNCTION_BLOCK PetFeederControl
VAR_INPUT
    CurrentTime : TIME; (* Current system time input *)
END_VAR
VAR_OUTPUT
    FoodDispense : BOOL; (* Food dispenser control signal *)
END_VAR
VAR
    FeedTime1 : TIME := T#8H0M0S; (* First feeding time - 8:00 AM *)
    FeedTime2 : TIME := T#12H0M0S; (* Second feeding time - 12:00 PM *)
    FeedTime3 : TIME := T#18H0M0S; (* Third feeding time - 6:00 PM *)
    FoodAmount : INT := 50; (* Amount of food to dispense in grams - Currently Unused *)
    state : BOOL; (* Represents the FSM state: TRUE = Dispensing, FALSE = Idle *)
END_VAR

(* STATE 0: IDLE (Default State) *)
(* Description: The system is waiting for the current time to match a scheduled feeding time. No food is being dispensed. *)
(* Output for State 0: FoodDispense = FALSE *)

(* STATE 1: DISPENSING (Active State) *)
(* Description: The system has detected that the current time falls within a scheduled feeding window. The food dispenser is active. *)
(* Output for State 1: FoodDispense = TRUE *)

(* TRANSITIONS *)
(* STATE 0 -> STATE 1: IF (CurrentTime >= FeedTime1 AND CurrentTime < FeedTime1 + T#30S) OR 
                       (CurrentTime >= FeedTime2 AND CurrentTime < FeedTime2 + T#30S) OR 
                       (CurrentTime >= FeedTime3 AND CurrentTime < FeedTime3 + T#30S) *)
(* STATE 1 -> STATE 0: Always (Implicitly handled by the logic in State 0 checking the condition again every cycle) *)

(* FSM Logic Implementation *)
(* Transition to State 1 if any feeding condition is met *)
IF (CurrentTime >= FeedTime1 AND CurrentTime < FeedTime1 + T#30S) OR
   (CurrentTime >= FeedTime2 AND CurrentTime < FeedTime2 + T#30S) OR
   (CurrentTime >= FeedTime3 AND CurrentTime < FeedTime3 + T#30S)
THEN
    state := TRUE; (* Transition to STATE 1 *)
END_IF;

(* Transition to State 0 if no feeding condition is met *)
IF NOT ((CurrentTime >= FeedTime1 AND CurrentTime < FeedTime1 + T#30S) OR
        (CurrentTime >= FeedTime2 AND CurrentTime < FeedTime2 + T#30S) OR
        (CurrentTime >= FeedTime3 AND CurrentTime < FeedTime3 + T#30S))
THEN
    state := FALSE; (* Transition to STATE 0 *)
END_IF;

(* Assign Output based on Current State *)
(* STATE 0: FoodDispense = FALSE *)
(* STATE 1: FoodDispense = TRUE *)
FoodDispense := state;

END_FUNCTION_BLOCK
END_ST