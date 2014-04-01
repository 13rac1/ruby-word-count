#!/usr/bin/env ruby

require 'optparse'

class WCRuby
  # Program initialization
  def initialize
    # Array to store command line options.
    @options = {}
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
      opt.separator "The options below may be used to select which counts are printed."

      opt.on("-c","--bytes", "print the byte counts") do
        @options[:bytes] = true
      end

      opt.on("-m","--chars", "print the character counts") do
        @options[:chars] = true
      end

      opt.on("-l","--lines", "print the newline counts") do
        @options[:lines] = true
      end

      opt.on("--files0-from=F", "read input from the files specified by",
                                "  NUL-terminated names in file F;",
                                "  If F is - then read names from standard input") do |f|
        @options[:files0-from] = f
      end

      opt.on("-L","--max-line-length", "print the length of the longest line") do
        @options[:max-line-length] = true
      end

      opt.on("-w","--words","print the word counts") do
        @options[:words] = true
      end

      opt.on("-h","--help", "display this help and exit") do
        puts opt_parser
        exit
      end

    end
    opt_parser.parse!
    # FIXME: Implement @option defaults
  end

  # Parse STDIN or file contents to create statistics
  def parse_input
    # Enable binary read mode.
    ARGF.binmode
    # Loop through all of the characters in the input files.
    ARGF.chars do |char|
      if @options[:bytes]
        @bytes += 1
      end
      if @options[:chars]
        @chars += 1
      end
      # FIXME: Handle all new line characters?
      if @options[:lines] && char == "\n"
        @lines += 1
      end
      #@max_line_length = 0    
      if @options[:words] && char == ' '
        @words += 1
      end      
    end    
  end
  
  def display_output
    puts " #{@lines} #{@words} #{@bytes}"
  end

end

# Run the program
wc_ruby = WCRuby.new
