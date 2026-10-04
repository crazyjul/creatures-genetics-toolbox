package creatures.gene;

import haxe.io.Bytes;

/**
 * Skin pigment effects: how much the pigment colours rotate and swap with each other.
 * Not read by the Creatures 4 engine; two bytes in Creatures 3 genomes, 128 being neutral.
 */
@:build(JsProp.all())
class PigmentbleedGene extends CreatureGene {

    public var rotation(get, never):Int;
    public var swap(get, never):Int;

    static inline var RotationOffset = Gene.FirstGeneByte;
    static inline var SwapOffset = Gene.FirstGeneByte + 1;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override public function fields() : Array<GeneField> {
        return [
            Fields.byte("rotation", "Rotation", RotationOffset, "128 is neutral"),
            Fields.byte("swap", "Swap", SwapOffset, "128 is neutral")
        ];
    }

    override function getName() : String {
        return 'Pigment bleed Gene';
    }

    override function getTypename() {
        return "PigmentBleed";
    }

    public function get_rotation():Int {
        return getByte(RotationOffset);
    }

    public function get_swap():Int {
        return getByte(SwapOffset);
    }
}
