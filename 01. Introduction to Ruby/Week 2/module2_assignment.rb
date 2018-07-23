class LineAnalyzer

  attr_reader :highest_wf_count, :highest_wf_words, :content, :line_number

  def initialize (content, line_number)
    content = content.split(" ")
    @content = Hash.new(0)
    @highest_wf_count = []
    @highest_wf_words = []
    @line_number = line_number

    content.each { |word| @content[word.downcase] += 1 }
  end   # End initialize here


  def calculate_word_frequency 
    @content = @content.sort_by { |word, count| count }.reverse
    @content.each do |word, count|
      if (@highest_wf_count[0] == nil) or (count >= @highest_wf_count[-1])
        @highest_wf_words.push(word)
        @highest_wf_count.push(count)
      else
        break
      end
    end # End @content.each loop here
  end   # End Calculate_word_frequency here
end


class Solution
  attr_reader :analyzers, :highest_count_across_lines, :highest_count_words_across_lines

  def initialize 
    @highest_count_across_lines = []
    @highest_count_words_across_lines = []
    @analyzers = []

    self.analyze_file
  end

  def analyze_file
    line_number = 0
    begin 
      File.open("test.txt", "r") do |file_handle|
        file_handle.each do |line|
          line = LineAnalyzer.new(line, line_number)
          line.calculate_word_frequency
          line_number += 1
          @analyzers.push(line)
        end
      end
    rescue Exception => e
      puts "Ouch. Let us assume that this did not happen"
      pp e
    end
  end

  def calculate_line_with_highest_frequency
    @analyzers.each do |line_handle|
      @highest_count_across_lines.push(line_handle.highest_wf_count)
      @highest_count_words_across_lines.push(line_handle.highest_wf_words)
    end
  end

  def print_highest_word_frequency_across_lines 
    puts "The following words have the highest word frequency per line"
    
    for line_number in 0...@analyzers.length
      puts "#{@highest_count_words_across_lines[line_number]} \t\t\t\t\t(appears in line #{line_number})"
    end
  end
end

solution_handle = Solution.new()
solution_handle.calculate_line_with_highest_frequency
solution_handle.print_highest_word_frequency_across_lines