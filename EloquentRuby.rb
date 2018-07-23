class Document 
  attr_accessor :title, :author, :content

  def initialize(title, author, content)
    @title = title
    @author = author
    @content = content
  end

  def authors
    @author.split
  end

  def word_count
    words.size
  end
end

doc = Document.new ("As you like it", "Shakesphere", "This is from the old days")
p doc