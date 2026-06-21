START_ST
FUNCTION_BLOCK PetFeederControl
VAR_INPUT
    CurrentTime : TIME;
END_VAR
VAR_OUTPUT
    FoodDispense : BOOL;
END_VAR
VAR
    state : INT := 0;
    FeedTime1 : TIME := T#8H0M0S;
    FeedTime2 : TIME := T#12H0M0S;
    FeedTime3 : TIME := T#18H0M0S;
    FoodAmount : INT := 50;
END_VAR

CASE state OF
    0: (* IDLE_WAITING *)
        FoodDispense := FALSE;
        IF (CurrentTime >= FeedTime1) AND (CurrentTime < (FeedTime1 + T#30S)) THEN
            state := 1;
        ELSIF (CurrentTime >= FeedTime2) AND (CurrentTime < (FeedTime2 + T#30S)) THEN
            state := 1;
        ELSIF (CurrentTime >= FeedTime3) AND (CurrentTime < (FeedTime3 + T#30S)) THEN
            state := 1;
        END_IF;
        
    1: (* DISPENSING_ACTIVE *)
        FoodDispense := TRUE;
        IF NOT( ((CurrentTime >= FeedTime1) AND (CurrentTime < (FeedTime1 + T#30S))) OR
                ((CurrentTime >= FeedTime2) AND (CurrentTime < (FeedTime2 + T#30S))) OR
                ((CurrentTime >= FeedTime3) AND (CurrentTime < (FeedTime3 + T#30S))) ) THEN
            state := 0;
        END_IF;
        
    ELSE
        state := 0;
        FoodDispense := FALSE;
END_CASE;

END_FUNCTION_BLOCK
END_ST