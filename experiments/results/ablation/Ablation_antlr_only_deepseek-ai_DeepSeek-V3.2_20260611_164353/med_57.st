(*
FUNCTION_BLOCK: FB_CourseDifferenceControl
DESCRIPTION: Computes the normalized angular difference between two compass headings.
             Inputs are interpreted as angles in tenths of a degree (3600 = 360.0°).
             Returns the smallest angular difference in the range [-1800, 1800].
             If KOMPASS_GRAD < 0, output is forced to 0 (invalid compass reading).
*)

FUNCTION_BLOCK FB_CourseDifferenceControl
VAR_INPUT
    KOMPASS_GRAD : INT;  (* Current compass heading [0.1°] *)
    KURS : INT;          (* Desired course [0.1°] *)
END_VAR

VAR_OUTPUT
    KURS_DIFF : INT;     (* Normalized angular difference [0.1°] *)
END_VAR

VAR
    tempDiff : INT;      (* Temporary difference for calculation *)
END_VAR

(* Main execution logic *)
IF KOMPASS_GRAD < 0 THEN
    (* Invalid compass reading: set output to safe default *)
    KURS_DIFF := 0;
ELSE
    (* Calculate initial difference *)
    tempDiff := KURS - KOMPASS_GRAD;
    
    (* Apply circular range correction to get smallest angular difference *)
    IF tempDiff > 1800 THEN
        KURS_DIFF := tempDiff - 3600;
    ELSIF tempDiff < -1800 THEN
        KURS_DIFF := tempDiff + 3600;
    ELSE
        KURS_DIFF := tempDiff;
    END_IF;
END_IF;

END_FUNCTION_BLOCK