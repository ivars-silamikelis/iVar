Filter out vcf file by a list of rs IDs and/or sample genotypes.
Currently only diploid genotypes are accepted for genotype filtering.

Each ID in the list must be seperated by newline (see rs.txt).

To test script just type:

perl iVar.pl -i sample.vcf -rs rs.txt

or

perl iVar.pl -i sample_2.vcf -g genotypes.txt


To filter sample by genotypes, list of samples with their genotypes is needed.
Format it like this:

SampleName1:genotype1,genotype2,...,genotypeN

SampleName2:genotype1,genotype2,...,genotypeN

SampleName3:genotype1,genotype2,...,genotypeN


Where genotype1...N can have any genotype value (0/0, 0/1 etc). 

It also accepts following genotypes:
het = retain records where sample is heterozygote (-het to drop these records)
hom = retain records where sample is homozygote (-hom to drop these records)
hom_alt = retain records where sample is homozygote with alternative allele (-hom_alt to drop these records)
hom_ref = retain records where sample is homozygote with reference allele (-hom_alt to drop these records)
any = sample can have any genotype (even empty) (-any to drop these records (empty list))
empty = sample can have only empty genotype (-empty to drop these records (same as non_empty))
non_empty = sample can have only non empty genotype (-non_empty to drop these records (same as empty))

(see genotypes.txt)


