#!/usr/bin/perl;
use strict;
use warnings;
use Getopt::Long;

my $rs_file;
my $vcf_file;
my @rs_data;
my $match;
my $help_message=0;
my $outname;
my $output_handle = \*STDOUT;
my $column = 3;
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
	-m,--match = retain records that matches ids in <RS> [False]
	-c,--column = provide the column number for rs id in <VCF> file [3]
	
		
END_MESSAGE

GetOptions( "rs=s" => \$rs_file, "i|vcf=s"=> \$vcf_file, "m|match" => \$match, "h|help" => \$help_message, "o|out=s" => \$outname, "c|column=i" => \$column);

#check for help flag and if input is provided 
if ($help_message){
	
	print $message;
	exit;
}
unless ($rs_file && $vcf_file){
	print STDERR "Specify input and rs list\n";
	exit;
}
if ($outname){
	open my $fh, ">", $outname or die "Can't write to $outname\n";
	$output_handle = $fh;
}
#print STDERR "Opening data\n";
open my $rsfh, "<", $rs_file or die "$rs_file doesn't exist\n";
while (<$rsfh>){
	chomp($_);
	push (@rs_data,$_);
}
close $rsfh;
open my $vcfh, "<", $vcf_file or die "$vcf_file doesn't exist\n";

while (<$vcfh>){
	chomp($_);
	if ($_=~/^#/){
		print $output_handle $_,"\n";	#prints vcf header
		next;
	}
	next if $_ eq ""; #skips blank line
	my @fields=split("\t",$_);
	die "Too large column number\n" if ($column-1) > $#fields;
	my $rs_field = $fields[$column-1];
	if (grep {$_ eq $rs_field} @rs_data){		#print data depending whether match flag was provided
		if ($match){
			print $output_handle $_,"\n";
		}
	} else {
		unless ($match){
			print $output_handle $_,"\n";
		}
	}
}
close $vcfh;
close $output_handle;
exit;
