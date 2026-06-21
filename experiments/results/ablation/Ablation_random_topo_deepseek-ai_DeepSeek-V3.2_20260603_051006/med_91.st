FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT; (* 新的物料请求 *)
END_VAR
VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE; (* AGV 1 就绪状态 *)
    AGV2_Ready : BOOL := TRUE; (* AGV 2 就绪状态 *)
    AGV3_Ready : BOOL := TRUE; (* AGV 3 就绪状态 *)
    SystemErrorCode : INT := 0; (* 系统错误代码 *)
    QueueCount : INT := 0; (* 当前队列任务数 *)
END_VAR
VAR
    (* 队列管理变量 *)
    MaterialQueue : ARRAY[1..10] OF INT; (* 物料处理请求队列 *)
    QueueHead : INT := 1; (* 队列头部指针 *)
    QueueTail : INT := 1; (* 队列尾部指针 *)
    QueueEmpty : BOOL := TRUE; (* 队列空标志 *)
    QueueFull : BOOL := FALSE; (* 队列满标志 *)
    
    (* AGV状态变量 *)
    AGVStatus : ARRAY[1..3] OF BOOL := [TRUE, TRUE, TRUE]; (* TRUE=就绪, FALSE=工作中 *)
    AGVPosition : ARRAY[1..3] OF INT := [0, 0, 0]; (* AGV当前位置 *)
    AGVTask : ARRAY[1..3] OF INT := [0, 0, 0]; (* AGV当前任务 *)
    AGVTaskProgress : ARRAY[1..3] OF INT := [0, 0, 0]; (* AGV任务进度 *)
    
    (* 临时变量 *)
    TempRequest : INT;
    TempPosition : INT;
    i : INT;
    j : INT;
    TaskAssigned : BOOL;
    ValidRequest : BOOL;
    
    (* 状态监控 *)
    SystemIdle : BOOL := TRUE;
    AnyAGVWorking : BOOL := FALSE;
    QueueOverflowError : BOOL := FALSE;
    PositionError : BOOL := FALSE;
    DuplicateTaskError : BOOL := FALSE;
END_VAR

(* 1. 初始化检查和状态重置 *)
IF SystemErrorCode <> 0 THEN
    (* 系统错误时重置状态 *)
    FOR i := 1 TO 3 DO
        AGVStatus[i] := TRUE;
        AGVPosition[i] := 0;
        AGVTask[i] := 0;
        AGVTaskProgress[i] := 0;
    END_FOR;
    QueueHead := 1;
    QueueTail := 1;
    QueueEmpty := TRUE;
    QueueFull := FALSE;
    QueueCount := 0;
    SystemErrorCode := 0;
END_IF;

(* 2. 处理新的物料请求 *)
ValidRequest := (MaterialRequest > 0);
IF ValidRequest THEN
    IF NOT QueueFull THEN
        (* 入队操作 *)
        MaterialQueue[QueueTail] := MaterialRequest;
        
        (* 更新队列尾部指针 *)
        QueueTail := QueueTail + 1;
        IF QueueTail > 10 THEN
            QueueTail := 1;
        END_IF;
        
        (* 更新队列状态 *)
        QueueEmpty := FALSE;
        QueueCount := QueueCount + 1;
        IF QueueCount >= 10 THEN
            QueueFull := TRUE;
        END_IF;
        
        QueueOverflowError := FALSE;
    ELSE
        (* 队列溢出错误 *)
        QueueOverflowError := TRUE;
        SystemErrorCode := 1;
    END_IF;
ELSIF MaterialRequest < 0 THEN
    (* 无效请求错误 *)
    SystemErrorCode := 2;
END_IF;

(* 3. 安全检查：确保AGV位置非负 *)
PositionError := FALSE;
FOR i := 1 TO 3 DO
    IF AGVPosition[i] < 0 THEN
        AGVPosition[i] := 0;
        PositionError := TRUE;
        SystemErrorCode := 3;
    END_IF;
END_FOR;

