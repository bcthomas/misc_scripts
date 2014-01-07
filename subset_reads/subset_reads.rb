#!/usr/bin/ruby -w
require 'rubygems'
require 'trollop'

PROGRAMNAME="subset_reads.rb"

# defaults
opts = Trollop::options do
  version "0.1"
  banner <<-EOT
Summary:
  #{PROGRAMNAME}: randomly select reads from a FASTQ input(s); Input
                  can be either shuffled or unshuffled FASTQ files.
                  Selected reads can be size filtered.  Subsets can
                  be specified by either the number of reads you want
                  out, or the portion of reads (e.g. 1/10th).  The
                  output file(s) will end in ".sub12345", depending
                  on your subset request.

Synopsis: Shuffled FASTQ input
  #{PROGRAMNAME} --shuffled=<input shuffled FASTQ file>
                 --number=<number or reads to select>

Synopsis: Separate FASTQ inputs
  #{PROGRAMNAME} --forward=<forward/first FASTQ file>
                 --reverse=<reverse/second FASTQ file>
                 --number=<number or reads to select>

Options:

EOT

  opt :shuffled, "shuffled FASTQ file", :type => :string
  opt :forward, "forward FASTQ file", :type => :string
  opt :reverse, "reverse FASTQ file", :type => :string
  opt :number, "number of reads to sample", :type => :integer
  opt :portion, "fraction of the reads to return (e.g. 1/10th is --portion=10)", :type => :integer
  opt :min, "minimum read length (0 = use all reads to sample from)", :type => :integer, :default => 0
  opt :overwrite, "overwrite output if it exists?", :type => :bool, :default => false
  opt :verbose, "give verbose output during run", :type => :bool, :default => false
end

# options 'bool' is optional if left commented out
# Trollop::die :bool, "is required" unless opts[:bool]
if (!opts[:number] and !opts[:portion])
  Trollop::die "ERROR: Need either --number or --portion parameters"
end

if opts[:shuffled]
  Trollop::die :shuffled, "is required" unless opts[:shuffled]
  Trollop::die :shuffled, "file must exist" unless File.exist?(opts[:shuffled])
else
  Trollop::die :forward, "is required" unless opts[:forward]
  Trollop::die :forward, "file must exist" unless File.exist?(opts[:forward])
  Trollop::die :reverse, "is required" unless opts[:reverse]
  Trollop::die :reverse, "file must exist" unless File.exist?(opts[:reverse])
end

def print_random_4(in_f,in_r,out_f,out_r,n,extra,min = 0)
  output_count = 0
  while(!in_f.eof?)
    h1,s1,qh1,q1 = in_f.readline,in_f.readline,in_f.readline,in_f.readline  # first read in pair (4 lines)
    h2,s2,qh2,q2 = in_r.readline,in_r.readline,in_r.readline,in_r.readline  # second read in pair (4 lines)
    if (n == ((in_f.lineno - 4) / 4))
      if min == 0 # not looking for min length reads, just print
        out_f.puts h1
        out_f.puts s1
        out_f.puts qh1
        out_f.puts q1
        out_r.puts h2
        out_r.puts s2
        out_r.puts qh2
        out_r.puts q2
        output_count += 1
        break
      else # make sure reads are good quality
        if s1.length >= min and s2.length >= min
          out_f.puts h1
          out_f.puts s1
          out_f.puts qh1
          out_f.puts q1
          out_r.puts h2
          out_r.puts s2
          out_r.puts qh2
          out_r.puts q2
          output_count += 1
          break
        else
          break
        end
      end
    elsif extra > 0  # if not looking for min length, extra will be 0, so don't need to check if min is nil
      if s1.length >= min and s2.length >= min
        out_f.puts h1
        out_f.puts s1
        out_f.puts qh1
        out_f.puts q1
        out_r.puts h2
        out_r.puts s2
        out_r.puts qh2
        out_r.puts q2
        output_count += 1
        extra -= 1 # note scope; this doesn't change outer extra value
      end
    end # end of if (n == (f.lineno/8))
  end # end of while(!f.eof?)
  output_count
