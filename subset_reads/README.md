subset_reads.rb
============

Summary:
  subset_reads.rb: randomly select reads from a FASTQ input(s); Input
                  can be either shuffled or unshuffled FASTQ files.
                  Selected reads can be size filtered.  Subsets can
                  be specified by either the number of reads you want
                  out, or the portion of reads (e.g. 1/10th).  The
                  output file(s) will end in ".sub12345", depending
                  on your subset request.

Installation: subset_reads.rb depends on the ruby 'trollop' gem.

Synopsis: Shuffled FASTQ input
  subset_reads.rb --shuffled=<input shuffled FASTQ file>
                 --number=<number or reads to select>

Synopsis: Separate FASTQ inputs
  subset_reads.rb --forward=<forward/first FASTQ file>
                 --reverse=<reverse/second FASTQ file>
                 --number=<number or reads to select>

Options:
  --shuffled, -s <s>:   shuffled FASTQ file
   --forward, -f <s>:   forward FASTQ file
   --reverse, -r <s>:   reverse FASTQ file
    --number, -n <i>:   number of reads to sample
   --portion, -p <i>:   fraction of the reads to return (e.g. 1/10th is
                        --portion=10)
       --min, -m <i>:   minimum read length (0 = use all reads to sample from)
                        (default: 0)
     --overwrite, -o:   overwrite output if it exists?
       --verbose, -v:   give verbose output during run
       --version, -e:   Print version and exit
          --help, -h:   Show this message
