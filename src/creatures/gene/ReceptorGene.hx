package creatures.gene;

import haxe.io.Bytes;


@:build(JsProp.all())
class ReceptorGene extends BiochemistryGene {

    public var organId(get, never) : Int;
    public var tissueId(get, never) : Int;
    public var locusId(get, never) : Int;
    public var chemical(get, never) : Int;
    public var threshold(get, never) : Float;
    public var nominal(get, never) : Float;
    public var gain(get, never) : Float;
    public var effect(get, never) : Int;

    /** Effect flags: the chemical lowers the signal instead of raising it / any signal gives the full gain. */
    public var reduces(get, never) : Bool;
    public var digital(get, never) : Bool;

    static inline var OrganIdOffset = Gene.FirstGeneByte;
    static inline var TissueIdOffset = Gene.FirstGeneByte + 1;
    static inline var LocusIdOffset = Gene.FirstGeneByte + 2;
    static inline var ChemicalOffset = Gene.FirstGeneByte + 3;
    static inline var ThresholdOffset = Gene.FirstGeneByte + 4;
    static inline var NominalOffset = Gene.FirstGeneByte + 5;
    static inline var GainOffset = Gene.FirstGeneByte + 6;
    static inline var EffectOffset = Gene.FirstGeneByte + 7;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Receptor Gene';
    }

    function get_organId() : Int {
        return getByte(OrganIdOffset);
    }

    function get_tissueId() : Int {
        return getByte(TissueIdOffset);
    }

    function get_locusId() : Int {
        return getByte(LocusIdOffset);
    }

    function get_chemical() : Int {
        return getByte(ChemicalOffset);
    }

    function get_threshold() : Float {
        return getFloat(ThresholdOffset);
    }

    function get_nominal() : Float {
        return getFloat(NominalOffset);
    }

    function get_gain() : Float {
        return getFloat(GainOffset);
    }

    function get_effect() : Int {
        return getByte(EffectOffset);
    }

    function get_reduces() : Bool {
        return (effect & 1) != 0;
    }

    function get_digital() : Bool {
        return (effect & 2) != 0;
    }

    override function getTypename() {
        return "Receptor";
    }
}
