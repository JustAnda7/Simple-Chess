class Human
  attr_accessor :color

  def initialize(color)
    @color = color
  end

  def to_s
    color
  end
end
