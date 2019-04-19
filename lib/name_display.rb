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
    return unless author.attribute('type')

    value = author.attribute('type').value

    value = author_type if value == 'person' && author_type

    "[#{value}]"
  end

  def role_or_type
    return "[#{author_role}]" if author_role

    type
  end

  def author_type
    author.parent.parent.attribute('type')&.value
  end

  def author_role
    author.parent.parent.attribute('role')&.value
  end

  def display
    [text, title, date, formal, role_or_type].compact.join(' ')
  end
end
