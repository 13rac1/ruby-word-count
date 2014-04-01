#!/usr/bin/env ruby

require 'optparse'

class WCRuby
  # Program initialization
  def initialize
    # Hash to store command line options.
    @options = {}
    # Hash of results keyed by filename
    @results = {}

    # Run the program
    parse_options
    parse_input
    display_output
    # Exit with success
    exit 0
  end

  # Parse command line input into @option array.
  def parse_options
    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{__FILE__} [OPTION]... [FILE}..."
      opt.separator "  or: #{__FILE__} [OPTION]... --files0-from=F"
      opt.separator "Print newline, word, and byte counts for each FILE, and a total line if"
      opt.separator "more than one FILE is specified.  With no FILE, or when FILE is -,"
      opt.separator "read standard input.  A word is a non-zero-length sequence of characters"
      opt.separator "delimited by white space."
      opt.separator "The options below may be used to select which counts are printed, always in"
      opt.separator "the following order: newline, word, character, byte, maximum line length."

      opt.on("-c", "--bytes", "print the byte counts") do
        @options[:bytes] = true
      end

      opt.on("-m", "--chars", "print the character counts") do
        @options[:chars] = true
      end

      opt.on("-l", "--lines", "print the newline counts") do
        @options[:lines] = true
      end

      opt.on("--files0-from=F", "read input from the files specified by",
                                "  NUL-terminated names in file F;",
                                "  If F is - then read names from standard input") do |f|
        @options[:files0-from] = f
      end

      opt.on("-L", "--max-line-length", "print the length of the longest line") do
        @options[:max-line-length] = true
      end

      opt.on("-w", "--words","print the word counts") do
        @options[:words] = true
      end

      opt.on("-h", "--help", "display this help and exit") do
        puts opt_parser
        exit
      end
    end

    # Parse options into @options or fail.
    begin
      opt_parser.parse!
    rescue OptionParser::InvalidOption => e
      puts "#{__FILE__}: #{e}"
      puts "Try '#{__FILE__} --help' for more information."
      exit 1
    end

    # If no command line options have been set, provide the defaults.
    if @options.count() == 0
      @options[:lines] = true
      @options[:words] = true
      @options[:bytes] = true
    end
  end

  # Parse STDIN or file contents to create statistics
  def parse_input
    # Enable binary read mode.
    ARGF.binmode

    current_file = ARGF.filename
    @results[ARGF.filename] = WCRubyResults.new

    # Loop through all of the characters in the input files.
    ARGF.chars do |char|
      # If the filename has changed, create a new storage structure.
      if current_file != ARGF.filename
        @results[ARGF.filename] = WCRubyResults.new
      end

      if @options[:bytes]
        @results[ARGF.filename].bytes += 1
      end
      if @options[:chars]
        @results[ARGF.filename].chars += 1
      end
      # FIXME: Handle all new line characters?
      if @options[:lines] && char == "\n"
        @results[ARGF.filename].lines += 1
      end
      #@max_line_length = 0
      if @options[:words] && char == ' '
        @results[ARGF.filename].words += 1
      end
    end
  end

  def display_output
    @results.each { |file, result|
      puts " #{result.lines} #{result.words} #{result.bytes} #{file}"
    }
    exit 0
  end

end

# Data structure to store result data per file
class WCRubyResults
  attr_accessor :bytes
  attr_accessor :chars
  attr_accessor :lines
  attr_accessor :max_line_length
  attr_accessor :words

  def initialize
    # Integer byte count
    @bytes = 0
    # Integer character count
    @chars = 0
    # Integer line count
    @lines = 0
    # Integer max line length
    @max_line_length = 0
    # Integer word count
    @words = 0
  end
end

# Run the program
wc_ruby = WCRuby.new
