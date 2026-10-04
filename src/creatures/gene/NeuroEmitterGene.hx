package creatures.gene;

import haxe.io.Bytes;

typedef NeuroEmitterInput = {
    /** Tissue id of the lobe, -1 when the slot is unused. */
    var lobeTissueId : Int;
    var neuron : Int;
}

typedef NeuroEmitterEmission = {
    var chemical : Int;
    var amount : Float;
}

/**
 * Emits chemicals according to the activity of up to three neurons.
 * Layout (from the engine's Biochemistry::ReadFromGenome): three (lobe + 1, neuron) byte pairs,
 * a tick rate, then four (chemical, amount) pairs. A lobe byte of 255 means the slot is unused.
 */
@:build(JsProp.all())
class NeuroEmitterGene extends BiochemistryGene {

    public var inputs(get, never):Array<NeuroEmitterInput>;
    public var bioTickRate(get, never):Float;
    public var emissions(get, never):Array<NeuroEmitterEmission>;

    static inline var InputCount = 3;
    static inline var EmissionCount = 4;
    static inline var InputsOffset = Gene.FirstGeneByte;
    static inline var BioTickRateOffset = Gene.FirstGeneByte + 2 * InputCount;
    static inline var EmissionsOffset = BioTickRateOffset + 1;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Neuro Emitter Gene';
    }

    override function getTypename() {
        return "NeuroEmitter";
    }

    public function get_inputs():Array<NeuroEmitterInput> {
        var result = [];

        for(i in 0...InputCount) {
            var lobe = getByte(InputsOffset + 2 * i);
            result.push({ lobeTissueId : lobe == 255 ? -1 : lobe - 1, neuron : getByte(InputsOffset + 2 * i + 1) });
        }

        return result;
    }

    public function get_bioTickRate():Float {
        return getFloat(BioTickRateOffset);
    }

    public function get_emissions():Array<NeuroEmitterEmission> {
        var result = [];

        for(i in 0...EmissionCount) {
            result.push({
                chemical : getByte(EmissionsOffset + 2 * i),
                amount : getFloat(EmissionsOffset + 2 * i + 1)
            });
        }

        return result;
    }
}
