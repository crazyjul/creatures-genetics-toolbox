package creatures.gene;

import haxe.io.Bytes;

/**
 * Sets the redness, greenness or blueness of the skin. Not read by the Creatures 4 engine,
 * but present in Creatures 3 genomes: one byte for the channel (0 red, 1 green, 2 blue)
 * and one for the amount (128 is neutral).
 */
@:build(JsProp.all())
class PigmentGene extends CreatureGene {

    public var channel(get, never):Int;
    public var channelName(get, never):String;
    public var amount(get, never):Int;

    static inline var ChannelOffset = Gene.FirstGeneByte;
    static inline var AmountOffset = Gene.FirstGeneByte + 1;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Pigment Gene';
    }

    override function getTypename() {
        return "Pigment";
    }

    public function get_channel():Int {
        return getCodon(ChannelOffset, 0, 2);
    }

    public function get_channelName():String {
        return switch(channel) {
            case 0: "Red";
            case 1: "Green";
            default: "Blue";
        }
    }

    public function get_amount():Int {
        return getByte(AmountOffset);
    }
}
