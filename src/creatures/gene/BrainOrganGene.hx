package creatures.gene;

import haxe.io.Bytes;

/**
 * Configures the characteristics of the brain's organ ("configure its organ characteristics" in the engine).
 * No reader was found, but the five bytes have the same shape as an organ gene's, so they are decoded alike.
 */
@:build(JsProp.all())
class BrainOrganGene extends BrainGene {

    public var clockRate(get, never) : Float;
    public var repairRate(get, never) : Float;
    public var lifeForce(get, never) : Float;
    public var initClock(get, never) : Float;
    public var zeroEnergyDamage(get, never) : Float;

    static inline var ClockRateOffset = Gene.FirstGeneByte;
    static inline var RepairRateOffset = Gene.FirstGeneByte + 1;
    static inline var LifeForceOffset = Gene.FirstGeneByte + 2;
    static inline var InitClockOffset = Gene.FirstGeneByte + 3;
    static inline var ZeroEnergyDamageOffset = Gene.FirstGeneByte + 4;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override public function fields() : Array<GeneField> {
        return [
            Fields.float("clockRate", "Clock rate", ClockRateOffset),
            Fields.float("repairRate", "Repair rate", RepairRateOffset),
            Fields.float("lifeForce", "Life force", LifeForceOffset),
            Fields.float("initClock", "Initial clock", InitClockOffset),
            Fields.float("zeroEnergyDamage", "Zero energy damage", ZeroEnergyDamageOffset)
        ];
    }

    override function getName() : String {
        return 'Brain organ Gene';
    }

    override function getTypename() {
        return "BrainOrgan";
    }

    public function get_clockRate() : Float {
        return getFloat(ClockRateOffset);
    }

    public function get_repairRate() : Float {
        return getFloat(RepairRateOffset);
    }

    public function get_lifeForce() : Float {
        return getFloat(LifeForceOffset);
    }

    public function get_initClock() : Float {
        return getFloat(InitClockOffset);
    }

    public function get_zeroEnergyDamage() : Float {
        return getFloat(ZeroEnergyDamageOffset);
    }
}
