package creatures.gene;

/**
 * Describes one editable value inside a gene, so a UI can show and change it without knowing the gene kind.
 *
 * kind is one of:
 *  - "byte":     a byte, 0 to 255
 *  - "codon":    a byte the game wraps into min..max
 *  - "int16":    two bytes, big-endian, 0 to 65535
 *  - "float":    a byte read as 0 to 1
 *  - "sfloat":   a byte read as -1 to 1
 *  - "chemical": a byte naming a chemical (0 is none)
 *  - "bit":      one flag inside a byte, picked by mask
 *  - "bool":     a byte that is true unless it is 0 (written as 1 or 0)
 *  - "text":     length characters stored as bytes
 */
typedef GeneField = {
    var name : String;
    var label : String;
    var kind : String;
    /** Position of the value from the start of the gene (the gene's header takes the first 12 bytes). */
    var offset : Int;
    var min : Int;
    var max : Int;
    var mask : Int;
    var length : Int;
    var hint : String;
}
