package creatures.gene;

import haxe.io.Bytes;

/**
 * Decodes the 16-entry state-variable rules that lobe and tract genes carry.
 * Each entry is three codons: opcode, operand kind and array index/value.
 */
class SVRule {
    public static inline var Length = 16;
    public static inline var EntrySize = 3;
    public static inline var ByteSize = Length * EntrySize;

    static inline var FloatDivisor = 248;

    static var OpCodeNames = [
        "stop", "blank", "store accumulator into", "load accumulator from",
        "if =", "if !=", "if >", "if <", "if >=", "if <=",
        "if zero", "if non-zero", "if positive", "if negative", "if non-negative", "if non-positive",
        "add", "subtract", "subtract from", "multiply by", "divide by", "divide into",
        "min into accumulator", "max into accumulator",
        "set tend rate", "tend accumulator to", "negate into accumulator", "load |x| into accumulator",
        "distance to", "flip around",
        "no operation", "set to spare neuron", "bound 0..1", "bound -1..1", "add and store in", "tend to and store in",
        "nominal threshold", "leakage rate", "rest state", "input gain", "persistence", "signal noise",
        "winner takes all", "set ST to LT rate", "set LT to ST rate and converge", "store |acc| into",
        "stop if zero", "stop if non-zero", "goto if zero", "goto if non-zero",
        "divide and add to neuron input", "multiply and add to neuron input", "goto line",
        "stop if <", "stop if >", "stop if <=", "stop if >=",
        "set reward threshold", "set reward rate", "set reward chemical",
        "set punishment threshold", "set punishment rate", "set punishment chemical",
        "preserve variable", "restore variable", "preserve spare variable", "restore spare variable",
        "goto if negative", "goto if positive"
    ];

    static var OperandNames = [
        "accumulator", "input", "dendrite", "neuron", "spare neuron", "random",
        "chemical[src id +", "chemical", "chemical[dst id +",
        "zero", "one", "value", "-value", "value x10", "value /10", "value int"
    ];

    // Operations that do not read an operand: stop, no operation, set to spare neuron, winner takes all
    static function takesNoOperand(op : Int) : Bool {
        return op == 0 || op == 30 || op == 31 || op == 42;
    }

    /**
     * Reads the rule starting at the given absolute byte offset.
     * Entries after the first "stop" are never executed, so they are left out.
     */
    public static function read(bytes : Bytes, offset : Int) : Array<SVRuleEntry> {
        var entries = [];

        for(i in 0...Length) {
            var at = offset + i * EntrySize;
            var op = bytes.get(at) % OpCodeNames.length;
            var operand = bytes.get(at + 1) % OperandNames.length;
            var raw = bytes.get(at + 2);
            var index = operand >= 1 && operand <= 4 ? raw % 8 : raw;

            entries.push({ opCode : op, operand : operand, index : index, text : describe(op, operand, index) });

            if(op == 0) {
                break;
            }
        }

        return entries;
    }

    static function describe(op : Int, operand : Int, index : Int) : String {
        var name = OpCodeNames[op];

        if(takesNoOperand(op)) {
            return name;
        }

        return name + " " + describeOperand(operand, index);
    }

    static function describeOperand(operand : Int, index : Int) : String {
        var name = OperandNames[operand];

        return switch(operand) {
            case 1 | 2 | 3 | 4: name + "[" + index + "]";
            case 6 | 8: name + " " + index + "]";
            case 7: name + "[" + index + "]";
            case 15: name + " " + index;
            case 11 | 12 | 13 | 14:
                var value = Math.min(1.0, index / FloatDivisor);
                name + " " + Std.string(Math.round(value * 1000) / 1000);
            default: name;
        }
    }
}