end

def print_random_8(f,out,n,extra,min = 0)
  output_count = 0
  while(!f.eof?)
    h1,s1,qh1,q1 = f.readline,f.readline,f.readline,f.readline  # first read in pair (4 lines)
    h2,s2,qh2,q2 = f.readline,f.readline,f.readline,f.readline  # second read in pair (4 lines)
    if (n == ((f.lineno - 8) / 8))
      if min == 0 # not looking for min length reads, just print
        out.puts h1
        out.puts s1
        out.puts qh1
        out.puts q1
        out.puts h2
        out.puts s2
        out.puts qh2
        out.puts q2
        output_count += 1
        break
      else # make sure reads are good quality
        if s1.length >= min and s2.length >= min
          out.puts h1
          out.puts s1
          out.puts qh1
          out.puts q1
          out.puts h2
          out.puts s2
          out.puts qh2
          out.puts q2
          output_count += 1
          break
        else
          break
        end
      end
    elsif extra > 0  # if not looking for min length, extra will be 0, so don't need to check if min is nil
      if s1.length >= min and s2.length >= min
        out.puts h1
        out.puts s1
        out.puts qh1
        out.puts q1
        out.puts h2
        out.puts s2
        out.puts qh2
        out.puts q2
        output_count += 1
        extra -= 1 # note scope; this doesn't change outer extra value
      end
    end # end of if (n == (f.lineno/8))
  end # end of while(!f.eof?)
  output_count
end

if opts[:shuffled]
  $stderr.puts "processing shuffled input #{opts[:shuffled]}" if opts[:verbose]
  total_lines = `wc -l #{opts[:shuffled]}`.chomp!.to_i
  total_reads = (0 .. (total_lines/8 - 1)).to_a
  $stderr.puts "Total reads in file: #{total_reads.length * 2} (#{total_reads.length} pairs)" if opts[:verbose]

  if opts[:portion]
    opts[:number] = (total_reads.length * 2) / opts[:portion]
    $stderr.puts "Setting number of reads to #{opts[:number]} based on portion of 1/#{opts[:portion]}" if opts[:verbose]
  end

  if opts[:number] % 2 != 0
    $stderr.puts "requested number of reads is odd: adding 1 to #{opts[:number]}"
    opts[:number] += 1
  end

  if opts[:number] > (total_reads.length * 2)
    $stderr.puts "ERROR: requested number of random entries (#{opts[:number]}) is larger than the number of entries in the file!"
    exit(1)
  end

  randoms = Hash.new {|h,k| h[k] = 0} # default to values of 0
  # opts[:number]/2 because already shuffled, so only need half the number of randoms (gotta keep pairs!)
  total_reads.sample(opts[:number]/2).each {|x| randoms[x]}
  $stderr.puts "Created sample from total reads of size: #{randoms.length} read pairs (#{randoms.length * 2} reads)" if opts[:verbose]

  outfile = "#{opts[:shuffled]}.sub#{opts[:number]}"
  if opts[:portion]
    outfile = "#{opts[:shuffled]}.sub#{opts[:portion]}"
  end
  if File.exist?(outfile) and !opts[:overwrite]
    $stderr.puts "ERROR: outfile #{outfile} already exists!  Use --overwrite flag to force overwrite"
    exit(1)
  end

  selected = 0
  out = File.open(outfile,"w")
  f = File.open(opts[:shuffled])         # open input file
  extra = 0                              # track the number of new randoms needed
  randoms.sort.each do |x,v|
    ocount = print_random_8(f,out,x,extra,opts[:min])
    if ocount == 0
      extra += 1
    elsif ocount == 1
      selected += 2
    else # more than one output!
      selected += (ocount * 2)
      extra -= (ocount - 1)
    end
  end

  if extra > 0 # there are missing numbers
    while (extra > 0)
      break if f.eof?
      ocount = print_random_8(f,out,-1,extra,opts[:min])
      if ocount == 1
        selected += 2
      elsif ocount > 1
        selected += (ocount * 2)
        extra -= (ocount - 1)
      end
    end
  end

  f.close
  out.close
  if selected != opts[:number]
    $stderr.puts "ERROR: requested number of reads (#{opts[:number]}) does not equal output count (#{selected})"
    $stderr.puts "(this could be due to --min being set too stringently for the overall quality of your reads"
    exit(1)
  end

