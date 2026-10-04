package creatures.gene;

typedef SVRuleEntry = {
    var opCode : Int;
    var operand : Int;
    var index : Int;
    /** The whole line as text: the operation followed by its operand. */
    var text : String;
    /** The operation alone ("load accumulator from"). */
    var opName : String;
    /** The operand alone ("neuron[2]", "value 0.5", "line 5"), empty when the operation has none. */
    var operandText : String;
    /** What the operation does: "flow", "memory", "math", "neuron", "learning" or "other". */
    var category : String;
    /** What the operand is: "variable", "chemical", "number", "accumulator" or "other". */
    var operandKind : String;
}
