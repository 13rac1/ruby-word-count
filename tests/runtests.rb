#!/usr/bin/env ruby
# Simple unit tests for 'wc.rb' vs the 'wc' provided with Linux.

require 'faker'
# Stop deprecation notice
I18n.config.enforce_available_locales = true

TEMP_FILE = "/tmp/wcrb.txt"

puts "rwc Acceptance Tests"

puts "Generating text to process"
fake_text = Faker::Lorem.paragraphs(10)
File.open(TEMP_FILE, 'w') { |file| fake_text.each { |line| file.write(line) } }

#puts `../bin/rwc --help`

puts fake_text


