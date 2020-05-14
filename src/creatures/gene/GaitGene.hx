package creatures.gene;

import haxe.io.Bytes;


class GaitGene extends CreatureGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Gait Gene';
    }
}