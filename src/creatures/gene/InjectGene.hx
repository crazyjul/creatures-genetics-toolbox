package creatures.gene;

import haxe.io.Bytes;


@:build(JsProp.all())
class InjectGene extends BiochemistryGene {

    public var chemical(get, never) : Int;
    public var initialConcentration(get, never): Float;

    static inline var ChemicalOffset = Gene.FirstGeneByte;
    static inline var InitialConcentrationOffset = Gene.FirstGeneByte + 1;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override public function fields() : Array<GeneField> {
        return [
            Fields.chemical("chemical", "Chemical", ChemicalOffset),
            Fields.float("initialConcentration", "Initial concentration", InitialConcentrationOffset)
        ];
    }

    override function getName() : String {
        return 'Inject Emitter Gene';
    }

    override function getTypename() {
        return "Inject";
    }


    public function get_chemical() : Int {
        return getByte(ChemicalOffset);
    }

    public function get_initialConcentration(): Float {
        return getFloat(InitialConcentrationOffset);
    }

}