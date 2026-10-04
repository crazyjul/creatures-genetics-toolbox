import utest.Assert;
import utest.Test;

import creatures.Genome;
import creatures.gene.BrainOrganGene;
import creatures.gene.Gene;
import creatures.gene.GaitGene;
import creatures.gene.NeuroEmitterGene;
import creatures.gene.PigmentGene;
import creatures.gene.PigmentbleedGene;
import creatures.gene.PoseGene;

/** Pose, gait, pigment, brain organ and neuro-emitter genes decoded from the sample genome. */
class TestOtherGenes extends Test {
    static inline var FixturePath = "test/data/sample.gen";

    var genome : Genome;

    function setup() {
        #if sys
        if(sys.FileSystem.exists(FixturePath)) {
            genome = new Genome(sys.io.File.getBytes(FixturePath));
        }
        #end
    }

    function find<T : Gene>(cls : Class<T>, id : Int) : T {
        for(g in genome.genes) {
            if(Std.isOfType(g, cls) && g.id == id) {
                return cast g;
            }
        }

        return null;
    }

    function all<T : Gene>(cls : Class<T>) : Array<T> {
        return [for(g in genome.genes) if(Std.isOfType(g, cls)) cast g];
    }

    function testPigments() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.equals(13, all(PigmentGene).length);

        var red = find(PigmentGene, 1);
        Assert.equals(0, red.channel);
        Assert.equals("Red", red.channelName);
        Assert.equals(128, red.amount);
        Assert.equals("Pigment", red.typename);

        Assert.equals("Green", find(PigmentGene, 2).channelName);
        Assert.equals("Blue", find(PigmentGene, 3).channelName);
        Assert.equals(132, find(PigmentGene, 4).amount);
    }

    function testPigmentBleed() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.equals(9, all(PigmentbleedGene).length);

        for(g in all(PigmentbleedGene)) {
            Assert.equals(128, g.rotation);
            Assert.equals(128, g.swap);
            Assert.equals("PigmentBleed", g.typename);
        }
    }

    function testGaits() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.equals(14, all(GaitGene).length);

        var normal = find(GaitGene, 1);
        Assert.equals(0, normal.gait);
        Assert.same([13, 14, 15, 16, 0, 0, 0, 0], normal.poses);

        Assert.same([17, 17, 18, 18, 19, 19, 20, 20], find(GaitGene, 2).poses);
        // "Back off" is gene 11 but gait 10.
        Assert.equals(10, find(GaitGene, 11).gait);
    }

    function testPoses() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.equals(242, all(PoseGene).length);

        var first = find(PoseGene, 1);
        Assert.equals(0, first.poseNumber);
        Assert.equals("??1312312010100X", first.poseString);
        Assert.equals(16, first.parts.length);
        Assert.equals("Direction", first.parts[0].name);
        Assert.equals("?", first.parts[0].code);
        Assert.equals("Body", first.parts[2].name);
        Assert.equals("1", first.parts[2].code);
        Assert.equals("Pose", first.typename);

        Assert.equals("?011121120111XXX", find(PoseGene, 5).poseString);
    }

    function testPoseStringsAreWellFormed() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var valid = ~/^[0-9?!X]{16}$/;

        for(g in all(PoseGene)) {
            Assert.isTrue(valid.match(g.poseString), "pose " + g.id + " '" + g.poseString + "'");
        }
    }

    function testBrainOrgan() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var organ = all(BrainOrganGene)[0];
        Assert.notNull(organ);
        Assert.floatEquals(128 / 255, organ.clockRate);
        Assert.floatEquals(16 / 255, organ.repairRate);
        Assert.floatEquals(1.0, organ.lifeForce);
        Assert.floatEquals(52 / 255, organ.initClock);
        Assert.floatEquals(64 / 255, organ.zeroEnergyDamage);
        Assert.equals("BrainOrgan", organ.typename);
    }

    function testNeuroEmitter() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var emitter = all(NeuroEmitterGene)[0];
        Assert.notNull(emitter);
        Assert.equals("NeuroEmitter", emitter.typename);

        Assert.equals(3, emitter.inputs.length);
        Assert.equals(3, emitter.inputs[0].lobeTissueId);
        Assert.equals(37, emitter.inputs[0].neuron);
        Assert.equals(-1, emitter.inputs[1].lobeTissueId);
        Assert.equals(-1, emitter.inputs[2].lobeTissueId);

        Assert.floatEquals(4 / 255, emitter.bioTickRate);

        Assert.equals(4, emitter.emissions.length);
        Assert.equals(117, emitter.emissions[0].chemical);
        Assert.floatEquals(8 / 255, emitter.emissions[0].amount);
        Assert.equals(158, emitter.emissions[1].chemical);
        Assert.equals(157, emitter.emissions[2].chemical);
        Assert.equals(0, emitter.emissions[3].chemical);
    }
}
