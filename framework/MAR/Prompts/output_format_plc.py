# Options for PLC code generation, professionally reinforced for IEC 61131-3 ST standard compliance, inspired by advanced agentic workflows.
output_format_prompt = {
    "None": None,

    "Text": "Provide a clear and concise technical explanation in natural language. Structure your answer with paragraphs or bullet points for readability. Your response must not contain any code blocks or syntax-like text.",

    "StructuredJSON": "You must provide your response exclusively in a single, syntactically correct JSON object. This JSON defines variables according to the IEC 61131-3 standard. It must have three keys: 'VAR_INPUT', 'VAR_OUTPUT', and 'VAR'. Each key must contain a list of objects, where each object has a 'name' (string) and a 'type' (string). The 'type' must be a valid IEC 61131-3 elementary data type (e.g., BOOL, INT, DINT, REAL, TIME) or a derived data type (e.g., a STRUCT or ARRAY). For example:\n"
                      "```json\n"
                      "{\n"
                      "  \"VAR_INPUT\": [\n"
                      "    {\"name\": \"StartButton\", \"type\": \"BOOL\"}\n"
                      "  ],\n"
                      "  \"VAR_OUTPUT\": [],\n"
                      "  \"VAR\": [\n"
                      "    {\"name\": \"HeatingTimer\", \"type\": \"TON\"}\n"
                      "  ]\n"
                      "}\n"
                      "```\n"
                      "Your entire response must be only the JSON object. Do not add any introductory text, closing remarks, or explanations.",

    "Pseudocode": "Describe the control logic using language-agnostic pseudocode. This plan must serve as an unambiguous blueprint for a PLC programmer. Use standard constructs like IF/THEN/ELSE, CASE, FOR, WHILE. Clearly differentiate between assignment (e.g., 'SET MotorSpeed TO 800') and comparison (e.g., 'IF Temperature IS > 65.0'). The logic must be complete and cover all specified conditions and edge cases.",

    "StateTransitionDiagram": "Describe the state machine logic using a structured text format that is directly translatable to an ST CASE statement. For each state, you must define the actions performed within that state and the exact conditions for transitioning to other states. Follow this strict format:\n"
                             "STATE [StateNumber] (* [StateName] *):\n"
                             "  // Actions executed in this state\n"
                             "  [Action 1 using := for assignment];\n"
                             "  [Action 2 using := for assignment];\n\n"
                             "  // Transition logic from this state\n"
                             "  IF [Condition 1] THEN\n"
                             "    NextState := [NextStateNumber 1];\n"
                             "  ELSIF [Condition 2] THEN\n"
                             "    NextState := [NextStateNumber 2];\n"
                             "  END_IF;\n",

    "STCode": "You are an expert PLC programmer specializing in the IEC 61131-3 standard. Your task is to generate a Structured Text (ST) code snippet for a PLC application. You must follow these rules without exception:\n\n"
              "--- STRICT SYNTAX RULES ---\n"
              "1. NO MARKDOWN: Your entire response must be the raw ST code ONLY. Do NOT enclose it in ```st ... ``` or any other markdown syntax.\n"
              "2. ASSIGNMENT IS `:=`: Use `:=` for all value assignments. The `=` operator is ONLY for comparison within expressions.\n"
              "3. TYPE CONVERSIONS: Do NOT use invalid, non-standard syntax. Use the correct IEC 61131-3 function format.\n"
              "4. COMPLETE STRUCTURES: All control structures must be fully formed with their corresponding terminator.\n"
}











