package creatures.gene;

import haxe.io.Bytes;


class ExpressionGene extends CreatureGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Expression Gene';
    }
}