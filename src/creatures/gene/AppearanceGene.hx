package creatures.gene;

import haxe.io.Bytes;

@:build(JsProp.all())
class AppearanceGene extends CreatureGene {

    public var bodyRegion(get, never) : Int;
    public var bodyVariant(get, never) : Int;
    public var genusVariant(get, never) : Int;

    static inline var BodyRegionOffset = Gene.FirstGeneByte;
    static inline var BodyVariantOffset = Gene.FirstGeneByte + 1;
    static inline var GenusVariantOffset = Gene.FirstGeneByte + 2;

    static inline var RegionCount = 6;
    static inline var VariantCount = 26;
    static inline var CreatureGeniCount = 4;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Appearance Gene';
    }

    override function getTypename() {
        return 'Appearance';
    }

    public function get_bodyRegion() : Int {
        return getCodon(BodyRegionOffset, 0, RegionCount - 1);
    }

    public function get_bodyVariant() : Int {
        return getCodon(BodyVariantOffset, 0, VariantCount - 1);
    }

    public function get_genusVariant() : Int {
        return getCodon(GenusVariantOffset, 0, CreatureGeniCount - 1);
    }
}