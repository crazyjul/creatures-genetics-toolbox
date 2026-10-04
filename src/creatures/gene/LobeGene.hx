package creatures.gene;

import haxe.io.Bytes;


@:build(JsProp.all())
class LobeGene extends BrainGene {

    public var token(get, never):String;
    public var updateTime(get, never):Int;
    public var x(get, never):Int;
    public var y(get, never):Int;
    public var width(get, never):Int;
    public var height(get, never):Int;
    public var neuronCount(get, never):Int;
    public var colour(get, never):Array<Int>;
    public var tissueId(get, never):Int;
    public var runInitRuleAlways(get, never):Bool;
    public var initRule(get, never):Array<SVRuleEntry>;
    public var updateRule(get, never):Array<SVRuleEntry>;

    static inline var TokenOffset = Gene.FirstGeneByte;
    static inline var UpdateTimeOffset = Gene.FirstGeneByte + 4;
    static inline var XOffset = Gene.FirstGeneByte + 6;
    static inline var YOffset = Gene.FirstGeneByte + 8;
    static inline var WidthOffset = Gene.FirstGeneByte + 10;
    static inline var HeightOffset = Gene.FirstGeneByte + 11;
    static inline var ColourOffset = Gene.FirstGeneByte + 12;
    // The byte after the colour is the "winner takes all" flag, which the engine ignores.
    static inline var TissueIdOffset = Gene.FirstGeneByte + 16;
    static inline var RunInitRuleAlwaysOffset = Gene.FirstGeneByte + 17;
    // Seven spare bytes follow.
    static inline var InitRuleOffset = Gene.FirstGeneByte + 25;
    static inline var UpdateRuleOffset = InitRuleOffset + SVRule.ByteSize;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override public function fields() : Array<GeneField> {
        return [
            Fields.text("token", "Token", TokenOffset, 4, "four characters naming the lobe"),
            Fields.int16("updateTime", "Update time", UpdateTimeOffset, "0 means never updated"),
            Fields.int16("x", "Position x", XOffset),
            Fields.int16("y", "Position y", YOffset),
            Fields.byte("width", "Width", WidthOffset, "neurons across"),
            Fields.byte("height", "Height", HeightOffset, "neurons down"),
            Fields.byte("red", "Red", ColourOffset),
            Fields.byte("green", "Green", ColourOffset + 1),
            Fields.byte("blue", "Blue", ColourOffset + 2),
            Fields.byte("tissueId", "Tissue id", TissueIdOffset, "255 means no tissue"),
            Fields.bit("runInitRuleAlways", "Run the init rule every update", RunInitRuleAlwaysOffset, 1)
        ];
    }

    override function getName() : String {
        return 'Lobe Gene (' + token + ')';
    }

    override function getTypename() {
        return "Lobe";
    }

    public function get_token():String {
        return getToken(TokenOffset);
    }

    public function get_updateTime():Int {
        return getInt(UpdateTimeOffset);
    }

    public function get_x():Int {
        return getInt(XOffset);
    }

    public function get_y():Int {
        return getInt(YOffset);
    }

    public function get_width():Int {
        return getByte(WidthOffset);
    }

    public function get_height():Int {
        return getByte(HeightOffset);
    }

    public function get_neuronCount():Int {
        return width * height;
    }

    public function get_colour():Array<Int> {
        return [getByte(ColourOffset), getByte(ColourOffset + 1), getByte(ColourOffset + 2)];
    }

    public function get_tissueId():Int {
        return getByte(TissueIdOffset);
    }

    public function get_runInitRuleAlways():Bool {
        return getCodon(RunInitRuleAlwaysOffset, 0, 1) > 0;
    }

    public function get_initRule():Array<SVRuleEntry> {
        return getSVRule(InitRuleOffset);
    }

    public function get_updateRule():Array<SVRuleEntry> {
        return getSVRule(UpdateRuleOffset);
    }
}
