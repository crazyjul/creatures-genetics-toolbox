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

    public function isValid() : Bool {
        var header = _bytes.getString(0, 4);

        return header == Constants.GenomeHeader;
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
            if(_bytes.getString(i, 4) == Constants.GeneHeader) {
                range.start = i;
                break;
            }

            ++i;
        }

        i += 4;

        while((i +3) < _bytes.length) {
            if(_bytes.getString(i, 4) == Constants.GeneHeader) {
                range.end = i - 1;
                break;
            }

            ++i;
        }

        if(range.start == null || (range.end == null && i != _bytes.length)) {
            return null;
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