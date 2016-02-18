class School < ActiveRecord::Base
has_many :terms

  default_scope { order('name') }

  def add_term(new_term)
    terms << new_term
  end

end
