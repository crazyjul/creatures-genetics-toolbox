package creatures.gene;

import haxe.io.Bytes;

@:build(JsProp.all())
class Gene {
    var _bytes : Bytes;
    var _offset : Int;
    var _length : Int;

    public static inline var TypeOffset = 4;
    public static inline var SubtypeOffset = 5;
    public static inline var IdOffset = 6;
    public static inline var GenerationOffset = 7;
    public static inline var AgeOffset = 8;
    public static inline var FlagsOffset = 9;
    public static inline var MutabilityOffet = 10;
    public static inline var VariantOffset = 11;

    public static inline var MutableFlag = 1;
    public static inline var DuplicateFlag = 2;
    public static inline var CutFlag = 4;
    public static inline var MaleFlag = 8;
    public static inline var FemaleFlag = 16;
    public static inline var IgnoreFlag = 32;

    public static inline var FirstGeneByte = 12;

    public var typename(get, never):String;
    public var type(get, never) : Int;
    public var subtype(get, never) : Int;
    public var id(get, never) : Int;
    public var generation(get, never) : Int;
    public var age(get, set) : Age;
    public var flags(get, never): Array<GeneFlag>;
    public var variant(get, never): Int;
    public var sex(get, set) : SexActivation;
    public var mutability(get, set) : Int;

    /** Size of the gene in bytes, header included. */
    public var byteLength(get, never) : Int;

    public function new(bytes :  Bytes, offset : Int) {
        _bytes = bytes;
        _offset = offset;
        _length = FirstGeneByte;
    }

    /** Called by the genome, which knows where the gene ends. */
    public function attachLength(length : Int) : Void {
        _length = length;
    }

    public function get_typename():String {
        return getTypename();
    }

    function getTypename() : String {
        return null;
    }

    function get_byteLength() : Int {
        return _length;
    }

    function get_type() : Int {
        return getByte(TypeOffset);
    }

    function get_subtype() : Int {
        return getByte(SubtypeOffset);
    }

    function get_id() : Int {
        return getByte(IdOffset);
    }

    function get_generation() : Int {
        return getByte(GenerationOffset);
    }

    function get_age() : Age {
        var age = getByte(AgeOffset);

        switch(age) {
            case 0: return Embryo;

            case 1: return Child;

            case 2: return Adolescent;

            case 3: return Youth;

            case 4: return Adult;

            case 5: return Old;

            case 6: return Senile;

            // Throw an error ?
            default : return Embryo;
        }
    }

    function set_age(value : Age) : Age {
        var number = switch(value) {
            case Embryo: 0;
            case Child: 1;
            case Adolescent: 2;
            case Youth: 3;
            case Adult: 4;
            case Old: 5;
            case Senile: 6;
        }

        writeByte(AgeOffset, number);

        return value;
    }

    static function flagBit(flag : GeneFlag) : Int {
        return switch(flag) {
            case CanBeMutated: MutableFlag;
            case CanBeDuplicated: DuplicateFlag;
            case CanBeCut: CutFlag;
            case ExpressInMale: MaleFlag;
            case ExpressInFemale: FemaleFlag;
            case Ignored: IgnoreFlag;
        }
    }

    static var AllFlags : Array<GeneFlag> = [CanBeMutated, CanBeDuplicated, CanBeCut, ExpressInMale, ExpressInFemale, Ignored];

    function get_flags() :Array<GeneFlag> {
        var bits = getByte(FlagsOffset);

        return AllFlags.filter(function(flag) return (bits & flagBit(flag)) != 0);
    }

    function get_variant() : Int {
        return getByte(VariantOffset);
    }

    function get_mutability() : Int {
        return getByte(MutabilityOffet);
    }

    function set_mutability(value: Int) : Int {
        writeByte(MutabilityOffet, value);

        return getByte(MutabilityOffet);
    }

    function getName() :String {
        return "Unknown gene ( " + type + ")";
    }

    function getByte(local_offset : Int) : Int {
        return _bytes.get(_offset + local_offset);
    }

    /** Writes a byte, keeping it within 0 to 255. */
    function writeByte(local_offset : Int, value : Int) : Void {
        _bytes.set(_offset + local_offset, value < 0 ? 0 : (value > 255 ? 255 : value));
    }

    /** Two byte big-endian integer, as stored in genes. */
    function getInt(local_offset : Int) : Int {
        return (getByte(local_offset) << 8) | getByte(local_offset + 1);
    }

    function writeInt(local_offset : Int, value : Int) : Void {
        var clamped = value < 0 ? 0 : (value > 65535 ? 65535 : value);

        writeByte(local_offset, clamped >> 8);
        writeByte(local_offset + 1, clamped & 255);
    }

    /** Four character identifier (lobe names and so on). Read as raw bytes, genes are not text. */
    function getToken(local_offset : Int) : String {
        var token = "";

        for(i in 0...4) {
            token += String.fromCharCode(getByte(local_offset + i));
        }

        return token;
    }

