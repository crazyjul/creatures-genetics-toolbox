package creatures.gene;

import haxe.io.Bytes;


class StimulusGene extends CreatureGene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Stimulus Gene';
    }
}