package creatures.gene;

import haxe.io.Bytes;


class BrainGene extends Gene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Brain Gene (subtype : ${subtype})';
    }
}