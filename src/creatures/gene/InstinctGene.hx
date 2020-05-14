package creatures.gene;

import haxe.io.Bytes;


class InstinctGene extends CreatureGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Instinct Gene';
    }
}