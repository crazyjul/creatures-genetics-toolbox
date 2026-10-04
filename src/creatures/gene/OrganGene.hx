package creatures.gene;

import haxe.io.Bytes;

@:build(JsProp.all())
class OrganGene extends Gene {

    public var clockRate(get, never) : Float;
    public var repairRate(get, never) : Float;
    public var lifeForce(get, never) : Float;
    public var initClock(get, never) : Float;
    public var zeroEnergyDamage(get, never) : Float;

    public var clockRateAsByte(get, never) : Float;
    public var repairRateAsByte(get, never) : Float;
    public var lifeForceAsByte(get, never) : Float;
    public var initClockAsByte(get, never) : Float;
    public var zeroEnergyDamageAsByte(get, never) : Float;


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
        return 'Organ Gene (${clockRate}, ${repairRate}, ${lifeForce}, ${initClock}, ${zeroEnergyDamage})';
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

    public function get_clockRateAsByte() : Int {
        return getByte(ClockRateOffset);
    }

    public function get_repairRateAsByte() : Int {
        return getByte(RepairRateOffset);
    }

    public function get_lifeForceAsByte() : Int {
        return getByte(LifeForceOffset);
    }

    public function get_initClockAsByte() : Int {
        return getByte(InitClockOffset);
    }

    public function get_zeroEnergyDamageAsByte() : Int {
        return getByte(ZeroEnergyDamageOffset);
    }

    override function getTypename() : String {
        return "Organ";
    }
}
