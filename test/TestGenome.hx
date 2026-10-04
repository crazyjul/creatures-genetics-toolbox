import haxe.io.Bytes;
import haxe.io.BytesOutput;
import utest.Assert;
import utest.Test;

import creatures.Genome;
import creatures.gene.Constants;
import creatures.gene.Gene;
import creatures.gene.notes.GenomeNotes;

class TestGenome extends Test {
    /** Drop a real genome file here to enable the fixture tests. */
    static inline var FixturePath = "test/data/sample.gen";
    static inline var NotesFixturePath = "test/data/sample.gno";

    /** Builds a gene block: header, type, subtype, id, generation, age, flags, mutability, variant, payload. */
    static function geneBytes(type : Int, subtype : Int, id : Int, ?payload : Array<Int>) : Bytes {
        var out = new BytesOutput();
        out.writeString(Constants.GeneHeader);
        out.writeByte(type);
        out.writeByte(subtype);
        out.writeByte(id);
        out.writeByte(0);   // generation
        out.writeByte(4);   // age: adult
        out.writeByte(0);   // flags
        out.writeByte(1);   // mutability
        out.writeByte(0);   // variant
        for(b in (payload != null ? payload : [])) {
            out.writeByte(b);
        }
        return out.getBytes();
    }

    static function genomeBytes(genes : Array<Bytes>, footer : Bool = true) : Bytes {
        var out = new BytesOutput();
        out.writeString(Constants.GenomeHeader);
        for(g in genes) {
            out.writeBytes(g, 0, g.length);
        }
        if(footer) {
            out.writeString(Constants.GenomeFooter);
        }
        return out.getBytes();
    }

    function testValidHeader() {
        var genome = new Genome(genomeBytes([]));
        Assert.isTrue(genome.isValid());
    }

    function testInvalidHeader() {
        var genome = new Genome(Bytes.ofString("nope"));
        Assert.isFalse(genome.isValid());
    }

    function testEmptyGenomeHasNoGenes() {
        var genome = new Genome(genomeBytes([]));
        Assert.equals(0, genome.genes.length);
    }

    function testParsesEveryGene() {
        var genome = new Genome(genomeBytes([
            geneBytes(1, 0, 1, [0, 0, 0, 0, 0, 0, 0, 0]),   // receptor
            geneBytes(1, 2, 2, [0, 0, 0, 0, 0, 0, 0, 0]),   // reaction
            geneBytes(3, 0, 3, [0, 0, 0, 0, 0, 0, 0, 0])    // organ
        ]));
        Assert.equals(3, genome.genes.length);
    }

    function testLastGeneIsKept() {
        var genome = new Genome(genomeBytes([geneBytes(1, 2, 7, [0, 0, 0, 0, 0, 0, 0, 0])]));
        Assert.equals(1, genome.genes.length);
        Assert.equals(7, genome.genes[0].id);
    }

    function testGeneHeaderFields() {
        var genome = new Genome(genomeBytes([geneBytes(1, 2, 9, [0, 0, 0, 0, 0, 0, 0, 0])]));
        var gene : Gene = genome.genes[0];
        Assert.equals(1, gene.type);
        Assert.equals(2, gene.subtype);
        Assert.equals(9, gene.id);
        Assert.equals(1, gene.mutability);
    }

    function testReactionGeneTypename() {
        var genome = new Genome(genomeBytes([geneBytes(1, 2, 1, [0, 0, 0, 0, 0, 0, 0, 0])]));
        Assert.equals("Reaction", genome.genes[0].typename);
    }

    function testUnknownGeneTypeIsKept() {
        var genome = new Genome(genomeBytes([
            geneBytes(1, 2, 1, [0, 0, 0, 0, 0, 0, 0, 0]),
            geneBytes(9, 9, 2, [0, 0, 0, 0]),   // type not known to the toolbox
            geneBytes(1, 2, 3, [0, 0, 0, 0, 0, 0, 0, 0])
        ]));
        Assert.equals(3, genome.genes.length);
        Assert.equals(9, genome.genes[1].type);
        Assert.isNull(genome.genes[1].typename);
    }

    #if sys
    static function fixture(path : String) : Bytes {
        return sys.FileSystem.exists(path) ? sys.io.File.getBytes(path) : null;
    }

    static function countGeneHeaders(bytes : Bytes) : Int {
        var count = 0;
        for(i in 0...(bytes.length - 3)) {
            if(Genome.hasMarker(bytes, i, Constants.GeneHeader)) {
                ++count;
            }
        }
        return count;
    }

    function testFixtureGenomeLoads() {
        var bytes = fixture(FixturePath);
        if(bytes == null) {
            Assert.pass("No fixture at " + FixturePath);
            return;
        }

        var genome = new Genome(bytes);
        Assert.isTrue(genome.isValid());
        Assert.isTrue(genome.genes.length > 0);
        Assert.equals(countGeneHeaders(bytes), genome.genes.length);
    }

    function testFixtureGenomeHasNoUnimplementedGenes() {
        var bytes = fixture(FixturePath);
        if(bytes == null) {
            Assert.pass("No fixture at " + FixturePath);
            return;
        }

        var genome = new Genome(bytes);
        var unimplemented = genome.genes.filter(function(g) return g.typename == null);
        Assert.equals(0, unimplemented.length);

        // Every gene still exposes the common header fields.
        for(g in genome.genes) {
            Assert.isTrue(g.type >= 0 && g.type <= 3);
        }
    }

    function testFixtureNotesDescribeGenes() {
        var bytes = fixture(FixturePath);
        var notes_bytes = fixture(NotesFixturePath);
        if(bytes == null || notes_bytes == null) {
            Assert.pass("No fixture");
            return;
        }

        var genome = new Genome(bytes);
        var notes = new GenomeNotes();
        notes.load(notes_bytes);

        var described = genome.genes.filter(function(g) return notes.getDescription(g.type, g.subtype, g.id) != "");
        Assert.isTrue(described.length > genome.genes.length / 2);
    }

    /** Not an assertion: prints the gene kinds of the fixture genome that have no dedicated implementation yet. */
    function testReportUnimplementedGenes() {
        var bytes = fixture(FixturePath);
        if(bytes == null) {
            Assert.pass("No fixture at " + FixturePath);
            return;
        }

        var genome = new Genome(bytes);
        var counts = new Map<String, Int>();
        for(g in genome.genes) {
            if(g.typename == null) {
                var key = Type.getClassName(Type.getClass(g)) + " (type " + g.type + ", subtype " + g.subtype + ")";
                counts[key] = counts.exists(key) ? counts[key] + 1 : 1;
            }
        }

        var keys = [for(k in counts.keys()) k];
        keys.sort(Reflect.compare);
        Sys.println("");
        Sys.println("Genes without a typename in the fixture genome (" + genome.genes.length + " genes total):");
        for(k in keys) {
            Sys.println("  " + counts[k] + " x " + k);
        }
        Assert.pass();
    }
    #end
}
