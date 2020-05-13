package creatures.gene;

import haxe.io.Bytes;


class BiochemistryGene extends Gene {

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Biochemistry Gene (subtype : ${subtype})';
    }
}