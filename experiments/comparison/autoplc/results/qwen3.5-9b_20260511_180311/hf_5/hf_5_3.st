FUNCTION_BLOCK SelectSort
VAR_INPUT
exe : BOOL;
seq : ARRAY[0..100] OF REAL;  // Replaced VARIANT with a standard ARRAY type. Adjust size as needed.
END_VAR
VAR_OUTPUT
error : BOOL;
status : WORD;
END_VAR
VAR
i : INT;
j : INT;
minIndex : INT;
n : INT;
temp : ARRAY[0..100] OF REAL; // Replaced VARIANT with matching ARRAY type for swapping.
isError : BOOL;
isSorted : BOOL;
valI : REAL;                 // Changed from LREAL to REAL to match the array element type.
valJ : REAL;
valMin : REAL;
END_VAR

error := FALSE;
status := 16#0000;

IF NOT exe THEN
    RETURN;
END_IF;

// Removed type check for TYP as it is not applicable to standard ARRAY types in ST.
// n := seq.ARRAY_SIZE; // ARRAY_SIZE is a property of ARRAY types, but explicit sizing is often clearer.
n := HIGH(seq) + 1; // Calculate size based on the defined array bounds.

IF n <= 1 THEN
    error := FALSE;
    status := 16#0000;
    RETURN;
END_IF;

isError := FALSE;
isSorted := FALSE;

FOR i := 0 TO n - 2 DO
    minIndex := i;
    FOR j := i + 1 TO n - 1 DO
        // Simplified logic: removed redundant IF/ELSE block
        valI := seq[i];
        valJ := seq[j];

        IF valJ < valI THEN
            valMin := valI;
            valI := valJ;
            valJ := valMin;
            minIndex := j;
        END_IF;
    END_FOR;

    IF minIndex <> i THEN
        temp := seq[i];
        seq[i] := seq[minIndex];
        seq[minIndex] := temp;
    END_IF;
END_FOR;

error := FALSE;
status := 16#0000;
END_FUNCTION_BLOCK