package creatures.gene;

import haxe.io.Bytes;

@:build(JsProp.all())
class StimulusGene extends CreatureGene {

    public var stimulus(get, never) : Int;
    public var nounStimulation(get, never): Float;
    public var verbToStimulate(get, never): Int;
    public var stimulusFlags(get, never): Int;
    public var chemicals(get, never): Array<Int>;
    public var adjustments(get, never): Array<Float>;

    public var _chemicals: Array<Int>;
    public var _adjustments: Array<Float>;

    static inline var StimulusOffset = Gene.FirstGeneByte;
    static inline var NounStimulationOffset = Gene.FirstGeneByte + 1;
    static inline var VerbToStimulateOffset = Gene.FirstGeneByte + 2;
    static inline var StimulusFlagsOffset = Gene.FirstGeneByte + 4;
    static inline var ChemicalsOffset = Gene.FirstGeneByte + 5;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Stimulus Gene';
    }

    override function getTypename() {
        return "Stimulus";
    }

    function get_stimulus() : Int {
        return getCodon(0, 0, Constants.StimuliCount - 1);
    }

    function get_nounStimulation(): Float {
        return getFloat(NounStimulationOffset);
    }

    function get_verbToStimulate(): Int {
        return getByteWithInvalid(VerbToStimulateOffset);
    }

    function get_stimulusFlags(): Int {
        return getByte(StimulusFlagsOffset);
    }

    function get_chemicals(): Array<Int> {
        if(_chemicals == null) {
            loadCache();
        }

        return _chemicals;
    }

    function get_adjustments(): Array<Float> {
        if(_adjustments == null) {
            loadCache();
        }

        return _adjustments;
    }

    function loadCache() {
        _chemicals  = [];
        _adjustments = [];

        for(i in 0...4) {
            _chemicals[i] = getByte(ChemicalsOffset + 2 * i);
            _adjustments[i] = getSignedFloat(ChemicalsOffset + 2 * i + 1);
        }
    }

}