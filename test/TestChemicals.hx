import utest.Assert;
import utest.Test;

import creatures.Chemicals;
import creatures.Genome;
import creatures.gene.ReactionGene;
import creatures.gene.ReceptorGene;

class TestChemicals extends Test {
    static inline var FixturePath = "test/data/sample.gen";

    function testKnownNames() {
        Assert.equals("Protein", Chemicals.name(12));
        Assert.equals("Amino acid", Chemicals.name(13));
        Assert.equals("ATP", Chemicals.name(35));
        Assert.equals("Pain", Chemicals.name(148));
        Assert.equals("REM", Chemicals.name(213));
        Assert.equals("Protein (12)", Chemicals.label(12));
    }

    function testUnknownAndNone() {
        // Chemicals the game does not list are "unknownase".
        Assert.equals("Unknownase", Chemicals.name(14));
        Assert.equals("Unknownase", Chemicals.name(255));
        Assert.isFalse(Chemicals.isKnown(14));
        Assert.equals("none", Chemicals.name(0));
        Assert.equals("none", Chemicals.label(0));
    }

    function testTableSize() {
        Assert.equals(152, Chemicals.knownCount());
    }

    #if sys
    function testReactionsUseKnownChemicals() {
        if(!sys.FileSystem.exists(FixturePath)) {
            Assert.pass("No fixture");
            return;
        }

        var genome = new Genome(sys.io.File.getBytes(FixturePath));

        // "protein to amino acid" reads as protein -> amino acid.
        for(g in genome.genes) {
            if(Std.isOfType(g, ReactionGene) && g.id == 24) {
                var r : ReactionGene = cast g;
                Assert.equals("Protein", Chemicals.name(r.reactants[0].chemical));
                Assert.equals("Amino acid", Chemicals.name(r.products[0].chemical));
            }
        }
    }

    function testDriveReceptorsListenToDriveChemicals() {
        if(!sys.FileSystem.exists(FixturePath)) {
            Assert.pass("No fixture");
            return;
        }

        var genome = new Genome(sys.io.File.getBytes(FixturePath));

        // The first receptor ("drive 1") listens to the pain chemical.
        for(g in genome.genes) {
            if(Std.isOfType(g, ReceptorGene)) {
                Assert.equals("Pain", Chemicals.name(cast(g, ReceptorGene).chemical));
                break;
            }
        }
    }
    #end
}
