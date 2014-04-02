#!/usr/bin/env ruby

require 'optparse'

# Handle CTRL-C nicely.
trap("INT") { exit 1}

class WCRuby
  # Program initialization
  def initialize
    # Run the program
    parse_options
    parse_input
    parse_output
    display_output
    # Exit with success
    exit 0
  end

  # Parse command line input into @option array.
  def parse_options
    # Hash to store command line options.
    @options = Hash.new
    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{__FILE__} [OPTION]... [FILE}..."
      opt.separator "  or:  #{__FILE__} [OPTION]... --files0-from=F"
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
        @options[:files0_from] = f
      end

      opt.on("-L", "--max-line-length", "print the length of the longest line") do
        @options[:max_length] = true
      end

      opt.on("-w", "--words","print the word counts") do
        @options[:words] = true
      end

      opt.on("-h", "--help", "display this help and exit") do
        puts opt_parser
        exit 0
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
    # Hash of results keyed by filename
    @results = Hash.new

    # Enable binary read mode.
    ARGF.binmode
    # Loop through all of the characters in the input files.
    ARGF.chars do |char|
      # If the filename has changed, create a new storage structure.
      @results[ARGF.filename] ||= Hash.new(0)

      if @options[:bytes]
        @results[ARGF.filename][:bytes] += 1
      end
      if @options[:chars]
        # FIXME: Count only characters, not all bytes.
        @results[ARGF.filename][:chars] += 1
      end
      # FIXME: Handle all new line characters?
      if @options[:lines] && char == "\n"
        @results[ARGF.filename][:lines] += 1
      end
      #@max_line_length = 0
      if @options[:words] && char == ' '
        @results[ARGF.filename][:words] += 1
      end
    end
  end

  # Parse the results for display
  def parse_output
    # If more than one file was processed, calculate the totals.
    if @results.count > 1
      # Hash totals keyed by type (column)
      @total = Hash.new(0)
      # Calculate totals
      @results.each do |file, result|
        @total[:bytes] += result[:bytes];
        @total[:chars] += result[:chars];
        @total[:lines] += result[:lines];
        @total[:words] += result[:words];
        @total[:max_length] = result[:max_length] if result[:max_length] > @total[:max_length]
      end
      # Add the total hash to the results for display.
      @results['total'] = @total
    end

    @column_width = 0
    # Calculate column width by finding the max character width of the values.
    @results.each do |file, result|
      result.each do |key, value|
        width = value.to_s.length
        @column_width = width if width > @column_width
      end
    end
  end

  # Display the results
  def display_output
    # The printf format to print decimals using @column_width spaces.
    column_format = "%" + @column_width.to_s + "d"
    # Display the results, one line per file plus totals.
    @results.each do |file, result|
      # Print order: newline, word, character, byte, maximum line length
      print_order = [:lines, :words, :chars, :bytes, :max_length]

      # Count the number of columns being printed.
      column_count = 0
      print_order.each do |key|
        if @options[key]
          column_count += 1
          print sprintf(column_format, result[key]) + " "
        end
      end
      puts file
    end

    exit 0
  end

end

# Run the program
wc_ruby = WCRuby.new
