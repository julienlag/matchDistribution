# NAME

matchDistribution

# SYNOPSIS

Given distinct **"subject" (S)** and a **"target" (T)** distributions, this script attempts to mimic T's density (_i.e._, its shape) by randomly sampling from bins in S's population.

**Usage**: `matchDistribution.pl <OPTIONS> <arg1> <arg2> <arg3>`

## ARGUMENTS/INPUT

- **arg1**: Path to file containing T's values (1 column, 1 value per line).
- **arg2**: Number of bins to split the distributions into.
- **arg3**: Path to tab-separated file containing S's identifiers and values (column 1: unique identifier; column 2: corresponding value).

## OPTIONS

- **transform** (string)
= bin transform-transformed values in both distributions. Output values will be the original, non-transformed ones, though.

    Possible values: 'log10' only.

    Note: binning into log10-transformed is highly recommended e.g. for matching FPKM/RPKM distributions.

- **verbose**
= make STDERR more verbose

## OUTPUT

To STDOUT.

The script will output a pseudo-random subset of the subject file (_i.e._, arg3), such that its distribution matches T's density as closely as possible.

# DESCRIPTION

Given distinct **"subject" (S)** and a **"target" (T)** distributions, this script attempts to mimic T's density (_i.e._, its shape) by pseudo-randomly sampling from S's population.

Warning: The script attempts to match T's density only, not its population size.

IMPORTANT NOTES

- **"Pseudo-randomness"**

    Items from S's population are randomly selected within bins, not within the entire population, hence the "pseudo" prefix

- **Number of bins to choose**

    Usually the more, the better.

- **Log-transform**

    Binning into log10-transformed is highly recommended _e.g._ for matching FPKM/RPKM distributions (see transform option).

- **Re-iteration**

    It might be necessary to call the script several times sequentially (_i.e._ input -> output1; output1 -> output2; output2 -> output3, etc., where "->" denotes a matchDistribution call) until reaching an optimum.
    This is what the accompanying **matchDistributionLoop.sh** script does (see below).

# RE-ITERATIONS

Use **matchDistributionLoop.sh** and **matchDistributionKStest.r**. Both scripts need to be in your $PATH.
**Usage**: `matchDistributionLoop.sh <passes> <doKolmogorov-Smirnov> <target> <subject> <bins> <breakIfKSTest>`

Where:

- **passes** (int): Maximum number of passes to perform
- **doKolmogorov-Smirnov** (0|1 boolean): Toggle do KS test on resulting distributions after each pass, and print p-value. This will call **matchDistributionKStest.r** (courtesy of Andres Lanzos, CRG).
- **target** (string): Path to file containing T's values.
- **subject** (string): Path to tab-separated file containing S's identifiers and values.
- **bins** (int): Number of bins to split the distributions into.
- **breakIfKSTest** (0|1 boolean): break loop if KS test gives p>0.05 (_i.e._, before reaching the maximum number of passes).

# DEPENDENCIES

CPAN: List::Util 'shuffle'

# AUTHOR

Julien Lagarde, CRG, Barcelona, contact julienlag@gmail.com
