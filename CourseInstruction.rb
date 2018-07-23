3               # everthing is an object. There is no primitive data type
a = 4

unless 3 == 5   # unless is not equal to 
  puts "3 is not equal to 5"
end

until a>=5      # opposite of while. Prints till he given condition becomes true
  puts "print this statement"
  a += 1
end

puts "Print this" if a == 5 and 3 == 3          # modifier form
a *= 2 while a < 100                            # modifier form

if /sera/ === "coursera"                        # tripple equals
  puts "This works as tripple equals accepts regular expressions"
end

# Case statements, 2 flavors 

case            # 1st flavor. more of an if else version
  when a == 160  
    puts "a is equal to 160"
  when 3 == 3    
    puts "3 is equal to 3" 
  else  
    puts "nothing"
end

case a          # 2nd flavor. tripple equals is used
  when 160  then puts "a is equal to 160"
  when 140  then puts "a is equal to 140"
  else  puts "nothing"
end

# for loops is hardly used. each/times is preferred
for i in 0..2
  puts i
end

# using defined funciton to check if a given vairable is defined
# flag = defined?(doc)          returns the thing passed in/ nil

# factorial methods
# def factorial ( n = 5 )           # n is predefined to 5 if not padded to the function
#   n == 0 ? 1 : n * factorial ( n - 1)
# end

# splat -> def max ( one_param, *multiple_parram_array, third_param )

# delcaring array
arr = %w{ twinkle twinkle little start how i wonder how you are }
cur_weather = %Q{It's a hot day outsiede, 
grab your unblrellas}       # puts the string as is, including new line's


arr.each do |word|
  puts word
end


begin 
  # reading from your file
  File.foreach('EloquetRuby.rb') do |line|
    pp line.chomp
  end
 
rescue Exception => e
  pp e.message
  puts "Lets pretend that this didn't happen"
end

# for writting to a file
# File.open ("File name ", "Mode of reading") do |file_handler|

# Ruby automatically close the file at the end of the block

# accessing environment variables - puts ENV["PATH"]
# symbols are highly optimized strings, without the burdon of extra methods
# symbols are unique and immutable

# Some methods become available only when the object is defined. Done to save space as in Ruby,
# everthing is a symbol

# arrays are object referrences [auto expandable]

# array.sample(2)
# array.sort    /    array.sort!
# array.reverse    /    array.reverse!

# new_arr = a.select { |num| num < 10}.reject{ |num| num.even?}
# new_arr = a.map { |x| x*3 }

# 2 dots - all inclusive 
# 3 dots - last not inclusive [more dots you have, the less you have at the ends]

# p ('k'..'z').to_a.sample(2)   # extract 2 elements from the range k to z

# case age
# when 0..12 then puts "Still a baby"
# when 13..99 then puts "Teenager at heart"

# program to find the frequency of words
words = Hash.new(0)
sentence = "chitty chitty Bang Bang"

sentence.split.each do |word|
  words[word.downcase] += 1
end

pp words


# Class is a blueprint. For each instance of the class, you have instance variables which hold the state of the instace, called instance variables
# upon creating a new instance, the constructor is called to initialize the instance

# getters and setters, class definations ommited.
# def name= (name_value)
#   @name = name_value
# end

# to access the setter, you say, instance_variable.name = "new name. Notice the spaces around the equals are important"

# but simpler, attr_accessor / attr_reader / attr_writer

# namespace is ModuleName::ClassName

# require_relative 'ruby file'      # Basically tells you, relative to this file, tells you
                                    # where you can find the other ruby files to import

# include module_name

# require_relative
# local_variables method tells which methods are currenlty in scope

# values of constants can be changed in the inner scope, although, outside, the value remains unchagned
# array.each do |loop_counter; variables to be initializied to local scope to ensure that global scope is not destroyed |

class Document 

  private                   # Alls methods from here till the next access specifier is private

  def hello_world 
    puts "This is a crazy part of the world"
  end

  private :hello_world      # one way of telling the method is private
end

# For writting Unit Testing code, the class should be a subclass of Test::Unit::TestCase
# require 'test/unit'
# require_relative 'calculator'     # file to be tested

# class CalculatorTest < Test::Unit::TestCase
#   def setup
#     @calc = Calculator.new("test")
#   end  
#   
#   def test_addition
#     assert_equals 4, @calc.add(2,2)
#   end
#   
#   def test_subtraction
#     assert_equals 2, @calc.subtract(4,2)
#   end
#   
#   def test_division
#     assert_equals 2, @calc.divide(4,2)
#   end
# end

# Unit Tests give's you the confidence to refactor your code with confidence
# way to remember the twist involded in Unit Testing. each - expected first and then actual second

# to test conditions that may raise errors, you have assert_raise
# assert_raise ZeroDivisionError do
#   @calc.divide(1,0)
# end

# RSpec - more english like test case's and outputs. Availabe only after rspec init is given
# rspec --init

# require 'rspec'
# require_relative '../calculator'
# 
# describe Calculator do
#   before { @calculator = Calculator.new('RSpec Calculator') }
# 
#   it "should add 2 numbers correctly" do
#     expect(@calculator.add(2,4)).to eq 6
#   end
# 
#   it "should subtract 2 numbers correctly" do
#     expect(@calculator.subtract(4,2)).to eq 2
#   end
# end

# rspec --format documentation      # outputs the conditions it checks for
# More details on RSpec available at https://relishapp.com/rspec

string_input = %q{all your crazy quote marks goes here. Do all you like}    # gets the strict treatement
string_input = %Q{gets the libereal treatement}

heres_documetn =  <<EOF
all you pragraphs worth of content goes here
EOF

# The power of GSUB along with regular expressions. /i is to ignore case

puts "This code will blank out all times 10:52 AM ".gsub!(/\d\d:\d\d (AM|PM)+/i,"**:** **")

# ^ circumflex - matches the beginning of the string / beginning of each line
# $ dollar     - matches the end of each line

# /^Once upon a time.*and they lived happily ever after\.$/   matches a typicall fairy tail