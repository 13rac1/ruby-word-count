#!/usr/bin/env ruby
require 'optparse'

# Handle CTRL-C nicely.
trap("INT") { exit 1}

# Ruby class to duplicate functionality of the GNU coreutils wc program.
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
      #opt.separator "  or:  #{__FILE__} [OPTION]... --files0-from=F"
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

      #opt.on("--files0-from=F", "read input from the files specified by",
      #                          "  NUL-terminated names in file F;",
      #                          "  If F is - then read names from standard input") do |f|
      #  @options[:files0_from] = f
      #end

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

    word_length = 0
    line_length = 0
    # Enable binary read mode.
    ARGF.binmode
    # Store the current file
    current_file = ""
    # Loop through all of the characters in the input files.
    ARGF.chars do |char|
      # If the filename has changed, create a new storage structure.
      if @results[ARGF.filename].nil?
        if current_file!=""
          # Check word and line length before starting the next file.
          @results[current_file][:words] += 1 if word_length > 0
          @results[current_file][:max_length] = line_length if line_length > @results[current_file][:max_length]
        end
        current_file = ARGF.filename
        @results[current_file] = Hash.new(0)
        word_length = 0
        line_length = 0
      end

      @results[current_file][:bytes] += 1
      # FIXME: Count multi-byte characters as one character, separately from bytes.
      @results[current_file][:chars] += 1
      if char == "\n"
        @results[current_file][:lines] += 1
        # If line_length is greater the stored max_length, update it.
        @results[current_file][:max_length] = line_length if line_length > @results[current_file][:max_length]
        # Clear the counter.
        line_length = 0
      end
      # C function isspace() defines whitespace: http://www.cplusplus.com/reference/cctype/isspace/
      if [' ', "\t", "\n", "\v", "\f", "\r"].any? {|ws| ws == char}
        @results[current_file][:words] += 1 if word_length > 0
        word_length = 0
      elsif
        word_length += 1
      end

      line_length += 1
    end
    # Check word and line length after the loop.
    @results[current_file][:words] += 1 if word_length > 0
    @results[current_file][:max_length] = line_length if line_length > @results[current_file][:max_length]

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
