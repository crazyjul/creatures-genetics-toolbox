# creatures-genetics-toolbox

This haxe library allows reading and modifying of Creatures 3/DS/Exodus genome files.


## Genome support

After loading a genome, you can access all the recognized genes. Genes are just containers that point to the
genome's byte array: reading a value decodes bytes, and writing a value changes them in place.

### Usage

```
import creatures.Genome;


var genome = new Genome(file_content);

for(gene in genome.genes) {
    trace(gene.id);
}

```

Every gene has the common header fields (`type`, `subtype`, `id`, `generation`, `age`, `sex`, `mutability`, `flags`)
and, depending on its kind, its own: a `ReactionGene` has `reactants`, `products` and `speed`, a `LobeGene` has a
`token`, a size and its SV rules, and so on. Genes that the toolbox does not know are kept as plain `Gene`s.

Chemical numbers can be turned into names with `creatures.Chemicals`, and `creatures.ChemicalUsage` lists which
genes use which chemicals.

### Genes decoded

Brain: lobe, tract, brain organ. Biochemistry: receptor, emitter, reaction, half life, inject, neuro emitter.
Creature: stimulus, genus, appearance, pose, gait, instinct, pigment, pigment bleed, expression. Organ.

The layouts come from the Creatures 4 engine source and from Creatures 3 genomes. The engine does not read the
appearance, pose, gait and pigment genes, so those were decoded from genomes, and the Creatures 4 genes
(pattern, color, belly, eyes, special) are not decoded yet.


## Editing

Header values have setters:

```
gene.age = Adult;
gene.sex = Female;
gene.mutability = 200;
gene.addFlag(CanBeDuplicated);
gene.removeFlag(CanBeCut);
```

Every other value is a field. A gene describes its fields with `fields()`, and `getFieldValue` and `setFieldValue`
read and write them whatever the kind of gene, so an editor needs no code per kind:

```
for(field in gene.fields()) {
    trace(field.label + " = " + gene.getFieldValue(field));
}

gene.setFieldValue(field, 0.5);
```

A field is a byte, a byte wrapped into a range (codon), a 16 bit integer, a float (a byte read as 0 to 1), a signed
float, a chemical, a flag inside a byte, a boolean or some text. Values are clamped to what the byte can hold.
`bodyBytes()` and `setBodyByte()` give raw access to the bytes after the header, for values with no field.

Editing never changes the size of the genome. The genome keeps track of the changes:

```
genome.checkpoint();            // remember the state before a change
gene.mutability = 10;

genome.isModified(index);       // does this gene differ from the loaded one?
genome.modifiedGenes();         // positions of all the genes that do

var changed = genome.undo();    // positions of the genes that changed back
genome.redo();
genome.revert(index);           // one gene back to how it was loaded
genome.revertAll();

genome.refresh(index);          // a new gene object built from the bytes
var saved = genome.toBytes();   // the genome, ready to write to a file
```

`recordUndo(snapshot)` records a snapshot taken earlier with `toBytes()`, for callers that want to make a change
first and keep it in the history only if the bytes really changed. Up to 100 steps are kept.


## Tests

The tests use [utest](https://github.com/haxe-utest/utest) and run against a sample genome in `test/data`:

```
haxelib install utest
haxe tests.hxml                                  # on the Haxe interpreter
haxe tests-js.hxml && node bin/tests.js          # as JavaScript on node (needs hxnodejs)
```

The JavaScript run matters: the library is used in a browser, and some things behave differently there (for
example, `Bytes.getString` throws on binary data in JavaScript but not on the interpreter).
