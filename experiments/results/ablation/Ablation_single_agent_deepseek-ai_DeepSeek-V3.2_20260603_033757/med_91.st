FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT; (* 新的物料请求，>0表示有效请求 *)
    TaskComplete_AGV1 : BOOL := FALSE; (* AGV1任务完成信号 *)
    TaskComplete_AGV2 : BOOL := FALSE; (* AGV2任务完成信号 *)
    TaskComplete_AGV3 : BOOL := FALSE; (* AGV3任务完成信号 *)
    AGV1_PositionUpdate : INT := 0; (* AGV1位置更新值 *)
    AGV2_PositionUpdate : INT := 0; (* AGV2位置更新值 *)
    AGV3_PositionUpdate : INT := 0; (* AGV3位置更新值 *)
END_VAR

VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE; (* AGV1就绪状态 *)
    AGV2_Ready : BOOL := TRUE; (* AGV2就绪状态 *)
    AGV3_Ready : BOOL := TRUE; (* AGV3就绪状态 *)
    AGV1_CurrentTask : INT := 0; (* AGV1当前任务，0表示空闲 *)
    AGV2_CurrentTask : INT := 0; (* AGV2当前任务，0表示空闲 *)
    AGV3_CurrentTask : INT := 0; (* AGV3当前任务，0表示空闲 *)
    AGV1_Position : INT := 0; (* AGV1当前位置 *)
    AGV2_Position : INT := 0; (* AGV2当前位置 *)
    AGV3_Position : INT := 0; (* AGV3当前位置 *)
    QueueCount : INT := 0; (* 队列中任务数量 *)
    SafetyError : BOOL := FALSE; (* 安全错误标志 *)
    QueueOverflow : BOOL := FALSE; (* 队列溢出标志 *)
    InvalidRequest : BOOL := FALSE; (* 无效请求标志 *)
END_VAR

VAR
    (* 物料处理请求队列 - FIFO实现 *)
    MaterialQueue : ARRAY[1..10] OF INT;
    QueueHead : INT := 1; (* 队列头部指针 *)
    QueueTail : INT := 1; (* 队列尾部指针 *)
    
    (* AGV状态管理 *)
    AGVStatus : ARRAY[1..3] OF BOOL := [TRUE, TRUE, TRUE]; (* TRUE=就绪，FALSE=工作中 *)
    AGVTask : ARRAY[1..3] OF INT := [0, 0, 0]; (* AGV当前任务 *)
    
    (* 临时变量 *)
    TempTask : INT;
    i : INT;
    
    (* 状态监控 *)
    PreviousQueueCount : INT := 0;
    SystemIdle : BOOL := TRUE;
END_VAR

(* 1. 处理新的物料请求 *)
InvalidRequest := FALSE;
IF MaterialRequest > 0 THEN
    (* 检查请求有效性 *)
    IF MaterialRequest <= 100 THEN  (* 假设有效任务ID范围1-100 *)
        IF QueueCount < 10 THEN
            (* 原子性队列更新 *)
            MaterialQueue[QueueTail] := MaterialRequest;
            QueueTail := QueueTail + 1;
            IF QueueTail > 10 THEN
                QueueTail := 1;
            END_IF;
            QueueCount := QueueCount + 1;
            QueueOverflow := FALSE;
        ELSE
            (* 队列溢出处理 *)
            QueueOverflow := TRUE;
            SafetyError := TRUE;
        END_IF;
    ELSE
        (* 无效请求处理 *)
        InvalidRequest := TRUE;
        SafetyError := TRUE;
    END_IF;
END_IF;

(* 2. 处理AGV任务完成 *)
(* AGV1任务完成处理 *)
IF TaskComplete_AGV1 AND NOT AGVStatus[1] THEN
    AGVStatus[1] := TRUE;
    AGVTask[1] := 0;
    AGV1_Position := 0; (* 重置位置 *)
END_IF;

(* AGV2任务完成处理 *)
IF TaskComplete_AGV2 AND NOT AGVStatus[2] THEN
    AGVStatus[2] := TRUE;
    AGVTask[2] := 0;
    AGV2_Position := 0; (* 重置位置 *)
END_IF;

(* AGV3任务完成处理 *)
IF TaskComplete_AGV3 AND NOT AGVStatus[3] THEN
    AGVStatus[3] := TRUE;
    AGVTask[3] := 0;
    AGV3_Position := 0; (* 重置位置 *)
END_IF;

