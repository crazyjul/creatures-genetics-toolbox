package creatures.gene;

import haxe.io.Bytes;

@:build(JsProp.all())
class ExpressionGene extends CreatureGene {

    public var expressionId(get, never) : Int;
    public var weight(get, never) : Float;
    public var drives(get, never): Array<Int>;
    public var driveWeights(get, never) : Array<Float>;

    var _drives : Array<Int>;
    var _driveWeights : Array<Float>;

    static inline var ExpressionOffset = Gene.FirstGeneByte;
    static inline var WeightOffset = Gene.FirstGeneByte + 2;
    static inline var DriveWeightsOffset = Gene.FirstGeneByte + 3;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Expression Gene';
    }

    override function getTypename()  {
        return "Expression";
    }

    function get_expressionId() : Int {
        return getCodon(ExpressionOffset, 0, Constants.ExpressionCount - 1);
    }

    function get_weight() : Float {
        return getFloat(WeightOffset);
    }

    function get_drives(): Array<Int> {
        if(_drives == null) {
            loadCache();
        }

        return _drives;
    }

    function get_driveWeights() : Array<Float> {
        if(_driveWeights == null) {
            loadCache();
        }

        return _driveWeights;
    }

    function loadCache() {
        _drives = [];
        _driveWeights = [];

        for(i in 0...4) {
            _drives[i] = getByte(DriveWeightsOffset + 2 * i);
            _driveWeights[i] = getSignedFloat(DriveWeightsOffset + 2 * i + 1);
        }
    }
}
