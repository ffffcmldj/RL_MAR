FUNCTION_BLOCK PetFeederControl
VAR_INPUT
    CurrentTime : TIME;
END_VAR
VAR_OUTPUT
    FoodDispense : BOOL;
END_VAR
VAR
    FeedTime1 : TIME := T#8H0M0S;
    FeedTime2 : TIME := T#12H0M0S;
    FeedTime3 : TIME := T#18H0M0S;
    FoodAmount : INT := 50;
    DispenseWindow1 : BOOL;
    DispenseWindow2 : BOOL;
    DispenseWindow3 : BOOL;
END_VAR

DispenseWindow1 := (CurrentTime >= FeedTime1) AND (CurrentTime < (FeedTime1 + T#30S));
DispenseWindow2 := (CurrentTime >= FeedTime2) AND (CurrentTime < (FeedTime2 + T#30S));
DispenseWindow3 := (CurrentTime >= FeedTime3) AND (CurrentTime < (FeedTime3 + T#30S));

IF DispenseWindow1 OR DispenseWindow2 OR DispenseWindow3 THEN
    FoodDispense := TRUE;
ELSE
    FoodDispense := FALSE;
END_IF;

END_FUNCTION_BLOCK