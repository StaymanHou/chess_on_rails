class Game < ActiveRecord::Base
  after_initialize :init
  serialize :moves, Array

  def init
    self.moves ||= []
  end
end
