# NAME

matchDistribution

# SYNOPSIS

Given distinct "subject" (S) and a "target" (T) distributions, this script attempts to mimic T's density (i.e., its shape) by pseudo-randomly sampling from S's population.

matchDistribution.pl <OPTIONS> &lt;arg1> &lt;arg2> &lt;arg3>

## ARGUMENTS/INPUT

\- arg1: Path to file containing T's values (1 column, 1 value per line).

\- arg2: Number of bins to split the distributions into.

\- arg3: Path to tab-separated file containing S's identifiers and values (column 1: unique identifier; column 2: corresponding value).

## OPTIONS

\- transform (string)
    = bin transform-transformed values in both distributions. Output values will be the original, non-transformed ones, though.

Possible values: 'log10' only.

Note: binning into log10-transformed is highly recommended e.g. for matching FPKM/RPKM distributions.

\- verbose
	= make STDERR more verbose

## OUTPUT

To STDOUT.

The script will output a pseudo-random subset of the subject file (i.e., arg3), such that its distribution matches T's density as closely as possible.

# DESCRIPTION

Given distinct **"subject" (S)** and a **"target" (T)** distributions, this script attempts to mimic T's density (i.e., its shape) by pseudo-randomly1 sampling from S's population.

Warning: The script attempts to match T's density only, not its population size.

IMPORTANT NOTES

\- "Pseudo-randomness"

Items from S's population are randomly selected within bins, not within the entire population, hence the "pseudo" prefix

\- Log-transform

Binning into log10-transformed is highly recommended e.g. for matching FPKM/RPKM distributions (see transform option).

\- Re-iteration

It might be necessary to call the script several times sequentially (i.e. input -> output1; output1 -> output2; output2 -> output3, etc., where "->" denotes a matchDistribution call) until reaching an optimum.
This is what the accompanying **matchDistributionLoop.sh** script does (see below)

# RE-ITERATIONS

Use **matchDistributionLoop.sh** and **matchDistributionKStest.r**. Both scripts need to be in your $PATH.

matchDistributionLoop.sh &lt;passes> &lt;doKolmogorov-Smirnov> &lt;target> &lt;subject> &lt;bins> &lt;breakIfKSTest>

Where:

&lt;passes> (int): Maximum number of passes to perform

&lt;doKolmogorov-Smirnov> (0|1 boolean): Toggle do KS test on resulting distributions after each pass, and print p-value. This will call **matchDistributionKStest.r** (courtesy of Andres Lanzos, CRG).

&lt;target> (string): Path to file containing T's values.

&lt;subject> (string): Path to tab-separated file containing S's identifiers and values.

&lt;bins> (int): Number of bins to split the distributions into.

&lt;breakIfKSTest> (0|1 boolean): break loop if KS test gives p>0.05 (i.e., before reaching the maximum number of passes)

# DEPENDENCIES

CPAN: List::Util 'shuffle'

# AUTHOR

Julien Lagarde, CRG, Barcelona, contact julienlag@gmail.com
