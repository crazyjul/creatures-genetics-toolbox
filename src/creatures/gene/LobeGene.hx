package creatures.gene;

import haxe.io.Bytes;


class LobeGene extends BrainGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Lobe Gene';
    }
}