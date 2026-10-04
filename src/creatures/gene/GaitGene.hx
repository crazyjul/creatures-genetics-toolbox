package creatures.gene;

import haxe.io.Bytes;

/**
 * Defines a walking gait: the gait number, then up to eight pose numbers played in turn.
 * Not read by the Creatures 4 engine; decoded from Creatures 3 genomes. Unused poses are 0.
 */
@:build(JsProp.all())
class GaitGene extends CreatureGene {

    public var gait(get, never):Int;
    public var poses(get, never):Array<Int>;

    static inline var GaitOffset = Gene.FirstGeneByte;
    static inline var PosesOffset = Gene.FirstGeneByte + 1;
    static inline var PoseCount = 8;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Gait Gene';
    }

    override function getTypename() {
        return "Gait";
    }

    public function get_gait():Int {
        return getByte(GaitOffset);
    }

    public function get_poses():Array<Int> {
        return [for(i in 0...PoseCount) getByte(PosesOffset + i)];
    }
}
