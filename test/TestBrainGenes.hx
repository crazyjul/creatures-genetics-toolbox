import utest.Assert;
import utest.Test;

import creatures.Genome;
import creatures.gene.Gene;
import creatures.gene.InstinctGene;
import creatures.gene.LobeGene;
import creatures.gene.TractGene;

/** Brain genes decoded from the sample genome (a norn, see test/data). */
class TestBrainGenes extends Test {
    static inline var FixturePath = "test/data/sample.gen";

    var genome : Genome;
    var lobes : Array<LobeGene>;
    var tracts : Array<TractGene>;
    var instincts : Array<InstinctGene>;

    function setup() {
        #if sys
        if(!sys.FileSystem.exists(FixturePath)) {
            return;
        }

        genome = new Genome(sys.io.File.getBytes(FixturePath));
        lobes = [for(g in genome.genes) if(Std.isOfType(g, LobeGene)) cast g];
        tracts = [for(g in genome.genes) if(Std.isOfType(g, TractGene)) cast g];
        instincts = [for(g in genome.genes) if(Std.isOfType(g, InstinctGene)) cast g];
        #end
    }

    function lobe(token : String) : LobeGene {
        for(l in lobes) {
            if(l.token == token) {
                return l;
            }
        }

        return null;
    }

    function tract(src : String, dst : String) : TractGene {
        for(t in tracts) {
            if(t.srcLobe == src && t.dstLobe == dst) {
                return t;
            }
        }

        return null;
    }

    function testCounts() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.equals(15, lobes.length);
        Assert.equals(29, tracts.length);
        Assert.equals(30, instincts.length);
    }

    function testLobeHeader() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var drive = lobe("driv");
        Assert.notNull(drive);
        Assert.equals(4, drive.updateTime);
        Assert.equals(30, drive.x);
        Assert.equals(55, drive.y);
        Assert.equals(20, drive.width);
        Assert.equals(1, drive.height);
        Assert.equals(20, drive.neuronCount);
        Assert.same([210, 233, 118], drive.colour);
        Assert.equals(5, drive.tissueId);
        Assert.isFalse(drive.runInitRuleAlways);
        Assert.equals("Lobe", drive.typename);
    }

    function testLobeRunInitRuleAlways() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var combination = lobe("comb");
        Assert.equals(40, combination.width);
        Assert.equals(11, combination.height);
        Assert.isTrue(combination.runInitRuleAlways);
    }

    function testLobesAreSane() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        for(l in lobes) {
            Assert.isTrue(l.neuronCount > 0, "lobe " + l.token + " has neurons");
            Assert.equals(4, l.token.length);
            Assert.isTrue(~/^[a-z]{4}$/.match(l.token), "token '" + l.token + "' is lowercase letters");
        }
    }

    function testTractHeader() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var t = tract("visn", "stim");
        Assert.notNull(t);
        Assert.equals(12, t.updateTime);
        Assert.equals(0, t.srcMin);
        Assert.equals(39, t.srcMax);
        Assert.equals(1, t.srcDendrites);
        Assert.equals(0, t.dstMin);
        Assert.equals(39, t.dstMax);
        Assert.equals(1, t.dstDendrites);
        Assert.equals("Tract", t.typename);
    }

    function testMigratingTract() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var t = tract("driv", "comb");
        Assert.notNull(t);
        Assert.isTrue(t.migrates);
        Assert.isFalse(t.randomDendriteCount);
        Assert.equals(7, t.srcGrowthFactorVariable);
        Assert.equals(2, t.dstGrowthFactorVariable);
        Assert.equals(19, t.srcMax);
        Assert.equals(439, t.dstMax);
    }

    function testTractsConnectKnownLobes() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var tokens = [for(l in lobes) l.token];

        for(t in tracts) {
            Assert.contains(t.srcLobe, tokens, "source of tract " + t.srcLobe + "->" + t.dstLobe);
            Assert.contains(t.dstLobe, tokens, "destination of tract " + t.srcLobe + "->" + t.dstLobe);
        }
    }

    function testSVRulesStopAndAreDescribed() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        for(l in lobes) {
            for(rule in [l.initRule, l.updateRule]) {
                Assert.isTrue(rule.length > 0 && rule.length <= 16);
                Assert.isTrue(rule[rule.length - 1].opCode == 0 || rule.length == 16, "a rule ends with stop or is full");

                for(entry in rule) {
                    Assert.isTrue(entry.text != null && entry.text != "");
                }
            }
        }
    }

    function testInstinct() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var first = instincts[0];
        Assert.equals("Instinct", first.typename);
        Assert.equals(3, first.inputs.length);
        Assert.equals(2, first.inputs[0].lobeTissueId);
        Assert.equals(36, first.inputs[0].neuron);
        Assert.equals(-1, first.inputs[1].lobeTissueId);
        Assert.equals(1, first.action);
        Assert.equals(13, first.drive);
        Assert.floatEquals(-1.0, first.reinforcement);
    }

    function testInstinctsUseExistingLobes() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var tissues = [for(l in lobes) l.tissueId];

        for(i in instincts) {
            for(input in i.inputs) {
                if(input.lobeTissueId != -1) {
                    Assert.contains(input.lobeTissueId, tissues);
                }
            }
        }
    }
}