(* 3. 优先级任务分配策略 *)
IF QueueCount > 0 THEN
    (* 从队列头部获取任务 *)
    TempTask := MaterialQueue[QueueHead];
    
    (* 优先级分配：AGV1 > AGV2 > AGV3 *)
    IF AGVStatus[1] THEN
        (* 分配任务给AGV1 *)
        AGVTask[1] := TempTask;
        AGVStatus[1] := FALSE;
        
        (* 更新队列 *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        QueueCount := QueueCount - 1;
        
    ELSIF AGVStatus[2] THEN
        (* 分配任务给AGV2 *)
        AGVTask[2] := TempTask;
        AGVStatus[2] := FALSE;
        
        (* 更新队列 *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        QueueCount := QueueCount - 1;
        
    ELSIF AGVStatus[3] THEN
        (* 分配任务给AGV3 *)
        AGVTask[3] := TempTask;
        AGVStatus[3] := FALSE;
        
        (* 更新队列 *)
        QueueHead := QueueHead + 1;
        IF QueueHead > 10 THEN
            QueueHead := 1;
        END_IF;
        QueueCount := QueueCount - 1;
    END_IF;
END_IF;

(* 4. 更新AGV位置并实施安全约束 *)
(* AGV1位置更新 *)
IF NOT AGVStatus[1] THEN
    AGV1_Position := AGV1_Position + AGV1_PositionUpdate;
    (* 安全约束：确保位置非负 *)
    IF AGV1_Position < 0 THEN
        AGV1_Position := 0;
        SafetyError := TRUE;
    END_IF;
END_IF;

(* AGV2位置更新 *)
IF NOT AGVStatus[2] THEN
    AGV2_Position := AGV2_Position + AGV2_PositionUpdate;
    (* 安全约束：确保位置非负 *)
    IF AGV2_Position < 0 THEN
        AGV2_Position := 0;
        SafetyError := TRUE;
    END_IF;
END_IF;

(* AGV3位置更新 *)
IF NOT AGVStatus[3] THEN
    AGV3_Position := AGV3_Position + AGV3_PositionUpdate;
    (* 安全约束：确保位置非负 *)
    IF AGV3_Position < 0 THEN
        AGV3_Position := 0;
        SafetyError := TRUE;
    END_IF;
END_IF;

(* 5. 状态监控和同步 *)
(* 更新输出状态 *)
AGV1_Ready := AGVStatus[1];
AGV2_Ready := AGVStatus[2];
AGV3_Ready := AGVStatus[3];

AGV1_CurrentTask := AGVTask[1];
AGV2_CurrentTask := AGVTask[2];
AGV3_CurrentTask := AGVTask[3];

(* 监控系统空闲状态 *)
SystemIdle := (QueueCount = 0) AND AGVStatus[1] AND AGVStatus[2] AND AGVStatus[3];

(* 监控状态转换一致性 *)
IF PreviousQueueCount > QueueCount AND QueueCount > 0 THEN
    (* 队列任务减少但未分配任务，检查状态一致性 *)
    IF AGVStatus[1] AND AGVStatus[2] AND AGVStatus[3] THEN
        SafetyError := TRUE; (* 所有AGV就绪但队列任务减少，状态不一致 *)
    END_IF;
END_IF;
PreviousQueueCount := QueueCount;

(* 6. 错误处理恢复机制 *)
(* 如果系统空闲且无错误，清除安全错误标志 *)
IF SystemIdle AND NOT QueueOverflow AND NOT InvalidRequest THEN
    SafetyError := FALSE;
END_IF;

(* 确保任务不会重复分配 *)
FOR i := 1 TO 3 DO
    IF AGVTask[i] <> 0 THEN
        (* 检查其他AGV是否有相同任务 *)
        IF (i = 1 AND (AGVTask[2] = AGVTask[1] OR AGVTask[3] = AGVTask[1])) OR
           (i = 2 AND (AGVTask[1] = AGVTask[2] OR AGVTask[3] = AGVTask[2])) OR
           (i = 3 AND (AGVTask[1] = AGVTask[3] OR AGVTask[2] = AGVTask[3])) THEN
            SafetyError := TRUE;
            (* 重置重复的任务 *)
            IF i = 1 THEN AGVTask[1] := 0; AGVStatus[1] := TRUE; END_IF;
            IF i = 2 THEN AGVTask[2] := 0; AGVStatus[2] := TRUE; END_IF;
            IF i = 3 THEN AGVTask[3] := 0; AGVStatus[3] := TRUE; END_IF;
        END_IF;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK