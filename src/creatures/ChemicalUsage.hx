package creatures;

import creatures.gene.EmitterGene;
import creatures.gene.Gene;
import creatures.gene.InjectGene;
import creatures.gene.NeuroEmitterGene;
import creatures.gene.ReactionGene;
import creatures.gene.ReceptorGene;
import creatures.gene.StimulusGene;

typedef ChemicalUse = {
    var gene : Gene;
    /** Position of the gene in the genome. */
    var index : Int;
    /** How the gene uses the chemical: reactant, product, receptor, emitter, inject, neuro emitter or stimulus. */
    var role : String;
}

/**
 * Which genes mention which chemicals. Half-life genes describe every chemical, so they are left out.
 */
class ChemicalUsage {
    public static function collect(genes : Array<Gene>) : Map<Int, Array<ChemicalUse>> {
        var usage = new Map<Int, Array<ChemicalUse>>();

        function add(chemical : Int, index : Int, gene : Gene, role : String) {
            if(chemical == 0) {
                return;
            }

            if(!usage.exists(chemical)) {
                usage[chemical] = [];
            }

            usage[chemical].push({ gene : gene, index : index, role : role });
        }

        for(i in 0...genes.length) {
            var gene = genes[i];

            if(Std.isOfType(gene, ReactionGene)) {
                var reaction : ReactionGene = cast gene;

                for(term in reaction.reactants) {
                    add(term.chemical, i, gene, "reactant");
                }

                for(term in reaction.products) {
                    add(term.chemical, i, gene, "product");
                }
            } else if(Std.isOfType(gene, ReceptorGene)) {
                add(cast(gene, ReceptorGene).chemical, i, gene, "receptor");
            } else if(Std.isOfType(gene, EmitterGene)) {
                add(cast(gene, EmitterGene).chemical, i, gene, "emitter");
            } else if(Std.isOfType(gene, InjectGene)) {
                add(cast(gene, InjectGene).chemical, i, gene, "inject");
            } else if(Std.isOfType(gene, NeuroEmitterGene)) {
                for(emission in cast(gene, NeuroEmitterGene).emissions) {
                    add(emission.chemical, i, gene, "neuro emitter");
                }
            } else if(Std.isOfType(gene, StimulusGene)) {
                for(chemical in cast(gene, StimulusGene).chemicals) {
                    add(chemical, i, gene, "stimulus");
                }
            }
        }

        return usage;
    }
}
