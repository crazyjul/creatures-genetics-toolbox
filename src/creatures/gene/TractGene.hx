package creatures.gene;

import haxe.io.Bytes;


@:build(JsProp.all())
class TractGene extends BrainGene {

    public var updateTime(get, never):Int;
    public var srcLobe(get, never):String;
    public var srcMin(get, never):Int;
    public var srcMax(get, never):Int;
    public var srcDendrites(get, never):Int;
    public var dstLobe(get, never):String;
    public var dstMin(get, never):Int;
    public var dstMax(get, never):Int;
    public var dstDendrites(get, never):Int;
    public var migrates(get, never):Bool;
    public var randomDendriteCount(get, never):Bool;
    public var srcGrowthFactorVariable(get, never):Int;
    public var dstGrowthFactorVariable(get, never):Int;
    public var runInitRuleAlways(get, never):Bool;
    public var initRule(get, never):Array<SVRuleEntry>;
    public var updateRule(get, never):Array<SVRuleEntry>;

    static inline var UpdateTimeOffset = Gene.FirstGeneByte;
    static inline var SrcLobeOffset = Gene.FirstGeneByte + 2;
    static inline var SrcMinOffset = Gene.FirstGeneByte + 6;
    static inline var SrcMaxOffset = Gene.FirstGeneByte + 8;
    static inline var SrcDendritesOffset = Gene.FirstGeneByte + 10;
    static inline var DstLobeOffset = Gene.FirstGeneByte + 12;
    static inline var DstMinOffset = Gene.FirstGeneByte + 16;
    static inline var DstMaxOffset = Gene.FirstGeneByte + 18;
    static inline var DstDendritesOffset = Gene.FirstGeneByte + 20;
    static inline var MigratesOffset = Gene.FirstGeneByte + 22;
    static inline var RandomDendriteCountOffset = Gene.FirstGeneByte + 23;
    static inline var SrcGrowthFactorOffset = Gene.FirstGeneByte + 24;
    static inline var DstGrowthFactorOffset = Gene.FirstGeneByte + 25;
    static inline var RunInitRuleAlwaysOffset = Gene.FirstGeneByte + 26;
    // A spare byte and a spare token follow.
    static inline var InitRuleOffset = Gene.FirstGeneByte + 32;
    static inline var UpdateRuleOffset = InitRuleOffset + SVRule.ByteSize;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Tract Gene (' + srcLobe + ' -> ' + dstLobe + ')';
    }

    override function getTypename() {
        return "Tract";
    }

    public function get_updateTime():Int {
        return getInt(UpdateTimeOffset);
    }

    public function get_srcLobe():String {
        return getToken(SrcLobeOffset);
    }

    public function get_srcMin():Int {
        return getInt(SrcMinOffset);
    }

    public function get_srcMax():Int {
        return getInt(SrcMaxOffset);
    }

    public function get_srcDendrites():Int {
        return getInt(SrcDendritesOffset);
    }

    public function get_dstLobe():String {
        return getToken(DstLobeOffset);
    }

    public function get_dstMin():Int {
        return getInt(DstMinOffset);
    }

    public function get_dstMax():Int {
        return getInt(DstMaxOffset);
    }

    public function get_dstDendrites():Int {
        return getInt(DstDendritesOffset);
    }

    public function get_migrates():Bool {
        return getBool(MigratesOffset);
    }

    public function get_randomDendriteCount():Bool {
        return getBool(RandomDendriteCountOffset);
    }

    public function get_srcGrowthFactorVariable():Int {
        return getCodon(SrcGrowthFactorOffset, 0, 7);
    }

    public function get_dstGrowthFactorVariable():Int {
        return getCodon(DstGrowthFactorOffset, 0, 7);
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
