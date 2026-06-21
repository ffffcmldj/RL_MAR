FUNCTION_BLOCK FB_MergeBytes
VAR_INPUT
byteArray : ARRAY[1..20] OF DINT;
END_VAR
VAR_OUTPUT
dwordArray : ARRAY[1..10] OF DINT;
mergeDwordNum : DINT;
END_VAR
VAR
i : INT;
j : INT;
k : INT;
tempDword : DINT;
currentByteValue : DINT;
maxDwords : DINT;
maxBytes : DINT;
byteIndex : INT;
END_VAR
VAR CONSTANT
BYTE_ARRAY_SIZE : DINT := 20;
DWORD_ARRAY_SIZE : DINT := 10;
END_VAR


mergeDwordNum := 0;
maxBytes := BYTE_ARRAY_SIZE;
maxDwords := maxBytes DIV 4;
IF maxDwords > DWORD_ARRAY_SIZE THEN
maxDwords := DWORD_ARRAY_SIZE;
END_IF;

FOR i := 1 TO maxDwords DO
byteIndex := (i - 1) * 4 + 1;
tempDword := 0;
currentByteValue := byteArray[byteIndex];
tempDword := tempDword OR (currentByteValue AND 16#FF) SHL 24;
currentByteValue := byteArray[byteIndex + 1];
tempDword := tempDword OR (currentByteValue AND 16#FF) SHL 16;
currentByteValue := byteArray[byteIndex + 2];
tempDword := tempDword OR (currentByteValue AND 16#FF) SHL 8;
currentByteValue := byteArray[byteIndex + 3];
tempDword := tempDword OR (currentByteValue AND 16#FF);
dwordArray[i] := tempDword;
mergeDwordNum := mergeDwordNum + 1;
END_FOR;
END_FUNCTION_BLOCK