else # not shuffled ############################

  $stderr.puts "processing unshuffled input files #{opts[:forward]} - #{opts[:reverse]}" if opts[:verbose]
  total_lines = `wc -l #{opts[:forward]}`.chomp!.to_i # assume files are same size, don't check to save time
  total_reads = (0 .. (total_lines/4 - 1)).to_a
  $stderr.puts "Total reads in both files: #{total_reads.length * 2} (#{total_reads.length} pairs)" if opts[:verbose]

  if opts[:portion]
    opts[:number] = (total_reads.length / opts[:portion]) * 2
    $stderr.puts "Setting number of reads to #{opts[:number]} based on portion of 1/#{opts[:portion]}" if opts[:verbose]
  end

  if opts[:number] % 2 != 0
    $stderr.puts "requested number of reads is odd: adding 1 to #{opts[:number]}"
    opts[:number] += 1
  end

  if opts[:number] / 2 > total_reads.length
    $stderr.puts "ERROR: requested number of random entries (#{opts[:number] / 2}) is larger than the number of entries in the file!"
    exit(1)
  end

  randoms = Hash.new {|h,k| h[k] = 0}
  # opts[:number]/2 because we doubled above to account for each file (gotta keep pairs!)
  total_reads.sample(opts[:number]/2).each {|x| randoms[x]}
  $stderr.puts "Created sample from total reads of size: #{randoms.length} read pairs (#{randoms.length * 2} reads)" if opts[:verbose]

  outfile_f = "#{opts[:forward]}.sub#{opts[:number]}"
  outfile_r = "#{opts[:reverse]}.sub#{opts[:number]}"
  if opts[:portion]
    outfile_f = "#{opts[:forward]}.sub#{opts[:portion]}"
    outfile_r = "#{opts[:reverse]}.sub#{opts[:portion]}"
  end
  if File.exist?(outfile_f) and !opts[:overwrite]
    $stderr.puts "ERROR: outfile #{outfile_f} already exists!  Use --overwrite flag to force overwrite"
    exit(1)
  end
  if File.exist?(outfile_r) and !opts[:overwrite]
    $stderr.puts "ERROR: outfile #{outfile_r} already exists!  Use --overwrite flag to force overwrite"
    exit(1)
  end

  selected = 0
  out_f = File.open(outfile_f,"w")
  out_r = File.open(outfile_r,"w")
  in_f = File.open(opts[:forward])         # open file
  in_r = File.open(opts[:reverse])         # open file
  extra = 0
  randoms.sort.each do |x,v|
    ocount = print_random_4(in_f,in_r,out_f,out_r,x,extra,opts[:min])
    if ocount == 0
      extra += 1
    elsif ocount == 1
      selected += 2
    else # more than one output!
      selected += (ocount * 2)
      extra -= (ocount - 1)
    end
  end

  if extra > 0 # there are missing numbers
    while (extra > 0)
      break if in_f.eof?
      ocount = print_random_4(in_f,in_r,out_f,out_r,-1,extra,opts[:min])
      if ocount == 1
        selected += 2
      elsif ocount > 1
        selected += (ocount * 2)
        extra -= (ocount - 1)
      end
    end
  end

  in_f.close
  in_r.close
  out_f.close
  out_r.close
  if selected != opts[:number]
    $stderr.puts "ERROR: requested number of reads (#{opts[:number]}) does not equal output (#{selected})!"
    exit(1)
  end
end
