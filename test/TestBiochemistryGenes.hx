import utest.Assert;
import utest.Test;

import creatures.Genome;
import creatures.gene.EmitterGene;
import creatures.gene.Gene;
import creatures.gene.HalfLifeGene;
import creatures.gene.ReactionGene;
import creatures.gene.ReceptorGene;

/** Reactions, half lives, receptors and emitters decoded from the sample genome. */
class TestBiochemistryGenes extends Test {
    static inline var FixturePath = "test/data/sample.gen";

    var genome : Genome;

    function setup() {
        #if sys
        if(sys.FileSystem.exists(FixturePath)) {
            genome = new Genome(sys.io.File.getBytes(FixturePath));
        }
        #end
    }

    function all<T : Gene>(cls : Class<T>) : Array<T> {
        return [for(g in genome.genes) if(Std.isOfType(g, cls)) cast g];
    }

    function reaction(id : Int) : ReactionGene {
        for(r in all(ReactionGene)) {
            if(r.id == id) {
                return r;
            }
        }

        return null;
    }

    function testSimpleReaction() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        // "protein to amino acid": 1 x chemical 12 -> 4 x chemical 13
        var r = reaction(24);
        Assert.notNull(r);
        Assert.equals(1, r.reactants.length);
        Assert.equals(12, r.reactants[0].chemical);
        Assert.equals(1, r.reactants[0].proportion);
        Assert.equals(1, r.products.length);
        Assert.equals(13, r.products[0].chemical);
        Assert.equals(4, r.products[0].proportion);
        Assert.equals("1 x chem 12 -> 4 x chem 13", r.equation);
        Assert.equals("Reaction", r.typename);
    }

    function testReactionWithTwoReactants() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var r = reaction(55);
        Assert.equals(2, r.reactants.length);
        Assert.equals(112, r.reactants[0].chemical);
        Assert.equals(13, r.reactants[1].chemical);
        Assert.equals(4, r.reactants[1].proportion);
        Assert.equals(1, r.products.length);
        Assert.equals(11, r.products[0].chemical);
    }

    function testReactionRate() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var r = reaction(24);
        // The rate byte is 54: the engine stores 1 - 54/255 as the speed.
        Assert.floatEquals(1.0 - 54 / 255, r.speed);
        Assert.floatEquals(Math.pow(2.2, 54 / 255 * 32.0), r.halfLifeTicks);
    }

    function testAllReactionsAreWellFormed() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.equals(101, all(ReactionGene).length);

        for(r in all(ReactionGene)) {
            for(term in r.reactants.concat(r.products)) {
                Assert.isTrue(term.proportion >= 1 && term.proportion <= 16);
                Assert.isTrue(term.chemical > 0 && term.chemical < 256);
            }

            Assert.isTrue(r.speed >= 0 && r.speed <= 1);
            Assert.isTrue(r.halfLifeTicks >= 1);
        }
    }

    function testHalfLives() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = all(HalfLifeGene)[0];
        Assert.equals(256, gene.decayRates.length);
        Assert.equals(256, gene.halfLives.length);

        for(i in 0...256) {
            if(gene.decayRates[i] == 0) {
                Assert.equals(0.0, gene.halfLives[i]);
            } else {
                Assert.floatEquals(Math.pow(2.2, gene.decayRates[i]), gene.halfLives[i]);
            }
        }
    }

    function testReceptorFlags() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        for(r in all(ReceptorGene)) {
            Assert.equals(untyped (r.effect & 1) != 0, r.reduces);
            Assert.equals(untyped (r.effect & 2) != 0, r.digital);
        }
    }

    function testEmitterFlags() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var emitters = all(EmitterGene);
        Assert.equals(43, emitters.length);

        for(e in emitters) {
            Assert.equals((e.effect & 1) != 0, e.removes);
            Assert.equals((e.effect & 2) != 0, e.digital);
            Assert.equals((e.effect & 4) != 0, e.inverts);
        }
    }
}
