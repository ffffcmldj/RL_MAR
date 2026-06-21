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
    FoodAmount : INT := 50; (* Amount of food to dispense in grams - currently unused *)
END_VAR

(* Main dispensing logic *)
FoodDispense := FALSE;

IF (CurrentTime >= FeedTime1) AND (CurrentTime < (FeedTime1 + T#30S)) THEN
    FoodDispense := TRUE;
ELSIF (CurrentTime >= FeedTime2) AND (CurrentTime < (FeedTime2 + T#30S)) THEN
    FoodDispense := TRUE;
ELSIF (CurrentTime >= FeedTime3) AND (CurrentTime < (FeedTime3 + T#30S)) THEN
    FoodDispense := TRUE;
END_IF;

END_FUNCTION_BLOCK