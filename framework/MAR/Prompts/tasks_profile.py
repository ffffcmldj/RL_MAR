tasks_profile = [
                {'Name': 'SequentialLogicControl',
                 'Description': 'Discrete step-by-step control using state machines. '
                    'Outputs are binary ON/OFF actions executed in a fixed sequence or based on timed events. '
                    'Uses CASE statements for state transitions, timers for delays, counters for repetitions. '
                    'Controls physical equipment like valves, conveyor stages, traffic lights through simple on/off signals. '
                    'NO continuous analog regulation, NO feedback loops. NOT a sorting algorithm or data structure task.'},
                {'Name': 'ProcessControl',
                 'Description': 'Closed-loop regulation of continuous analog variables. '
                    'Reads sensor values (temperature, pressure, level, flow) and modulates outputs '
                    '(heater, valve, pump) to maintain a target setpoint. '
                    'Core technique is PID or hysteresis control with feedback. '
                    'The primary challenge is rejecting disturbances to keep a physical variable stable at the desired value. '
                    'NOT step-by-step state machines, NOT pure on/off control.'},
                {'Name': 'MotionAndSortingControl',
                 'Description': 'Precise mechanical motion control and item sorting. '
                    'Controls motor speed, servo position, robotic arm trajectory, or conveyor diverters. '
                    'Uses encoder feedback for position/speed regulation. '
                    'Sorts and routes items based on sensor classification (color, size, weight). '
                    'Involves acceleration profiles, positioning sequences, and multi-axis coordination. '
                    'NOT temperature regulation, NOT data algorithms.'},
                {'Name': 'DataHandlingAndCommunication',
                 'Description': 'Pure data manipulation without physical process control. '
                    'Core operations: sorting arrays, managing stacks/queues, mathematical computation, '
                    'data format conversion, communication protocol encoding, look-up tables, counting, and arithmetic logic. '
                    'May have I/O variables but the central challenge is data processing, not controlling physical equipment. '
                    'NOT state machine control of machinery, NOT PID regulation.'},
                {'Name': 'SafetyAndMonitoring',
                 'Description': 'Safety-critical override logic as the PRIMARY function. '
                    'Emergency stop that immediately halts all equipment. '
                    'Safety interlocks that prevent unsafe states. '
                    'Redundant monitoring of critical parameters with automatic safe-state activation. '
                    'Fault diagnostics and error response. '
                    'ALL normal operations are secondary to safety. '
                    'NOT a control system that merely includes a stop button as one input among many.'}
                ]
