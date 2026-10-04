package creatures.gene;

import haxe.io.Bytes;

typedef PosePart = {
    var name : String;
    /** One character: a digit selects the pose of that body part, '?' leaves it unchanged, 'X' means none. */
    var code : String;
}

/**
 * Defines a pose: a pose number, then a 16 character string with one character per body part.
 * The part order is the engine's (SkeletonConstants.h: direction, head, body, thighs, shins,
 * feet, humeri, radii, tail root, tail tip); the last character is spare. Not read by the
 * Creatures 4 engine, decoded from Creatures 3 genomes.
 */
@:build(JsProp.all())
class PoseGene extends CreatureGene {

    public var poseNumber(get, never):Int;
    public var poseString(get, never):String;
    public var parts(get, never):Array<PosePart>;

    static inline var PoseNumberOffset = Gene.FirstGeneByte;
    static inline var PoseStringOffset = Gene.FirstGeneByte + 1;
    static inline var PoseStringLength = 16;

    static var PartNames = [
        "Direction", "Head", "Body",
        "Left thigh", "Left shin", "Left foot",
        "Right thigh", "Right shin", "Right foot",
        "Left humerus", "Left radius", "Right humerus", "Right radius",
        "Tail root", "Tail tip", "Spare"
    ];

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Pose Gene';
    }

    override function getTypename() {
        return "Pose";
    }

    public function get_poseNumber():Int {
        return getByte(PoseNumberOffset);
    }

    public function get_poseString():String {
        return getRawString(PoseStringOffset, PoseStringLength);
    }

    public function get_parts():Array<PosePart> {
        var text = poseString;

        return [for(i in 0...PoseStringLength) { name : PartNames[i], code : text.charAt(i) }];
    }
}
