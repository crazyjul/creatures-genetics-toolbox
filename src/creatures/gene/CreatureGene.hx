package creatures.gene;

import haxe.io.Bytes;


class CreatureGene extends Gene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Creature Gene (subtype : ${subtype})';
    }
}