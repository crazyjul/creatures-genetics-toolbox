import haxe.io.Bytes;
import utest.Assert;
import utest.Test;

import creatures.Genome;
import creatures.gene.Age;
import creatures.gene.Gene;
import creatures.gene.GeneField;
import creatures.gene.InstinctGene;
import creatures.gene.LobeGene;
import creatures.gene.ReactionGene;
import creatures.gene.ReceptorGene;
import creatures.gene.SexActivation;

/** Writing to genes and to the genome, against the sample genome (see test/data). */
class TestEditing extends Test {
    static inline var FixturePath = "test/data/sample.gen";

    var bytes : Bytes;
    var genome : Genome;

    function setup() {
        #if sys
        if(sys.FileSystem.exists(FixturePath)) {
            bytes = sys.io.File.getBytes(FixturePath);
            genome = new Genome(bytes);
        }
        #end
    }

    /** The first receptor ("drive 1"): flags 7, mutability 128. */
    function receptor() : ReceptorGene {
        return cast genome.genes[2];
    }

    function find<T : Gene>(cls : Class<T>, id : Int) : T {
        for(g in genome.genes) {
            if(Std.isOfType(g, cls) && g.id == id) {
                return cast g;
            }
        }

        return null;
    }

    function field(gene : Gene, name : String) : GeneField {
        for(f in gene.fields()) {
            if(f.name == name) {
                return f;
            }
        }

        return null;
    }

    // ---------- header ----------

