package creatures.gene;

import haxe.io.Bytes;


class GeneFactory {

    public static function create(bytes : Bytes, offset : Int) : Gene {

        var header = bytes.getString(offset, 4);

        if(header != Constants.GeneHeader) {
            return null;
        }

        var type = bytes.get(offset + Gene.TypeOffset);
        var subtype =  bytes.get(offset + 5);

        switch([type, subtype]) {
            case [GeneType.Brain, BrainType.Lobe] : return new LobeGene(bytes, offset);

            case [GeneType.Brain, BrainType.BrainOrgan] : return new BrainOrganGene(bytes, offset);

            case [GeneType.Brain, BrainType.Tract] : return new TractGene(bytes, offset);

            case [GeneType.Brain, _] : return new BrainGene(bytes, offset);

            case [GeneType.Biochemistry, BiochemistryType.Receptor] : return new ReceptorGene(bytes, offset);

            case [GeneType.Biochemistry, BiochemistryType.Emitter] : return new EmitterGene(bytes, offset);

            case [GeneType.Biochemistry, BiochemistryType.Reaction] : return new ReactionGene(bytes, offset);

            case [GeneType.Biochemistry, BiochemistryType.HalfLife] : return new HalfLifeGene(bytes, offset);

            case [GeneType.Biochemistry, BiochemistryType.Inject] : return new InjectGene(bytes, offset);

            case [GeneType.Biochemistry, BiochemistryType.NeuroEmitter] : return new NeuroEmitterGene(bytes, offset);

            case [GeneType.Biochemistry, _] : return new BiochemistryGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Stimulus] : return new StimulusGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Genus] : return new GenusGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Appearance] : return new AppearanceGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Pose] : return new PoseGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Gait] : return new GaitGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Instinct] : return new InstinctGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Pigment] : return new PigmentGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Pigmentbleed] : return new PigmentbleedGene(bytes, offset);

            case [GeneType.Creature, CreatureType.Expression] : return new ExpressionGene(bytes, offset);

            case [GeneType.Creature, _] : return new CreatureGene(bytes, offset);

            case [GeneType.Organ, _] : return new OrganGene(bytes, offset);
        }

        trace("Specific gene unknown");

        return new Gene(bytes, offset);
    }
}