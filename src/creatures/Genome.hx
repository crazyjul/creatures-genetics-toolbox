package creatures;

import haxe.io.Bytes;
import haxe.io.UInt8Array;

import creatures.gene.Gene;
import creatures.gene.GeneFactory;
import creatures.gene.Constants;

class Genome {
    var _bytes : Bytes;
    var _genes : Array<Gene>;

    public var genes(get, never) : Array<Gene>;

    public function new(bytes: Bytes) {
        _bytes = bytes;
        parse();
    }

    /** Compares raw bytes with an ASCII marker; getString would try to decode binary data as UTF-8. */
    public static function hasMarker(bytes : Bytes, offset : Int, marker : String) : Bool {
        if(offset < 0 || offset + marker.length > bytes.length) {
            return false;
        }

        for(i in 0...marker.length) {
            if(bytes.get(offset + i) != marker.charCodeAt(i)) {
                return false;
            }
        }

        return true;
    }

    public function isValid() : Bool {
        return hasMarker(_bytes, 0, Constants.GenomeHeader);
    }

    function parse() {
        var range : GeneRange;
        var current_index = 4;
        _genes = [];

        while((range = getNextGeneRange(current_index)) != null) {
            var gene = GeneFactory.create(_bytes, range.start);

            if(gene != null) {
                _genes.push(gene);
            } else {
                trace("Unknown gene, ignoring (located at byte " + range.start + ")");
            }

            current_index = range.end;
        }
    }

    function getNextGeneRange(start_index : Int) : GeneRange {

        var i = start_index;
        var range = {start : null, end : null};

        while((i + 3) < _bytes.length) {
            if(hasMarker(_bytes, i, Constants.GeneHeader)) {
                range.start = i;
                break;
            }

            ++i;
        }

        if(range.start == null) {
            return null;
        }

        // A gene ends at the next gene, at the genome footer, or at the end of the data.
        i = range.start + 4;
        range.end = _bytes.length - 1;

        while((i + 3) < _bytes.length) {
            if(hasMarker(_bytes, i, Constants.GeneHeader) || hasMarker(_bytes, i, Constants.GenomeFooter)) {
                range.end = i - 1;
                break;
            }

            ++i;
        }

        return range;
    }

    function get_genes() : Array<Gene> {
        return _genes;
    }

}

typedef GeneRange = {
    var start : Int;
    var end : Int;
}