(* 4. 任务分配：基于优先级AGV1 > AGV2 > AGV3 *)
TaskAssigned := FALSE;
IF (NOT QueueEmpty) AND (SystemErrorCode = 0) THEN
    FOR i := 1 TO 3 DO
        IF (AGVStatus[i] = TRUE) AND (NOT TaskAssigned) THEN
            (* 从队列头部获取任务 *)
            TempRequest := MaterialQueue[QueueHead];
            
            (* 检查任务是否已被分配 *)
            DuplicateTaskError := FALSE;
            FOR j := 1 TO 3 DO
                IF (j <> i) AND (AGVTask[j] = TempRequest) AND (AGVTask[j] <> 0) THEN
                    DuplicateTaskError := TRUE;
                    SystemErrorCode := 4;
                END_IF;
            END_FOR;
            
            IF NOT DuplicateTaskError THEN
                (* 分配任务给AGV *)
                AGVTask[i] := TempRequest;
                AGVStatus[i] := FALSE;
                AGVTaskProgress[i] := 0;
                
                (* 更新队列头部指针 *)
                QueueHead := QueueHead + 1;
                IF QueueHead > 10 THEN
                    QueueHead := 1;
                END_IF;
                
                (* 更新队列状态 *)
                QueueCount := QueueCount - 1;
                IF QueueCount <= 0 THEN
                    QueueCount := 0;
                    QueueEmpty := TRUE;
                END_IF;
                QueueFull := FALSE;
                
                TaskAssigned := TRUE;
            END_IF;
        END_IF;
    END_FOR;
END_IF;

(* 5. 模拟AGV任务执行和位置更新 *)
AnyAGVWorking := FALSE;
FOR i := 1 TO 3 DO
    IF AGVStatus[i] = FALSE THEN
        AnyAGVWorking := TRUE;
        
        IF AGVTask[i] > 0 THEN
            (* 模拟AGV移动 *)
            AGVTaskProgress[i] := AGVTaskProgress[i] + 1;
            AGVPosition[i] := AGVTaskProgress[i];
            
            (* 检查任务是否完成 *)
            IF AGVTaskProgress[i] >= AGVTask[i] THEN
                (* 任务完成，重置AGV状态 *)
                AGVPosition[i] := 0;
                AGVTask[i] := 0;
                AGVTaskProgress[i] := 0;
                AGVStatus[i] := TRUE;
            END_IF;
        END_IF;
    END_IF;
END_FOR;

(* 6. 更新系统空闲状态 *)
SystemIdle := (QueueEmpty) AND (AGVStatus[1] = TRUE) AND (AGVStatus[2] = TRUE) AND (AGVStatus[3] = TRUE);
IF SystemIdle THEN
    (* 系统空闲时确保所有AGV位置归零 *)
    FOR i := 1 TO 3 DO
        AGVPosition[i] := 0;
    END_FOR;
END_IF;

(* 7. 更新输出状态 *)
AGV1_Ready := AGVStatus[1];
AGV2_Ready := AGVStatus[2];
AGV3_Ready := AGVStatus[3];

(* 8. 资源释放验证 *)
FOR i := 1 TO 3 DO
    IF (AGVStatus[i] = TRUE) AND (AGVTask[i] <> 0) THEN
        (* 状态不一致，强制释放资源 *)
        AGVTask[i] := 0;
        AGVTaskProgress[i] := 0;
        SystemErrorCode := 5;
    END_IF;
END_FOR;

(* 9. 防止重复任务分配（二次检查） *)
FOR i := 1 TO 2 DO
    FOR j := i + 1 TO 3 DO
        IF (AGVTask[i] = AGVTask[j]) AND (AGVTask[i] <> 0) THEN
            (* 发现重复任务，释放较低优先级的AGV *)
            IF j > i THEN
                AGVTask[j] := 0;
                AGVStatus[j] := TRUE;
                AGVTaskProgress[j] := 0;
                AGVPosition[j] := 0;
            END_IF;
            SystemErrorCode := 6;
        END_IF;
    END_FOR;
END_FOR;

(* 10. 状态监控和错误处理汇总 *)
IF SystemErrorCode <> 0 THEN
    (* 有错误时设置所有AGV为就绪状态以确保安全 *)
    AGV1_Ready := TRUE;
    AGV2_Ready := TRUE;
    AGV3_Ready := TRUE;
END_IF;

END_FUNCTION_BLOCK