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

my $message = <<'END_MESSAGE';
Usage:
	perl filter_rs.pl -i <VCF> --rs <RS>
	where 
	<VCF> is your data in vcf file format
	<RS> is list
	
		
END_MESSAGE

GetOptions( "rs=s" => \$rs_file, "i|vcf=s"=> \$vcf_file, "m|match" => \$match, "h|help" => \$help_message, "o|out=s" => \$outname);
unless ($rs_file && $vcf_file){
	print STDERR "Specify input and rs list\n";
	exit;
}
if ($help_message){
	
	print $message;
	exit;
}
if ($outname){
	open my $fh, ">", $outname or die "Can't write to $outname\n";
	$output_handle = $fh;
}
print STDERR "Opening data\n";
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
	my $rs_field = $fields[2];
	if ($match){
		print $output_handle $_,"\n" if (grep {$_ eq $rs_field} @rs_data);
	} else {
		print $output_handle $_,"\n" if (grep {$_ ne $rs_field} @rs_data);
	}
}
close $vcfh;
close $output_handle;

#print $vcf_file,"\t", $rs_file,"\n";
