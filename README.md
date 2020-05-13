# creatures-genetics-toolbox

This haxe library allows reading and modifying of Creatures 3/DS/Exodus genome files.


## Genome support

After loading a genome, you can access to all genes. Genes are just container that point to the original byte array.

For the moment, the system is read-only and does not support modifications.

###Usage

```
import creatures.Genome;


var genome = new Genome( file_content );

for( gene in genome.gene) {
    trace(gene.id);
}

```