    function testFlagsAreReadFromTheHeader() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var flags = receptor().flags;
        Assert.equals(3, flags.length);
        Assert.isTrue(receptor().hasFlag(CanBeMutated));
        Assert.isTrue(receptor().hasFlag(CanBeDuplicated));
        Assert.isTrue(receptor().hasFlag(CanBeCut));
        Assert.isFalse(receptor().hasFlag(Ignored));
    }

    function testAddingAndRemovingFlags() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        gene.removeFlag(CanBeDuplicated);
        Assert.isFalse(gene.hasFlag(CanBeDuplicated));
        Assert.equals(2, gene.flags.length);
        // Mutable (1) and cut (4) remain.
        Assert.equals(5, bytes.get(genome.offsetOf(2) + 9));

        gene.addFlag(CanBeDuplicated);
        Assert.equals(7, bytes.get(genome.offsetOf(2) + 9));

        // Adding a flag twice changes nothing.
        gene.addFlag(CanBeDuplicated);
        Assert.equals(7, bytes.get(genome.offsetOf(2) + 9));
    }

    function testAge() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        var expected = [Age.Embryo => 0, Age.Child => 1, Age.Adolescent => 2, Age.Youth => 3, Age.Adult => 4, Age.Old => 5, Age.Senile => 6];

        for(age in expected.keys()) {
            gene.age = age;
            Assert.equals(expected[age], bytes.get(genome.offsetOf(2) + 8));
            Assert.equals(age, gene.age);
        }
    }

    function testSexKeepsTheOtherFlags() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        var at = genome.offsetOf(2) + 9;

        gene.sex = Male;
        Assert.equals(7 | 8, bytes.get(at));
        Assert.equals(Male, gene.sex);

        gene.sex = Female;
        Assert.equals(7 | 16, bytes.get(at));
        Assert.equals(Female, gene.sex);

        gene.sex = Both;
        Assert.equals(7, bytes.get(at));
        Assert.equals(Both, gene.sex);
    }

    function testMutabilityIsClamped() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        gene.mutability = 200;
        Assert.equals(200, gene.mutability);

        gene.mutability = 999;
        Assert.equals(255, gene.mutability);

        gene.mutability = -5;
        Assert.equals(0, gene.mutability);
    }

    // ---------- fields ----------

    function testFloatFieldsRoundToABytes() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        gene.setFieldValue(field(gene, "threshold"), 0.5);
        // 0.5 of 255 is 127.5, which rounds up.
        Assert.equals(128, bytes.get(genome.offsetOf(2) + 16));
        Assert.floatEquals(128 / 255, gene.threshold);

        gene.setFieldValue(field(gene, "threshold"), 7.0);
        Assert.floatEquals(1.0, gene.threshold);
    }

    function testCodonFieldsStayInRange() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        gene.setFieldValue(field(gene, "organId"), 9);
        Assert.equals(3, gene.organId);
        gene.setFieldValue(field(gene, "organId"), -2);
        Assert.equals(0, gene.organId);
    }

    function testBitFields() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        var at = genome.offsetOf(2) + 19;
        var before = bytes.get(at);

        gene.setFieldValue(field(gene, "reduces"), true);
        Assert.isTrue(gene.reduces);
        Assert.equals(before | 1, bytes.get(at));

        gene.setFieldValue(field(gene, "digital"), true);
        Assert.isTrue(gene.digital);
        Assert.isTrue(gene.reduces);

        gene.setFieldValue(field(gene, "reduces"), false);
        Assert.isFalse(gene.reduces);
        Assert.isTrue(gene.digital);
    }

    function testChemicalFieldChangesTheEquation() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var reaction = find(ReactionGene, 24);
        Assert.equals("1 x Protein -> 4 x Amino acid", reaction.equation);

        // The first reactant becomes amino acid (13) instead of protein (12).
        reaction.setFieldValue(field(reaction, "chemical0"), 13);
        Assert.equals("1 x Amino acid -> 4 x Amino acid", reaction.equation);

        reaction.setFieldValue(field(reaction, "proportion2"), 99);
        Assert.equals(16, reaction.products[0].proportion);
    }

    function testTextFieldsArePadded() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var lobe : LobeGene = null;

        for(g in genome.genes) {
            if(Std.isOfType(g, LobeGene)) {
                lobe = cast g;
                break;
            }
        }

        lobe.setFieldValue(field(lobe, "token"), "ab");
        Assert.equals("ab  ", lobe.token);

        lobe.setFieldValue(field(lobe, "token"), "abcdefg");
        Assert.equals("abcd", lobe.token);
    }

    function testInt16FieldsAreBigEndian() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var lobe : LobeGene = cast genome.genes.filter(function(g) return Std.isOfType(g, LobeGene))[0];
        var at = genome.offsetOf(genome.genes.indexOf(lobe)) + 18;

        lobe.setFieldValue(field(lobe, "x"), 0x1234);
        Assert.equals(0x12, bytes.get(at));
        Assert.equals(0x34, bytes.get(at + 1));
        Assert.equals(0x1234, lobe.x);

        lobe.setFieldValue(field(lobe, "x"), 70000);
        Assert.equals(65535, lobe.x);
    }

    function testSignedFloatFieldsSpanMinusOneToOne() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var instinct : InstinctGene = null;

        for(g in genome.genes) {
            if(Std.isOfType(g, InstinctGene)) {
                instinct = cast g;
                break;
            }
        }

        var f = field(instinct, "reinforcement");
        instinct.setFieldValue(f, 0.0);
        Assert.floatEquals(0.0, instinct.reinforcement);
        instinct.setFieldValue(f, 1.0);
        Assert.floatEquals(1.0, instinct.reinforcement);
        instinct.setFieldValue(f, -1.0);
        Assert.floatEquals(-1.0, instinct.reinforcement);
        instinct.setFieldValue(f, 5.0);
        Assert.floatEquals(1.0, instinct.reinforcement);
    }

    function testEveryFieldOfEveryGeneSurvivesAReadThenWrite() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var exact = ["byte", "chemical", "int16", "float", "text", "bit"];
        var checked = 0;

        for(g in genome.genes) {
            for(f in g.fields()) {
                var value = g.getFieldValue(f);
                var before = [for(i in 0...f.length) bytes.get(genome.offsetOf(genome.genes.indexOf(g)) + f.offset + i)];

                g.setFieldValue(f, value);

                var after = [for(i in 0...f.length) bytes.get(genome.offsetOf(genome.genes.indexOf(g)) + f.offset + i)];
                var again = g.getFieldValue(f);

                if(Std.isOfType(value, Float)) {
                    Assert.floatEquals(value, again);
                } else {
                    Assert.equals(value, again);
                }

                if(exact.indexOf(f.kind) != -1) {
                    Assert.same(before, after, g.typename + "." + f.name);
                }

                ++checked;
            }
        }

        Assert.isTrue(checked > 3000);
    }

    function testEveryGeneKindListsItsFields() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        // Only half lives and genus names (monikers) are left to the raw byte editor.
        var withoutFields = new Map<String, Bool>();

        for(g in genome.genes) {
            if(g.fields().length == 0) {
                withoutFields[g.typename] = true;
            }
        }

        var names = [for(k in withoutFields.keys()) k];
        names.sort(Reflect.compare);
        Assert.same(["HalfLife"], names);
    }

    // ---------- bytes ----------

    function testGenesKnowTheirSize() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.equals(133, genome.genes.filter(function(g) return Std.isOfType(g, LobeGene))[0].byteLength);
        Assert.equals(21, genome.genes.filter(function(g) return Std.isOfType(g, InstinctGene))[0].byteLength);
    }

    function testBodyBytes() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var gene = receptor();
        Assert.equals(gene.byteLength - 12, gene.bodyBytes().length);
        Assert.equals(8, gene.bodyBytes().length);

        gene.setBodyByte(0, 77);
        Assert.equals(77, gene.bodyBytes()[0]);
        Assert.equals(77, bytes.get(genome.offsetOf(2) + 12));

        // Positions outside the gene are ignored, so a neighbouring gene cannot be overwritten.
        var neighbour = bytes.get(genome.offsetOf(2) + gene.byteLength);
        gene.setBodyByte(8, 1);
        gene.setBodyByte(-1, 1);
        Assert.equals(neighbour, bytes.get(genome.offsetOf(2) + gene.byteLength));
        Assert.equals(8, gene.bodyBytes().length);
    }

    // ---------- genome ----------

    function testAnUntouchedGenomeSavesIdentically() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.isFalse(genome.isModifiedAtAll());
        Assert.equals(0, genome.modifiedGenes().length);
        Assert.equals(0, genome.toBytes().compare(sys.io.File.getBytes(FixturePath)));
    }

    function testModifiedGenesAreTracked() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        genome.genes[5].mutability = 77;

        Assert.isTrue(genome.isModifiedAtAll());
        Assert.isTrue(genome.isModified(5));
        Assert.isFalse(genome.isModified(4));
        Assert.same([5], genome.modifiedGenes());
    }

    function testSavedBytesAreACopy() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        genome.genes[5].mutability = 77;
        var saved = genome.toBytes();
        genome.genes[5].mutability = 78;

        Assert.equals(77, saved.get(genome.offsetOf(5) + 10));
    }

    function testRefreshBuildsANewGeneFromTheBytes() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var old = genome.genes[5];
        old.mutability = 77;

        var fresh = genome.refresh(5);
        Assert.isTrue(fresh != old);
        Assert.isTrue(genome.genes[5] == fresh);
        Assert.equals(77, fresh.mutability);
        Assert.equals(old.typename, fresh.typename);
        Assert.equals(old.byteLength, fresh.byteLength);
    }

    function testUndoAndRedo() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        Assert.isFalse(genome.canUndo());

        genome.checkpoint();
        genome.genes[5].mutability = 10;
        genome.checkpoint();
        genome.genes[5].mutability = 20;

        Assert.same([5], genome.undo());
        Assert.equals(10, genome.refresh(5).mutability);
        Assert.isTrue(genome.canRedo());

        Assert.same([5], genome.undo());
        Assert.equals(128, genome.refresh(5).mutability);
        Assert.isFalse(genome.canUndo());
        Assert.equals(0, genome.undo().length);

        Assert.same([5], genome.redo());
        Assert.equals(10, genome.refresh(5).mutability);
        Assert.same([5], genome.redo());
        Assert.equals(20, genome.refresh(5).mutability);
        Assert.isFalse(genome.canRedo());
    }

    function testAnEditCanBeRecordedAfterItWasMade() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var before = genome.toBytes();
        genome.genes[5].mutability = 10;
        genome.recordUndo(before);

        Assert.isTrue(genome.canUndo());
        Assert.same([5], genome.undo());
        Assert.equals(128, genome.refresh(5).mutability);
    }

    function testANewEditClearsTheRedoHistory() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        genome.checkpoint();
        genome.genes[5].mutability = 10;
        genome.undo();
        Assert.isTrue(genome.canRedo());

        genome.checkpoint();
        Assert.isFalse(genome.canRedo());
    }

    function testUndoReportsEveryChangedGene() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        genome.checkpoint();
        genome.genes[3].mutability = 1;
        genome.genes[9].mutability = 2;
        genome.genes[9].age = Adult;

        Assert.same([3, 9], genome.undo());
    }

    function testHistoryIsLimited() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        for(i in 0...150) {
            genome.checkpoint();
        }

        var undone = 0;

        while(genome.canUndo()) {
            genome.undo();
            ++undone;
        }

        Assert.equals(100, undone);
    }

    function testRevertOneGene() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        genome.genes[5].mutability = 10;
        genome.genes[6].mutability = 20;

        Assert.same([5], genome.revert(5));
        Assert.equals(128, genome.refresh(5).mutability);
        Assert.equals(20, genome.genes[6].mutability);
        // Reverting a gene that was not changed does nothing.
        Assert.equals(0, genome.revert(5).length);

        // The revert itself can be undone.
        genome.undo();
        Assert.equals(10, genome.refresh(5).mutability);
    }

    function testRevertEverything() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        genome.genes[5].mutability = 10;
        genome.genes[6].mutability = 20;

        Assert.same([5, 6], genome.revertAll());
        Assert.isFalse(genome.isModifiedAtAll());
        Assert.equals(0, genome.revertAll().length);
    }

    function testASavedGenomeLoadsAgainWithTheEdits() {
        if(genome == null) {
            Assert.pass("No fixture");
            return;
        }

        var reaction = find(ReactionGene, 24);
        reaction.setFieldValue(field(reaction, "chemical0"), 3);
        receptor().age = Old;
        receptor().sex = Female;

        var reloaded = new Genome(genome.toBytes());
        Assert.equals(genome.genes.length, reloaded.genes.length);
        Assert.isTrue(reloaded.isValid());

        var reloadedReaction : ReactionGene = cast reloaded.genes.filter(function(g) return Std.isOfType(g, ReactionGene) && g.id == 24)[0];
        Assert.equals("1 x Glucose -> 4 x Amino acid", reloadedReaction.equation);
        Assert.equals(Old, reloaded.genes[2].age);
        Assert.equals(Female, reloaded.genes[2].sex);

        // Only those two genes differ from the original file.
        Assert.same([2, genome.genes.indexOf(find(ReactionGene, 24))], genome.modifiedGenes());
    }
}
