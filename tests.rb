# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end


  # def test_associate_school_with_terms
  #   s = School.new(name: "Haavad")
  #   t = Term.new(name: "Fall")
  #   assert s.terms << t
  #   assert_equal "Haavad", t.school_name
  # end

  def test_associate_lessons_with_readings
    l = Lesson.create(name: "Basketweaving")
    r = Reading.create(caption: "good read", url: "https//goodread.com", order_number: 1)
    l.add_readings(r)
    assert_equal r, l.readings.last
  end

  def test_lessons_readings_removed_when_lessons_destroyed
    l = Lesson.new(name: "Basketweaving")
    r = Reading.create(caption: "good read", url: "https//goodread.com", order_number: 1)
    l.add_readings(r)
    l.destroy
    assert r.destroyed?
  end

end
