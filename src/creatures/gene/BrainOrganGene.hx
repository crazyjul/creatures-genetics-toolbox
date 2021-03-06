package creatures.gene;

import haxe.io.Bytes;


class BrainOrganGene extends BrainGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Brain organ Gene';
    }
}