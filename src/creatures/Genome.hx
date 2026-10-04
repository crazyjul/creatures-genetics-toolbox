package creatures;

import haxe.io.Bytes;
import haxe.io.UInt8Array;

import creatures.gene.Gene;
import creatures.gene.GeneFactory;
import creatures.gene.Constants;

class Genome {
    static inline var HistoryLimit = 100;

    var _bytes : Bytes;
    var _original : Bytes;
    var _genes : Array<Gene>;
    var _offsets : Array<Int>;
    var _lengths : Array<Int>;
    var _undo : Array<Bytes>;
    var _redo : Array<Bytes>;

    public var genes(get, never) : Array<Gene>;

    public function new(bytes: Bytes) {
        _bytes = bytes;
        _original = copyOf(bytes);
        _undo = [];
        _redo = [];
        parse();
    }

    static function copyOf(bytes : Bytes) : Bytes {
        var copy = Bytes.alloc(bytes.length);
        copy.blit(0, bytes, 0, bytes.length);

        return copy;
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
        _offsets = [];
        _lengths = [];

        while((range = getNextGeneRange(current_index)) != null) {
            var gene = GeneFactory.create(_bytes, range.start);

            if(gene != null) {
                gene.attachLength(range.end - range.start + 1);
                _genes.push(gene);
                _offsets.push(range.start);
                _lengths.push(range.end - range.start + 1);
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

    // ---------- editing ----------
    //
    // Genes read and write the genome's bytes directly. Editing never changes the genome's size, so a gene
    // keeps its position, and a changed gene can be rebuilt from its bytes with refresh().

    /** Position of the gene in the file. */
    public function offsetOf(index : Int) : Int {
        return _offsets[index];
    }

    /**
     * Builds the gene at this position again from the genome's bytes and puts it in the list.
     * Use it after the bytes changed so that the gene object is a fresh one (a UI can then tell it changed).
     */
    public function refresh(index : Int) : Gene {
        var gene = GeneFactory.create(_bytes, _offsets[index]);
        gene.attachLength(_lengths[index]);
        _genes[index] = gene;

        return gene;
    }

    /** Whether the gene's bytes differ from those the genome was loaded with. */
    public function isModified(index : Int) : Bool {
        for(i in _offsets[index]..._offsets[index] + _lengths[index]) {
            if(_bytes.get(i) != _original.get(i)) {
                return true;
            }
        }

        return false;
    }

    /** Positions of the genes that differ from the loaded genome. */
    public function modifiedGenes() : Array<Int> {
        return [for(i in 0..._genes.length) if(isModified(i)) i];
    }

    public function isModifiedAtAll() : Bool {
        return _bytes.compare(_original) != 0;
    }

    /** The genome as it is now, ready to save. A copy, so saving cannot be changed by later edits. */
    public function toBytes() : Bytes {
        return copyOf(_bytes);
    }

    // ---------- history ----------

    /** Remembers the genome as it is now; call it before a change so that the change can be undone. */
    public function checkpoint() : Void {
        recordUndo(copyOf(_bytes));
    }

    /**
     * Remembers a snapshot taken earlier (see toBytes) as the state to go back to. This lets a caller make a
     * change first and only record it if the bytes really changed.
     */
    public function recordUndo(snapshot : Bytes) : Void {
        _undo.push(snapshot);

        if(_undo.length > HistoryLimit) {
            _undo.shift();
        }

        _redo = [];
    }

    public function canUndo() : Bool {
        return _undo.length > 0;
    }

    public function canRedo() : Bool {
        return _redo.length > 0;
    }

    /** Goes back to the last checkpoint; returns the positions of the genes that changed. */
    public function undo() : Array<Int> {
        if(_undo.length == 0) {
            return [];
        }

        _redo.push(copyOf(_bytes));

        return restore(_undo.pop());
    }

    public function redo() : Array<Int> {
        if(_redo.length == 0) {
            return [];
        }

        _undo.push(copyOf(_bytes));

        return restore(_redo.pop());
    }

    /** Puts one gene back to how it was loaded. Returns the positions that changed. */
    public function revert(index : Int) : Array<Int> {
        if(!isModified(index)) {
            return [];
        }

        checkpoint();
        _bytes.blit(_offsets[index], _original, _offsets[index], _lengths[index]);

        return [index];
    }

    /** Puts the whole genome back to how it was loaded. Returns the positions that changed. */
    public function revertAll() : Array<Int> {
        if(!isModifiedAtAll()) {
            return [];
        }

        checkpoint();

        return restore(_original);
    }

    /** Copies the snapshot over the genome's bytes and reports which genes that changed. */
    function restore(snapshot : Bytes) : Array<Int> {
        var changed = [];

        for(i in 0..._genes.length) {
            for(b in _offsets[i]..._offsets[i] + _lengths[i]) {
                if(_bytes.get(b) != snapshot.get(b)) {
                    changed.push(i);
                    break;
                }
            }
        }

        _bytes.blit(0, snapshot, 0, snapshot.length);

        return changed;
    }
}

typedef GeneRange = {
    var start : Int;
    var end : Int;
}
