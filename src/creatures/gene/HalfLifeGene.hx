package creatures.gene;

import haxe.io.Bytes;


class HalfLifeGene extends BiochemistryGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Half-Life Gene';
    }
}