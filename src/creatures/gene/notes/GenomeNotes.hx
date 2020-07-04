package creatures.gene.notes;

import haxe.io.Bytes;

typedef SVNote = {

    var geneType : Int;
    var geneSubtype : Int;
    var uniqueId : Int;
    var ruleNumber : Int;

    var annotations : Array<String>;
    var generalNote : String;
}

typedef Note = {

    var geneType : Int;
    var geneSubtype : Int;
    var uniqueId : Int;

    var caption : String;
    var annotation : String;
}


class GenomeNotes {
    static inline var messageSVRuleCount = 16;
    static inline var maximumGeneCount = 900;
    static inline var maximumNoteCount = maximumGeneCount * 2;
    static inline var maximumSVRuleCount = 2;
    static inline var maximumSVNoteCount = maximumGeneCount * maximumSVRuleCount;

    private var _svNotes : Array<SVNote> = [];
    private var _notes : Array<Note> = [];
    private var _noteMap : Map<Int, Note> = new Map();
    private var _notesCount : Int;
    private var _svnotesCount: Int;

    public function new() {
    }

    public function load(bytes: Bytes) {
        var byte_index = 0;
        function readVariant() {
            var type = bytes.getUInt16(byte_index);
            var value : Dynamic;

            switch(type) {
                case 2 : //16bit integer
                    value = bytes.getUInt16(byte_index + 2);

                    if(value > (1<<15)) {
                        value -= (1<<16);
                    }

                    byte_index += 4;

                default:
                    throw "Unsupported";
            }

            return value;
        }
        function readString() {
            var length  = bytes.getUInt16(byte_index);
            var string = bytes.getString(byte_index + 2, length);
            byte_index += length + 2;
            return string;
        }
        function readSVNote() {
            var note : SVNote = {
                geneType : bytes.getUInt16(byte_index),
                geneSubtype : bytes.getUInt16(byte_index + 2),
                uniqueId : bytes.getUInt16(byte_index + 4),
                ruleNumber : bytes.getUInt16(byte_index  + 6),

                annotations : [],
                generalNote : null
            };
            byte_index += 10;

            for(i in 0...(messageSVRuleCount+1)) {
                note.annotations.push(readString());
            }

            note.generalNote = readString();
            _svNotes.push(note);
        }
        function readNote() {
            var note : Note = {
                geneType : bytes.getUInt16(byte_index),
                geneSubtype : bytes.getUInt16(byte_index + 2),
                uniqueId : bytes.getUInt16(byte_index + 4),
                caption : null,
                annotation : null
            };
            byte_index += 8;
            note.caption = readString();
            note.annotation = readString();
            _notes.push(note);
            _noteMap[note.uniqueId] = note;
        }
        _svnotesCount = readVariant();

        for(i in 0...(maximumSVNoteCount+1)) {
            readSVNote();
        }

        _notesCount = readVariant();

        for(i in 0...(maximumNoteCount+1)) {
            readNote();
        }
    }


    public function getDescription(id : Int) : String {

        if(_noteMap.exists(id)) {
            return _noteMap[id].caption;
        }

        return "";
    }

}
