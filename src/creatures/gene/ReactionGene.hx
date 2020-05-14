package creatures.gene;

import haxe.io.Bytes;


class ReactionGene extends BiochemistryGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Reaction Emitter Gene';
    }
}