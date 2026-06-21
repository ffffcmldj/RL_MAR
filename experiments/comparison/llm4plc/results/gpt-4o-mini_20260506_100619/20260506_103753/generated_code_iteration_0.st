ructured-text
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
    state : INT := 0; (* State variable *)
    timer : TIME := T#0S; (* Timer variable for dispensing duration *)
    FoodAmount : INT := 50; (* Amount of food to dispense in grams, currently unused *)
END_VAR

(* Function Block Logic *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        FoodDispense := FALSE;
        state := 1; (* Transition to STATE 1 *)

    1: (* STATE 1: CHECK FEEDING TIME *)
        IF (CurrentTime >= FeedTime1 AND CurrentTime < FeedTime1 + T#30S) OR 
           (CurrentTime >= FeedTime2 AND CurrentTime < FeedTime2 + T#30S) OR 
           (CurrentTime >= FeedTime3 AND CurrentTime < FeedTime3 + T#30S) THEN
            state := 2; (* Transition to STATE 2 *)
        END_IF

    2: (* STATE 2: DISPENSE FOOD *)
        FoodDispense := TRUE;
        timer := T#30S; (* Start timer for 30 seconds *)
        state := 3; (* Transition to STATE 3 *)

    3: (* STATE 3: WAIT FOR NEXT FEEDING TIME *)
        IF timer > T#0S THEN
            timer := timer - T#1S; (* Decrement timer by 1 second *)
        ELSE
            FoodDispense := FALSE; (* Set FoodDispense to FALSE after 30 seconds *)
            state := 1; (* Transition back to STATE 1 *)
        END_IF
END_CASE

END_FUNCTION_BLOCK
END_ST