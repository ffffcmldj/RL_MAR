FUNCTION_BLOCK AGVControlSystem
VAR_INPUT
    MaterialRequest : INT; (* 新的物料请求 *)
    TaskCompletion : ARRAY[1..3] OF BOOL; (* AGV任务完成信号 *)
    PositionUpdate : ARRAY[1..3] OF INT; (* AGV位置更新值 *)
END_VAR
VAR_OUTPUT
    AGV1_Ready : BOOL := TRUE; (* AGV 1 就绪状态 *)
    AGV2_Ready : BOOL := TRUE; (* AGV 2 就绪状态 *)
    AGV3_Ready : BOOL := TRUE; (* AGV 3 就绪状态 *)
    QueueStatus : INT := 0; (* 队列状态：0-空，1-有任务，2-满 *)
    ErrorFlag : BOOL := FALSE; (* 错误标志 *)
    ErrorCode : INT := 0; (* 错误代码：0-无错误，1-队列满，2-无效请求，3-位置错误 *)
END_VAR
VAR
    MaterialQueue : ARRAY[1..10] OF INT; (* 物料处理请求队列 *)
    QueueHead : INT := 1; (* 队列头指针 *)
    QueueTail : INT := 1; (* 队列尾指针 *)
    QueueCount : INT := 0; (* 队列中任务数量 *)
    AGVPosition : ARRAY[1..3] OF INT := [0, 0, 0]; (* AGV位置数组 *)
    AGVTask : ARRAY[1..3] OF INT := [0, 0, 0]; (* AGV当前任务 *)
    AGVWorking : ARRAY[1..3] OF BOOL := [FALSE, FALSE, FALSE]; (* AGV工作状态 *)
    i : INT; (* 循环计数器 *)
    j : INT; (* 循环计数器 *)
    tempInt : INT; (* 临时整型变量 *)
    tempBool : BOOL; (* 临时布尔变量 *)
    QueueFull : BOOL; (* 队列满标志 *)
    QueueEmpty : BOOL; (* 队列空标志 *)
    TaskAssigned : BOOL; (* 任务分配标志 *)
    AGVIndex : INT; (* AGV索引 *)
    TaskToAssign : INT; (* 待分配任务 *)
END_VAR

(* 初始化检查 *)
IF QueueHead < 1 THEN
    QueueHead := 1;
END_IF;
IF QueueHead > 10 THEN
    QueueHead := 10;
END_IF;
IF QueueTail < 1 THEN
    QueueTail := 1;
END_IF;
IF QueueTail > 10 THEN
    QueueTail := 10;
END_IF;

(* 计算队列状态 *)
QueueFull := QueueCount >= 10;
QueueEmpty := QueueCount <= 0;

(* 更新队列状态输出 *)
IF QueueEmpty THEN
    QueueStatus := 0;
ELSIF QueueFull THEN
    QueueStatus := 2;
ELSE
    QueueStatus := 1;
END_IF;

(* 错误标志复位 *)
ErrorFlag := FALSE;
ErrorCode := 0;

(* 1. 处理物料请求 *)
IF MaterialRequest > 0 THEN
    (* 有效请求 *)
    IF NOT QueueFull THEN
        (* 入队操作 *)
        MaterialQueue[QueueTail] := MaterialRequest;
        
        (* 更新队列尾指针 *)
        QueueTail := QueueTail + 1;
        IF QueueTail > 10 THEN
            QueueTail := 1;
        END_IF;
        
        (* 更新队列计数 *)
        QueueCount := QueueCount + 1;
        IF QueueCount > 10 THEN
            QueueCount := 10;
        END_IF;
    ELSE
        (* 队列满错误 *)
        ErrorFlag := TRUE;
        ErrorCode := 1;
    END_IF;
ELSIF MaterialRequest < 0 THEN
    (* 无效请求 *)
    ErrorFlag := TRUE;
    ErrorCode := 2;
END_IF;

(* 2. 处理AGV任务完成 *)
FOR i := 1 TO 3 DO
    IF TaskCompletion[i] AND AGVWorking[i] THEN
        (* 任务完成，重置AGV状态 *)
        AGVWorking[i] := FALSE;
        AGVTask[i] := 0;
        
        (* 更新AGV位置 *)
        AGVPosition[i] := AGVPosition[i] + PositionUpdate[i];
        
        (* 确保位置非负 *)
        IF AGVPosition[i] < 0 THEN
            AGVPosition[i] := 0;
            ErrorFlag := TRUE;
            ErrorCode := 3;
        END_IF;
    END_IF;
END_FOR;

(* 3. 更新AGV就绪状态 *)
AGV1_Ready := NOT AGVWorking[1];
AGV2_Ready := NOT AGVWorking[2];
AGV3_Ready := NOT AGVWorking[3];

(* 4. 任务分配策略 *)
TaskAssigned := FALSE;

(* 检查队列是否为空 *)
IF NOT QueueEmpty THEN
    (* 按优先级顺序检查AGV *)
    FOR AGVIndex := 1 TO 3 DO
        IF NOT AGVWorking[AGVIndex] AND NOT TaskAssigned THEN
            (* 找到就绪的AGV *)
            
            (* 从队列中取出任务 *)
            TaskToAssign := MaterialQueue[QueueHead];
            
            (* 更新队列头指针 *)
            QueueHead := QueueHead + 1;
            IF QueueHead > 10 THEN
                QueueHead := 1;
            END_IF;
            
            (* 更新队列计数 *)
            QueueCount := QueueCount - 1;
            IF QueueCount < 0 THEN
                QueueCount := 0;
            END_IF;
            
            (* 分配任务给AGV *)
            AGVTask[AGVIndex] := TaskToAssign;
            AGVWorking[AGVIndex] := TRUE;
            TaskAssigned := TRUE;
            
            (* 清空队列中的该位置 *)
            MaterialQueue[QueueHead - 1] := 0;
            IF QueueHead = 1 THEN
                MaterialQueue[10] := 0;
            END_IF;
        END_IF;
    END_FOR;
END_IF;

(* 5. 状态同步和监控 *)
(* 确保队列指针和计数的一致性 *)
IF QueueCount = 0 THEN
    QueueHead := 1;
    QueueTail := 1;
    
    (* 清空队列 *)
    FOR i := 1 TO 10 DO
        MaterialQueue[i] := 0;
    END_FOR;
END_IF;

(* 确保AGV位置非负的二次检查 *)
FOR i := 1 TO 3 DO
    IF AGVPosition[i] < 0 THEN
        AGVPosition[i] := 0;
        IF NOT ErrorFlag THEN
            ErrorFlag := TRUE;
            ErrorCode := 3;
        END_IF;
    END_IF;
END_FOR;

END_FUNCTION_BLOCK