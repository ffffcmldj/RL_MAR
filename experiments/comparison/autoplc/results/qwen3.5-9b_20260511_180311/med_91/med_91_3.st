FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT;
END_VAR
VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE;
    AGV2_Ready : BOOL := TRUE;
    AGV3_Ready : BOOL := TRUE;
END_VAR
VAR
    MaterialQueue : ARRAY[1..10] OF INT;
    AGVPosition : ARRAY[1..3] OF INT;
    QueueHead : INT := 1;
    QueueTail : INT := 1;
    QueueCount : INT := 0;
    i : INT;
    j : INT;
    k : INT; // Explicitly declare loop variable k
    TaskAssigned : BOOL;
    CurrentTask : INT;
    AGVIndex : INT;
    IsReady : BOOL;
    IsBusy : BOOL;
    ValidRequest : BOOL;
    MinPos : INT;
END_VAR


    ValidRequest := TRUE;
    If MaterialRequest < 0 Then
        ValidRequest := FALSE;
    END_IF;

    If ValidRequest = TRUE Then
        If QueueCount < 10 Then
            MaterialQueue[QueueTail] := MaterialRequest;
            QueueTail := QueueTail + 1;
            If QueueTail > 10 Then
                QueueTail := 1;
            END_IF;
            QueueCount := QueueCount + 1;
        END_IF;
    END_IF;

    TaskAssigned := FALSE;
    CurrentTask := 0;

    For i := 1 To QueueCount Do
        CurrentTask := MaterialQueue[i];
        IsBusy := FALSE;
        For j := 1 To 3 Do
            If AGVPosition[j] = CurrentTask Then
                IsBusy := TRUE;
                EXIT; // Changed Break to EXIT
            END_IF;
        END_FOR;
        If IsBusy = FALSE Then
            EXIT; // Changed Break to EXIT
        END_IF;
    END_FOR;

    If TaskAssigned = FALSE Then
        For i := 1 To 3 Do
            AGVIndex := i;
            IsReady := TRUE;
            If AGVPosition[AGVIndex] <> 0 Then
                IsReady := FALSE;
            END_IF;
            If IsReady = TRUE Then
                If QueueCount > 0 Then
                    For j := 1 To QueueCount Do
                        CurrentTask := MaterialQueue[j];
                        IsBusy := FALSE;
                        For k := 1 To 3 Do
                            If AGVPosition[k] = CurrentTask Then
                                IsBusy := TRUE;
                                EXIT; // Changed Break to EXIT
                            END_IF;
                        END_FOR;
                        If IsBusy = FALSE Then
                            AGVPosition[AGVIndex] := CurrentTask;
                            If AGVIndex = 1 Then
                                AGV1_Ready := FALSE;
                            ELSIF AGVIndex = 2 Then
                                AGV2_Ready := FALSE;
                            ELSE
                                AGV3_Ready := FALSE;
                            END_IF;
                            TaskAssigned := TRUE;
                            EXIT; // Changed Break to EXIT
                        END_IF;
                    END_FOR;
                END_IF;
            END_IF;
            If TaskAssigned = TRUE Then
                EXIT;
            END_IF;
        END_FOR;
    END_IF;

    For i := 1 To 3 Do
        MinPos := 0;
        If AGVPosition[i] < MinPos Then
            MinPos := AGVPosition[i];
        END_IF;
        If MinPos < 0 Then
            AGVPosition[i] := 0;
        END_IF;
    END_FOR;

    For i := 1 To 3 Do
        If AGVPosition[i] = 0 Then
            If i = 1 Then
                AGV1_Ready := TRUE;
            ELSIF i = 2 Then
                AGV2_Ready := TRUE;
            ELSE
                AGV3_Ready := TRUE;
            END_IF;
        END_IF;
    END_FOR;

END_FUNCTION_BLOCK