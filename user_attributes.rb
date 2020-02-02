class UserAttributes
  attr_reader :id, :first_name, :last_name, :age

  def initialize(_, id, first_name, last_name, age)
    @id = id
    @first_name = first_name
    @last_name = last_name
    @age = age
  end
end
