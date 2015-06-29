#iVar
Filter out vcf file by a list of rs IDs and/or sample genotypes.
Currently only diploid genotypes are accepted for genotype filtering.

Each ID in the list must be seperated by newline (see rs.txt).

##Installation

To install with git, type in terminal:
```bash
git clone https://github.com/ivars-silamikelis/iVar
cd iVar
```
To test script, type:
```bash
perl iVar.pl -i sample.vcf -rs rs.txt
```
or
```bash
perl iVar.pl -i sample_2.vcf -g genotypes.txt
```
##Usage
To remove records in vcf file named `sample.vcf` that have rs IDs specified in a list named `rs.txt`:
```
perl iVar.pl -i sample.vcf -rs rs.txt
```
To keep records in vcf file named `sample.vcf` that have rs IDs specified in a list named `rs.txt` use `-m` flag:
```
perl iVar.pl -i sample.vcf -rs rs.txt -m
```

To filter vcf file named `sample.vcf` by sample genotypes, list of samples with their genotypes is needed (`genotypes.txt`).
```
perl iVar.pl -i sample.vcf -g genotypes.txt
```

If there are multiple genotypes listed for one sample, then records matching any of the specified genotypes will be kept.

If there are multiple samples in vcf file, then only those records where each sample matches given genotypes will be kept.


The list of genotypes must be in the following format:
```
SampleName1:genotype1,genotype2,...,genotypeN
SampleName2:genotype1,genotype2,...,genotypeN
SampleName3:genotype1,genotype2,...,genotypeN
```

Where `genotype1...N` can have any genotype value (0/0, 0/1 etc). 

It also accepts following genotypes:

Genotype | Description
---|---
**het** | retain records where sample is heterozygote (-het to drop these records)
**hom** | retain records where sample is homozygote (-hom to drop these records)
**hom_alt** | retain records where sample is homozygote with alternative allele (-hom_alt to drop these records)
**hom_ref** | retain records where sample is homozygote with reference allele (-hom_alt to drop these records)
**any** | sample can have any genotype (even empty) (-any to drop these records (empty list))
**empty** | sample can have only empty genotype (-empty to drop these records (same as non_empty))
**non_empty** | sample can have only non empty genotype (-non_empty to drop these records (same as empty))

(see genotypes.txt for examples)


