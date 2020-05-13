package creatures.gene;

import haxe.io.Bytes;


class GenusGene extends CreatureGene {

    public var genus(get, never) : Int;
    public var mother(get, never) : String;
    public var father(get, never) : String;

    static inline var GenusOffset = Gene.FirstGeneByte;
    static inline var MotherOffset = Gene.FirstGeneByte + 1;
    static inline var FatherOffset = Gene.FirstGeneByte + 1 + 32;

    var _mother : String;
    var _father : String;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Genus Gene (${genus}, ${mother}, ${father})';
    }

    public function get_genus() : Int {
        return _bytes.get(_offset + GenusOffset) % 4;
    }

    public function get_mother() : String {
        if(_mother == null) {
            _mother = extractString(_offset + MotherOffset, 32);
        }

        return _mother;
    }

    public function get_father() : String {
        if(_father == null) {
            _father = extractString(_offset + FatherOffset, 32);
        }

        return _father;
    }

    function extractString(start : Int, size : Int) : String {

        var i = 0;

        while(i < size) {
            if(_bytes.get(start + i) == 0) {
                break;
            }

            ++i;
        }

        return _bytes.getString(start, i);
    }
}