package creatures.gene;

import haxe.io.Bytes;

@:build(JsProp.all())
class Gene {
    var _bytes : Bytes;
    var _offset : Int;

    public static inline var TypeOffset = 4;
    public static inline var SubtypeOffset = 5;
    public static inline var IdOffset = 6;
    public static inline var GenerationOffset = 7;
    public static inline var AgeOffset = 8;
    public static inline var FlagsOffset = 9;
    public static inline var MutabilityOffet = 10;
    public static inline var VariantOffset = 11;

    public static inline var MutableFlag = 1;
    public static inline var DuplicateFlag = 2;
    public static inline var CutFlag = 4;
    public static inline var MaleFlag = 8;
    public static inline var FemaleFlag = 16;
    public static inline var IgnoreFlag = 32;

    public static inline var FirstGeneByte = 12;

    public var type(get, never) : Int;
    public var subtype(get, never) : Int;
    public var id(get, never) : Int;
    public var generation(get, never) : Int;
    public var age(get, never) : Age;
    public var flags(get, never): Array<GeneFlag>;
    public var variant(get, never): Int;
    public var sex(get, never) : SexActivation;

    public function new(bytes :  Bytes, offset : Int) {
        _bytes = bytes;
        _offset = offset;
    }

    function get_type() : Int {
        return getByte(TypeOffset);
    }

    function set_type(value : Int) : Int {
        return value;
    }

    function get_subtype() : Int {
        return getByte(SubtypeOffset);
    }

    function get_id() : Int {
        return getByte(IdOffset);

    }

    function get_generation() : Int {
        return getByte(GenerationOffset);
    }

    function get_age() : Age {
        var age = getByte(AgeOffset);

        switch(age) {
            case 0: return Embryo;

            case 1: return Child;

            case 2: return Adolescent;

            case 3: return Youth;

            case 4: return Adult;

            case 5: return Old;

            case 6: return Senile;

            // Throw an error ?
            default : return Embryo;
        }
    }

    function get_flags() :Array<GeneFlag> {
        return [];
    }

    function get_variant() : Int {
        return getByte(VariantOffset);
    }

    function getName() :String {
        return "Unknown gene ( " + type + ")";
    }

    function getByte(local_offset : Int) : Int {
        return _bytes.get(_offset + local_offset);
    }

    function getFloat(local_offset : Int) : Float {
        return _bytes.get(_offset + local_offset) / 255;
    }

    function get_sex() : SexActivation {
        var sex = getByte(FlagsOffset);
        sex &= MaleFlag | FemaleFlag;

        if(sex == 0 || sex == (MaleFlag | FemaleFlag)) {
            return Both;
        } else if(sex == MaleFlag) {
            return Male;
        } else {
            return Female;
        }
    }

}