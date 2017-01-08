#!/usr/bin/env perl
use Getopt::Long;
use strict;
use warnings;
use Data::Dumper;
use List::Util 'shuffle';
$|=1;
$Data::Dumper::Sortkeys =1;

###############
# Description:
###############
# Given distinct "subject" (S) and a "target" (T) distributions, this script attempts to mimic T's density (i.e., its shape) by pseudo-randomly sampling from S's population.
# Warning: The script attempts to match T's density only, not its population size.

###################
# Arguments/Input:
###################
#    arg1: path to file containing T's values (1 column, 1 value per line)
#    arg2: number of bins to split the distributions into
#    arg3: path to tab-separated file containing S's identifiers and values (column 1: unique identifier; column 2: corresponding value)

###########
# Options:
###########
#    transform: bin `transform`-transformed values in both distributions. Output values will be the original, non-transformed ones, though.
#     Possible values: 'log10' only.
#     binning into log10-transformed is highly recommended e.g. for matching FPKM/RPKM distributions.

###############################
# Output (to standard output):
###############################
# Pseudo-random subset of subject file (i.e., arg3)

#########
# Notes:
#########

# Pseudo-randomness: items from S's population are randomly selected **within bins**, not within the entire population, hence the "pseudo" prefix

# Log-transform: binning into log10-transformed is highly recommended e.g. for matching FPKM/RPKM distributions (see `transform` option).

# Re-iteration: it might be necessary to call the script several times sequentially (i.e. input -> output1; output1 -> output2; output2 -> output3, etc.) until reaching an optimum. Here's an example of a wrapper bash script that does just this (100 iterations, 500 bins):

# export passes=100
# ln -s subject.txt output.0.txt
# for i in `seq 1 $passes`; do
# let j=$i-1
# matchDistribution.pl target 500 subject.txt output.$j.txt > output.$i.txt
# rm -f output.$j.txt
# done

# The final output will be in the file named output.$passes.txt

my $transform;
GetOptions (
        'transform=s' => \$transform

        );

our $pseudocount=0.001;

if(defined $transform){
	unless ($transform eq 'log10'){
		die "invalid transform value (must be 'log10')\n";
	}
	print STDERR "Working on $transform - transformed values (with pseudocount = $pseudocount). Output values will be the original, non-transformed ones, though.\n";
}
else{
	$transform='no';
}

# http://stackoverflow.com/questions/1915616/how-can-i-elegantly-call-a-perl-subroutine-whose-name-is-held-in-a-variable
my %transform_subs = (no => \&no,
                      log10 => \&log10
                      );

my $distribToMatch=$ARGV[0]; # one column with values
my $bins=$ARGV[1]; # number of bins to separate the distrib into
my $targetObjectsToSubsampleFrom=$ARGV[2]; # two columns, e.g. column 1 is gene_id, column2 is RPKM
my @origvalues=();

open D, "$distribToMatch" or die $!;

print STDERR "Reading target distribution to mimic...\n";
while(<D>){
	chomp;
	push(@origvalues, $transform_subs{$transform}->($_));
}

#sort array numerically
my @sorted = sort { $a <=> $b } @origvalues;
@origvalues=@sorted;
@sorted=();
close D;

my $min=$origvalues[0];
my $max=$origvalues[$#origvalues];
my $range=$max-$min;
my $binRange=$range/$bins;

print STDERR "Min: $min, Max: $max. Range: $range. Bin range: $binRange\n";

#calculate what fraction of the total each bin represents

my %binSizes=();
for (my $i=$min; $i<=$max; $i+=$binRange){
	my $count=0;
	foreach my $j (@origvalues){
		if($j>=$i && $j<$i+$binRange){
			$count++
		}
		elsif($j>$i+$binRange){
			last;
		}
	}
	$binSizes{$i}=$count/($#origvalues+1);
}
print STDERR "Done...\n";

my %targetIdsToValues=();
my %targetsList=();
print STDERR "Reading subject dataset to sample from...\n";
open T, "$targetObjectsToSubsampleFrom" or die $!;
my %binnedPop=();
my $countValuesWithinRange=0;
while(<T>){
	chomp;
	my @line=split "\t";
	$targetIdsToValues{$line[0]}=$line[1];
	#populate bins
	foreach my $bin (keys %binSizes){
		if($transform_subs{$transform}->($line[1])>=$bin && $transform_subs{$transform}->($line[1])<$bin+$binRange){
			push(@{$binnedPop{$bin}}, $line[0]);
			$countValuesWithinRange++;
			last;
		}

	}
	if ($.%1000000 == 0){
                print STDERR "\tProcessed $. lines\n";
        }
}
close T;
print STDERR "Done...\n";


print STDERR "Found $countValuesWithinRange values within range in $targetObjectsToSubsampleFrom.\n";

foreach my $bin (keys %binnedPop){
	my $size=$#{$binnedPop{$bin}}+1;
	print STDERR "\nbin $bin: N= $size\n";
	print STDERR " Fraction of input: ".$size/$countValuesWithinRange."\n";
	print STDERR " Desired fraction in output: ".$binSizes{$bin}."\n";
	my $numberOfItemsToPick=int($binSizes{$bin}*$countValuesWithinRange);
	$numberOfItemsToPick=$size if ($size<$numberOfItemsToPick);
	print STDERR " Will try to pick $numberOfItemsToPick items at random.\n";
	print STDERR "###### WARNING bin $bin will be of size 0!! (No values available in input)\n" if ($size==0);
	my @shuffled = shuffle(@{$binnedPop{$bin}});
	my @ids=splice(@shuffled, 0, $numberOfItemsToPick);
	foreach my $id (@ids){
		print "$id\t$targetIdsToValues{$id}\n";
	}
}
print STDERR "Done! (You should probably plot the output and target distributions)\n";

sub log10 {
        my $n = shift;
        #add pseudocount
        return log($n+$pseudocount)/log(10);
    }
sub no {
        my $n = shift;
        return $n;
    }