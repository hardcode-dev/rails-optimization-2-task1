class User
  attr_reader :attributes, :sessions, :full_name

  def initialize(attributes, sessions)
    @attributes = attributes
    @sessions = sessions
    @full_name = "#{attributes.first_name} #{attributes.last_name}"
  end
end
