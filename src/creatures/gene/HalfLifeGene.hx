package creatures.gene;

import haxe.io.Bytes;

@:build(JsProp.all())
class HalfLifeGene extends BiochemistryGene {

    public var decayRates(get, never) : Array<Float>;

    var _decayRates : Array<Float>;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Half-Life Gene';
    }

    override function getTypename() {
        return "HalfLife";
    }

    function get_decayRates():  Array<Float> {
        if(_decayRates == null) {
            _decayRates = [];

            for(i in 0...256) {
                _decayRates[ i ] = getFloat(Gene.FirstGeneByte + i) * 32.0;
            }
        }

        return _decayRates;
    }
}