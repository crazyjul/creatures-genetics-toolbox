import utest.Assert;
import utest.Test;

import creatures.ChemicalUsage;
import creatures.Genome;

class TestChemicalUsage extends Test {
    static inline var FixturePath = "test/data/sample.gen";

    #if sys
    function usage() {
        var genome = new Genome(sys.io.File.getBytes(FixturePath));

        return ChemicalUsage.collect(genome.genes);
    }

    function roles(uses : Array<creatures.ChemicalUsage.ChemicalUse>) : Array<String> {
        return uses.map(function(u) return u.role);
    }

    function testProteinIsAReactantAndAnAminoAcidSource() {
        if(!sys.FileSystem.exists(FixturePath)) {
            Assert.pass("No fixture");
            return;
        }

        var u = usage();

        // Protein (12) is digested into amino acid (13).
        Assert.contains("reactant", roles(u[12]));
        Assert.contains("product", roles(u[13]));
    }

    function testDriveChemicalsHaveReceptors() {
        if(!sys.FileSystem.exists(FixturePath)) {
            Assert.pass("No fixture");
            return;
        }

        // Pain (148) is read by the first drive receptor.
        Assert.contains("receptor", roles(usage()[148]));
    }

    function testEveryUseCarriesItsGeneAndPosition() {
        if(!sys.FileSystem.exists(FixturePath)) {
            Assert.pass("No fixture");
            return;
        }

        var genome = new Genome(sys.io.File.getBytes(FixturePath));
        var u = ChemicalUsage.collect(genome.genes);

        for(chemical in u.keys()) {
            Assert.isTrue(chemical > 0 && chemical < 256);

            for(use in u[chemical]) {
                Assert.isTrue(genome.genes[use.index] == use.gene);
            }
        }
    }

    function testChemicalZeroIsNeverUsed() {
        if(!sys.FileSystem.exists(FixturePath)) {
            Assert.pass("No fixture");
            return;
        }

        Assert.isFalse(usage().exists(0));
    }

    function testRolesAreAmongTheKnownOnes() {
        if(!sys.FileSystem.exists(FixturePath)) {
            Assert.pass("No fixture");
            return;
        }

        var known = ["reactant", "product", "receptor", "emitter", "inject", "neuro emitter", "stimulus"];
        var u = usage();

        for(chemical in u.keys()) {
            for(use in u[chemical]) {
                Assert.contains(use.role, known);
            }
        }
    }
    #end
}
