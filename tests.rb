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

  def test_associate_schools_with_terms
     school = School.create(name: "Haavad")
     term = Term.create(name: "Fall")
     school.add_term(term)
     assert school.terms.include?(term)
     assert_equal school, term.school

  end

  def test_terms_with_courses
      term = Term.create(name: "Fall")
      course = Course.create(name: "Biologie")
      term.add_course(course)
      assert term.courses.include?(course)
      assert_equal term, course.term
  end




end
