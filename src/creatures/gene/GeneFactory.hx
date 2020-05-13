package creatures.gene;

import haxe.io.Bytes;


class GeneFactory {

    public static function create(bytes : Bytes, offset : Int) : Gene {

        var header = bytes.getString(offset, 4);

        if(header != Constants.GeneHeader) {
            return null;
        }

        var type = bytes.get(offset + Gene.TypeOffset);
        var subtype =  bytes.get(offset + 5);


        trace("Specific gene unknown");

        return new Gene(bytes, offset);
    }
}