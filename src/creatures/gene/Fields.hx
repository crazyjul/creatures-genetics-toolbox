package creatures.gene;

/** Builders for GeneField, so gene classes can list their fields briefly. */
class Fields {
    static function make(name : String, label : String, kind : String, offset : Int, hint : String) : GeneField {
        return { name : name, label : label, kind : kind, offset : offset, min : 0, max : 255, mask : 0, length : 1, hint : hint };
    }

    public static function byte(name : String, label : String, offset : Int, ?hint : String) : GeneField {
        return make(name, label, "byte", offset, hint);
    }

    public static function codon(name : String, label : String, offset : Int, min : Int, max : Int, ?hint : String) : GeneField {
        var field = make(name, label, "codon", offset, hint);
        field.min = min;
        field.max = max;

        return field;
    }

    public static function int16(name : String, label : String, offset : Int, ?hint : String) : GeneField {
        var field = make(name, label, "int16", offset, hint);
        field.max = 65535;
        field.length = 2;

        return field;
    }

    public static function float(name : String, label : String, offset : Int, ?hint : String) : GeneField {
        return make(name, label, "float", offset, hint);
    }

    public static function sfloat(name : String, label : String, offset : Int, ?hint : String) : GeneField {
        return make(name, label, "sfloat", offset, hint);
    }

    public static function chemical(name : String, label : String, offset : Int, ?hint : String) : GeneField {
        return make(name, label, "chemical", offset, hint);
    }

    public static function bit(name : String, label : String, offset : Int, mask : Int, ?hint : String) : GeneField {
        var field = make(name, label, "bit", offset, hint);
        field.mask = mask;

        return field;
    }

    public static function bool(name : String, label : String, offset : Int, ?hint : String) : GeneField {
        return make(name, label, "bool", offset, hint);
    }

    public static function text(name : String, label : String, offset : Int, length : Int, ?hint : String) : GeneField {
        var field = make(name, label, "text", offset, hint);
        field.length = length;

        return field;
    }
}
