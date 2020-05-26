package creatures.gene;

import haxe.io.Bytes;


@:build(JsProp.all())
class ReceptorGene extends BiochemistryGene {

    var organId(get, never) : Int;
    var tissueId(get, never) : Int;
    var locusId(get, never) : Int;
    var chemical(get, never) : Int;
    var threshold(get, never) : Float;
    var nominal(get, never) : Float;
    var gain(get, never) : Float;
    var effect(get, never) : Int;

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
        return 'Receptor Gene (${organId}, ${tissueId}, ${locusId}, ${chemical})';
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

    override function getTypename() {
        return "Receptor";
    }
}
