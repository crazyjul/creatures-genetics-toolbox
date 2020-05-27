package creatures.gene;

import haxe.io.Bytes;


@:build(JsProp.all())
class ReactionGene extends BiochemistryGene {

    public var organ(get, never):Int;
    public var tissue(get, never):Int;
    public var locus(get, never):Int;
    public var chemical(get, never):Int;
    public var threshold(get, never):Float;
    public var nominal(get, never):Float;
    public var gain(get, never):Float;
    public var effect(get, never):Int;

    static inline var OrganOffset = Gene.FirstGeneByte;
    static inline var TissueOffset = Gene.FirstGeneByte + 1;
    static inline var LocusOffset = Gene.FirstGeneByte + 2;
    static inline var ChemicalOffset = Gene.FirstGeneByte + 3;
    static inline var ThresholdOffset = Gene.FirstGeneByte + 4;
    static inline var NominalOffset = Gene.FirstGeneByte + 5;
    static inline var GainOffset = Gene.FirstGeneByte + 6;
    static inline var EffectOffset = Gene.FirstGeneByte + 7;


    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Reaction Emitter Gene';
    }

    override function getTypename() {
        return  "Emitter";
    }

    public function get_organ():Int {
        return getCodon(OrganOffset, 0, Constants.EmitterOrganCount - 1);
    }

    public function get_tissue():Int {
        return getByte(TissueOffset);
    }

    public function get_locus():Int {
        return getByte(LocusOffset);
    }

    public function get_chemical():Int {
        return getCodon(ChemicalOffset, 0, Constants.ChemicalCount - 1);
    }

    public function get_threshold():Float {
        return getFloat(ThresholdOffset);
    }

    public function get_nominal():Float {
        return return getFloat(NominalOffset);
    }

    public function get_gain():Float {
        return getFloat(GainOffset);
    }

    public function get_effect():Int {
        return getCodon(EffectOffset, 0, 255);
    }
}
