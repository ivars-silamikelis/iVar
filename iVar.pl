#!/usr/bin/perl;

#	 iVar filters vcf file by rs IDs and/or sample genotypes.
#    Copyright (C) 2014 Ivars Silamikelis
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#	 
#	 If you have any questions or comments you can contact me at ivars.silamikelis@biomed.lu.lv

use strict;
use warnings;
use Getopt::Long;
use List::Util qw(first);
my $rs_file;
my $vcf_file;
my $genotype_file;
my @rs_data;
my %genotypes;
my $match;
my $help_message=0;
my $outname;
my $output_handle = \*STDOUT;
my $column = 3;
my $gt_reverse;
# usage message
my $message = <<'END_MESSAGE';
Usage:
	perl iVar.pl -i <VCF> -rs <RS>
	where 
	<VCF> is your data in vcf file format
	<RS> is a newline seperated list containing rs IDs

	Available options:	
	-h,--help = print this message
	-o,--out = send output to file [STDOUT]
	-m,--match = retain records that matches ids in <RS>
	-c,--column = provide the column number for rs id in <VCF> file [3]
	-g,--genotypes = filter records by sample genotypes. Argument is a list of samples and their genotypes (see README)
	--gv = if on, then filter out records by sample genotypes
		
END_MESSAGE

GetOptions( "rs=s" => \$rs_file, "i|vcf=s"=> \$vcf_file, "m|match" => \$match,
"h|help" => \$help_message, "o|out=s" => \$outname,
"c|column=i" => \$column, "g|genotypes=s" => \$genotype_file, "gv" => \$gt_reverse);

#check for help flag and if input is provided 
if ($help_message){
	
	print $message;
	exit;
}
unless (($rs_file or $genotype_file) && $vcf_file){
	print STDERR "Specify input and rs or genotype list\n";
	exit;
}
if ($outname){
	open my $fh, ">", $outname or die "Can't write to $outname\n";
	$output_handle = $fh;
}
#print STDERR "Opening data\n";
#Parse list of rs ids
if ($rs_file){
	open my $rsfh, "<", $rs_file or die "Rs file $rs_file doesn't exist\n";
	while (<$rsfh>){
		chomp($_);
		push (@rs_data,$_);
	}
	close $rsfh;
}
#Parse list of genotypes
if ($genotype_file){
	open my $gtfh, "<", $genotype_file or die "Genotype file $genotype_file doesn't exist\n";
	while (<$gtfh>){
		chomp($_);
		$_=~s/ //g;
		my @fields = split(":",$_);
		@{$genotypes{$fields[0]}} = split(",",$fields[1]);
	}
	close $gtfh;
}

my $sample_count=scalar (keys %genotypes);
my %sample_indexes;
open my $vcfh, "<", $vcf_file or die "$vcf_file doesn't exist\n";

while (<$vcfh>){
	my $genotype_matches = 0;
	chomp($_);
	if ($_=~/CHROM\tPOS/){
		my @header = split("\t",$_);
		#get sample indexes to know which genotype belongs to which sample
		for my $sample (keys %genotypes){
			$sample_indexes{$sample} = first {$header[$_] eq $sample} 0..$#header;
		}
	}
	if ($_=~/^#/){
		print $output_handle $_,"\n";	#prints vcf header
		next;
	}
	next if $_ eq ""; #skips blank line
	my @fields=split("\t",$_);
	my $print_flag=0;
	my $condition_number=1;
	if ($rs_file && $genotype_file){
		$condition_number=2;
	}

	die "Column number out of scope\n" if ($column-1) > $#fields;
	my $rs_field = $fields[$column-1];
	if ($rs_file){
		$print_flag+=&rs_filter($rs_field, \@rs_data, $match);
#		if (grep {$_ eq $rs_field} @rs_data){		#print data depending whether match flag was provided
#			if ($match){
#				$print_flag+=1;
#				#print $output_handle $_,"\n";
#			}
#		} else {
#			unless ($match){
#				$print_flag+=1;
#				#print $output_handle $_,"\n";
#			}
#		}
	}
	if ($genotype_file){
		$print_flag+=&genotype_filter(\%genotypes, \%sample_indexes, \@fields, $sample_count,$gt_reverse);
		
		#for my $sample (keys %genotypes){
		#	#split data about sample in vcf file
		#	my @data = split(":",$fields[$sample_indexes{$sample}]);
		#	if (grep {$_ eq $data[0]} (@{$genotypes{$sample}})){
		#		++$genotype_matches;
		#	}
		#}
		#$print_flag+=1 if $genotype_matches == $sample_count;
	}
	print $output_handle $_,"\n" if $print_flag == $condition_number;
}
close $vcfh;
close $output_handle;
exit;
#rs_filter :: (String, \[String], Bool) -> Bool ( Actually an integer)
sub rs_filter{
	#Filter by rs field
	my $rs_id = shift;
	my $rs_list_ref = shift;
	my $match_flag = shift;
    if (grep {$_ eq $rs_id} @$rs_list_ref){       #print data depending whether match flag was provided
    	if ($match){
        	return 1;
          	#print $output_handle $_,"\n";
        } else {
			return 0;
		}
    } else {
    	unless ($match){
        	return 1;
            #print $output_handle $_,"\n";
        } else {
			return 0;
		}
    }
}

sub genotype_filter {
	#Filter by provided genotypes
	my $genotypes = shift;
	my $sample_indexes = shift;
	my $fields = shift;
	my $sample_count = shift;
	my $reverse_flag = shift;
	my $genotype_matches = 0;
	my %gtype_regexes = ("hom" => qr!(\d+)/\1!, "het" => qr%(\d+)/(?!\1)%, "hom_alt" => qr!([1-9]+)/\1!, "hom_ref" => qr!0/0!,
						 "any" => qr!.+/.+!, "empty" => qr!\./\.!, "non_empty" => qr![^.]/[^.]!,
						"-hom" => qr%(\d+)/(?!\1)|\./\.%, "-het" => qr%(\d+)/\1|\./\.%, "-hom_alt" => qr%0/0|(\d+)/(?!\1)|\./\.%,
						"-hom_ref" => qr%^(?!0/0)%, "-any" => qr%^(?!.+/.+)%, "-empty" => qr%^(?!\./\.)%, 
						"-non_empty" => qr%\./\.%
						);
	for my $sample (keys %{$genotypes}){
		die "Sample name in genotype file and vcf file do not match!\nMake sure that sample names in VCF header are exactly the same as in genotype file\n" unless $sample_indexes->{$sample};
        #split data about sample in vcf file
    	my @data = split(":",$fields->[$sample_indexes->{$sample}]);
		if (grep {$_ eq $data[0]} (@{$genotypes->{$sample}})){
			unless ($reverse_flag){
        		++$genotype_matches;
			} else {
				next;
			}
        } 
		if (grep {$_ =~ /hom|het|any|empty|non_empty/} @{$genotypes->{$sample}}){
			#check for het, hom, hom_alt or hom_ref flags
			#map {print $_," => ",$gtype_regexes{$_}} @{$genotypes->{$sample}};
			if (grep {$data[0] =~ /$gtype_regexes{$_}/ if $gtype_regexes{$_}} (@{$genotypes->{$sample}})) {
				unless ($reverse_flag){
					++$genotype_matches;
				} else {
					next;
				}
			}
		} 
		if ($reverse_flag){
			++$genotype_matches; 
		}
    }
    if ($genotype_matches == $sample_count){
		return 1;
	} else {
		return 0;
	}	
}
