# matchDistribution
Given distinct **"subject" (S)** and a **"target" (T)** distributions, this script attempts to mimic T's density (i.e., its shape) by pseudo-randomly sampling from S's population.

**Warning**: The script attempts to match T's density only, not its population size.

## Arguments/Input

* Argument 1

    Path to file containing T's values (1 column, 1 value per line)

* Argument 2

    Number of bins to split the distributions into

* Argument 3

    Path to tab-separated file containing S's identifiers and values (column 1: unique identifier; column 2: corresponding value)


## Options

* `transform` (string)

  = bin `transform`-transformed values in both distributions. Output values will be the original, non-transformed ones, though. 

  **Possible values**: 'log10' only. 

  **Note**: binning into log10-transformed is highly recommended e.g. for matching FPKM/RPKM distributions.

## Output (to standard output)
The script will output a pseudo-random subset of the subject file (i.e., Argument 3), such that its distribution matches T's density as closely as possible.


## Dependencies (CPAN)
List::Util 'shuffle'

## Example run

`$ matchDistribution.pl target.txt 500 subject.txt > output.txt`

## Important notes

* Pseudo-randomness

  Items from S's population are randomly selected **within bins**, not within the entire population, hence the "pseudo" prefix

* Log-transform

  Binning into log10-transformed is highly recommended e.g. for matching FPKM/RPKM distributions (see `transform` option).

* Re-iteration

  It might be necessary to call the script several times sequentially (i.e. input -> output1; output1 -> output2; output2 -> output3, etc.) until reaching an optimum. 

  Here's an example of a wrapper bash script that does just this (100 iterations, 500 bins):

  ```
  export passes=100
  ln -s subject.txt output.0.txt
  for i in `seq 1 $passes`; do
  let j=$i-1
  matchDistribution.pl target.txt 500 output.$j.txt > output.$i.txt
  rm -f output.$j.txt
  done
  ```

  The final output will be in the file named output.$passes.txt



## Author
Julien Lagarde, CRG, Barcelona, contact julienlag@gmail.com
