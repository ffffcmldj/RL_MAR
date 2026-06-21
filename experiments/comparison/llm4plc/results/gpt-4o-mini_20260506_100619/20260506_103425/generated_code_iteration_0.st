ructured-text
FUNCTION_BLOCK TrafficManagementSystem
VAR_INPUT
    VehicleCount1 : INT; (* Input for vehicle count at intersection 1 *)
    VehicleCount2 : INT; (* Input for vehicle count at intersection 2 *)
    VehicleCount3 : INT; (* Input for vehicle count at intersection 3 *)
    VehicleCount4 : INT; (* Input for vehicle count at intersection 4 *)
END_VAR
VAR_OUTPUT
    TrafficLight1 : BOOL; (* Output for traffic light at intersection 1 *)
    TrafficLight2 : BOOL; (* Output for traffic light at intersection 2 *)
    TrafficLight3 : BOOL; (* Output for traffic light at intersection 3 *)
    TrafficLight4 : BOOL; (* Output for traffic light at intersection 4 *)
END_VAR
VAR
    state : INT; (* The state variable *)
    prevState : INT; (* The previous state variable *)
END_VAR

(* Initialize state *)
state := 0;
prevState := 0;

(* State machine logic *)
CASE state OF
    0: (* STATE 0: INITIALIZE *)
        TrafficLight1 := FALSE;
        TrafficLight2 := FALSE;
        TrafficLight3 := FALSE;
        TrafficLight4 := FALSE;
        state := 1; (* Transition to STATE 1 *)

    1: (* STATE 1: CONTROL TRAFFIC LIGHTS FOR INTERSECTION PAIR 1 *)
        IF VehicleCount1 > VehicleCount2 THEN
            TrafficLight1 := TRUE;
            TrafficLight2 := FALSE;
        ELSE
            TrafficLight1 := FALSE;
            TrafficLight2 := TRUE;
        END_IF;
        state := 2; (* Transition to STATE 2 *)

    2: (* STATE 2: CONTROL TRAFFIC LIGHTS FOR INTERSECTION PAIR 2 *)
        IF VehicleCount3 > VehicleCount4 THEN
            TrafficLight3 := TRUE;
            TrafficLight4 := FALSE;
        ELSE
            TrafficLight3 := FALSE;
            TrafficLight4 := TRUE;
        END_IF;
        state := 1; (* Transition back to STATE 1 *)
END_CASE;

END_FUNCTION_BLOCK