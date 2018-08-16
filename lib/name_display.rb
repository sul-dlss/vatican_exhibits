##
# A class used to create a special display from an XML element of Vatican
# flavored TEI
class NameDisplay
  attr_reader :author

  delegate :text, to: :author

  def initialize(author)
    @author = author
  end

  def title
    author.attribute('title')&.value
  end

  def date
    author.attribute('date')&.value
  end

  def formal
    author.attribute('formal')&.value
  end

  def type
    "[#{author.attribute('type').value}]" if author.attribute('type')
  end

  def display
    [text, title, date, formal, type].compact.join(' ')
  end
end
