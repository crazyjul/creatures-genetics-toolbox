package creatures.gene;

import haxe.io.Bytes;

typedef InstinctInput = {
    /** Tissue id of the lobe the neuron belongs to, -1 when the slot is unused or invalid. */
    var lobeTissueId : Int;
    var neuron : Int;
}

@:build(JsProp.all())
class InstinctGene extends CreatureGene {

    public var inputs(get, never):Array<InstinctInput>;
    public var action(get, never):Int;
    public var drive(get, never):Int;
    public var reinforcement(get, never):Float;

    static inline var InputsOffset = Gene.FirstGeneByte;
    static inline var InputCount = 3;
    static inline var ActionOffset = Gene.FirstGeneByte + 2 * InputCount;
    static inline var DriveOffset = ActionOffset + 1;
    static inline var ReinforcementOffset = ActionOffset + 2;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Instinct Gene';
    }

    override function getTypename() {
        return "Instinct";
    }

    public function get_inputs():Array<InstinctInput> {
        var result = [];

        for(i in 0...InputCount) {
            // The lobe is stored as tissue id + 1 so that 0 means "none"; 255 is invalid.
            var tissue = getByte(InputsOffset + 2 * i) - 1;
            result.push({ lobeTissueId : tissue < 0 || tissue == 254 ? -1 : tissue, neuron : getByte(InputsOffset + 2 * i + 1) });
        }

        return result;
    }

    public function get_action():Int {
        return getByte(ActionOffset);
    }

    public function get_drive():Int {
        return getCodon(DriveOffset, 0, 255);
    }

    public function get_reinforcement():Float {
        return getSignedFloat(ReinforcementOffset);
    }
}