    /** Reads raw bytes as characters. Not getString, which decodes UTF-8 and throws on binary data. */
    function getRawString(local_offset : Int, length : Int) : String {
        var result = "";

        for(i in 0...length) {
            result += String.fromCharCode(getByte(local_offset + i));
        }

        return result;
    }

    /** Writes the characters as bytes, padding with spaces or cutting to the given length. */
    function writeRawString(local_offset : Int, length : Int, text : String) : Void {
        for(i in 0...length) {
            writeByte(local_offset + i, i < text.length ? text.charCodeAt(i) : 32);
        }
    }

    function getBool(local_offset : Int) : Bool {
        return getByte(local_offset) != 0;
    }

    function getSVRule(local_offset : Int) : Array<SVRuleEntry> {
        return SVRule.read(_bytes, _offset + local_offset);
    }

    function getFloat(local_offset : Int) : Float {
        return _bytes.get(_offset + local_offset) / 255;
    }

    function writeFloat(local_offset : Int, value : Float) : Void {
        writeByte(local_offset, Math.round(value * 255));
    }

    function getSignedFloat(local_offset : Int) : Float {
        return (getCodon(local_offset, 0, 248) / 124.0) - 1.0;
    }

    function writeSignedFloat(local_offset : Int, value : Float) : Void {
        var byte = Math.round((value + 1.0) * 124.0);

        writeByte(local_offset, byte < 0 ? 0 : (byte > 248 ? 248 : byte));
    }

    function getByteWithInvalid(local_offset : Int) : Int {
        var value = getCodon(local_offset, 0, 255);
        return value == 255 ? -1 : value;
    }

    function getCodon(local_offset : Int, min : Int, max: Int) : Int {

        var value = getByte(local_offset);

        if(min <= value && value <= max) {
            return value;
        }

        return value % (max - min + 1) + min;
    }

    function get_sex() : SexActivation {
        var sex = getByte(FlagsOffset);
        sex &= MaleFlag | FemaleFlag;

        if(sex == 0 || sex == (MaleFlag | FemaleFlag)) {
            return Both;
        } else if(sex == MaleFlag) {
            return Male;
        } else {
            return Female;
        }
    }

    /** Genes that are not tied to a sex have neither the male nor the female bit. */
    function set_sex(value : SexActivation) : SexActivation {
        var bits = getByte(FlagsOffset) & ~(MaleFlag | FemaleFlag);

        switch(value) {
            case Male: bits |= MaleFlag;
            case Female: bits |= FemaleFlag;
            case Both:
        }

        writeByte(FlagsOffset, bits);

        return value;
    }

    public function addFlag(value : GeneFlag) : Void {
        writeByte(FlagsOffset, getByte(FlagsOffset) | flagBit(value));
    }

    public function removeFlag(value : GeneFlag) : Void {
        writeByte(FlagsOffset, getByte(FlagsOffset) & ~flagBit(value));
    }

    public function hasFlag(value : GeneFlag) : Bool {
        return (getByte(FlagsOffset) & flagBit(value)) != 0;
    }

    // ---------- generic access, for editors ----------

    /** The values this kind of gene lets an editor change. */
    public function fields() : Array<GeneField> {
        return [];
    }

    /** A field's value: a number, a Bool for bits and a String for text. */
    public function getFieldValue(field : GeneField) : Dynamic {
        return switch(field.kind) {
            case "byte" | "chemical": getByte(field.offset);
            case "codon": getCodon(field.offset, field.min, field.max);
            case "int16": getInt(field.offset);
            case "float": getFloat(field.offset);
            case "sfloat": getSignedFloat(field.offset);
            case "bit": (getByte(field.offset) & field.mask) != 0;
            case "bool": getByte(field.offset) != 0;
            case "text": getRawString(field.offset, field.length);
            default: null;
        }
    }

    public function setFieldValue(field : GeneField, value : Dynamic) : Void {
        switch(field.kind) {
            case "byte" | "chemical":
                writeByte(field.offset, Math.round(value));
            case "codon":
                var number : Int = Math.round(value);
                writeByte(field.offset, number < field.min ? field.min : (number > field.max ? field.max : number));
            case "int16":
                writeInt(field.offset, Math.round(value));
            case "float":
                writeFloat(field.offset, value);
            case "sfloat":
                writeSignedFloat(field.offset, value);
            case "bit":
                var bits = getByte(field.offset);
                writeByte(field.offset, value == true ? bits | field.mask : bits & ~field.mask);
            case "bool":
                writeByte(field.offset, value == true ? 1 : 0);
            case "text":
                writeRawString(field.offset, field.length, Std.string(value));
            default:
        }
    }

    /** The bytes after the header, as numbers. */
    public function bodyBytes() : Array<Int> {
        return [for(i in FirstGeneByte...byteLength) getByte(i)];
    }

    /** Sets one of the bytes after the header (position 0 is the gene's first body byte). */
    public function setBodyByte(position : Int, value : Int) : Void {
        var local = FirstGeneByte + position;

        if(position >= 0 && local < byteLength) {
            writeByte(local, value);
        }
    }
}
