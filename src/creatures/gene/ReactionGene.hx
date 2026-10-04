package creatures.gene;

import haxe.io.Bytes;

/**
 * A chemical reaction site: up to two reactants turning into up to two products, at a given rate.
 * Layout (from the engine's Organ::InitFromGenome): for the two reactants and then the two products,
 * a proportion (1 to 16) and a chemical (0 meaning none); then the rate.
 */
@:build(JsProp.all())
class ReactionGene extends BiochemistryGene {

    public var reactants(get, never):Array<ReactionTerm>;
    public var products(get, never):Array<ReactionTerm>;
    public var speed(get, never):Float;
    public var halfLifeTicks(get, never):Float;
    public var equation(get, never):String;

    static inline var MaxProportion = 16;
    static inline var TermsOffset = Gene.FirstGeneByte;
    static inline var RateOffset = Gene.FirstGeneByte + 8;

    public function new(bytes : Bytes, offset : Int) {
        super(bytes, offset);
    }

    override function getName() : String {
        return 'Reaction Gene';
    }

    override function getTypename() {
        return "Reaction";
    }

    /** The term at a position: 0 and 1 are the reactants, 2 and 3 the products. */
    function term(position : Int) : ReactionTerm {
        return {
            proportion : getCodon(TermsOffset + 2 * position, 1, MaxProportion),
            chemical : getByte(TermsOffset + 2 * position + 1)
        };
    }

    function present(positions : Array<Int>) : Array<ReactionTerm> {
        return [for(p in positions) term(p)].filter(function(t) return t.chemical != 0);
    }

    public function get_reactants():Array<ReactionTerm> {
        return present([0, 1]);
    }

    public function get_products():Array<ReactionTerm> {
        return present([2, 3]);
    }

    /** 1 is the fastest reaction, 0 the slowest. */
    public function get_speed():Float {
        return 1.0 - getFloat(RateOffset);
    }

    /** Ticks for half of the available reactants to react, as the engine computes it. */
    public function get_halfLifeTicks():Float {
        return Math.pow(2.2, getFloat(RateOffset) * 32.0);
    }

    function writeSide(terms : Array<ReactionTerm>) : String {
        return terms.length == 0 ? "nothing" : terms.map(function(t) return t.proportion + " x chem " + t.chemical).join(" + ");
    }

    public function get_equation():String {
        return writeSide(reactants) + " -> " + writeSide(products);
    }
}
