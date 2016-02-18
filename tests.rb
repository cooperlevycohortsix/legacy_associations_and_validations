# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'byebug'
# Include both the migration and the app itself
require './migration'
require './application'
require './school'
require './term'

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
     school.terms << term
     assert school.terms.include?(term)
     assert_equal school, term.school

  end

  def test_associate_terms_with_courses_not_deletable_if
      term = Term.create(name: "Fall")
      course = Course.create(name: "Biologie")
      term.courses << course
      term.destroy
      refute term.destroyed?
  end


  def test_associate_course_with_course_students_not_deletable_if
      course = Course.create(name: "Metalurgy")
      course_student = CourseStudent.create(student_id: 100)
      course.course_students <<  course_student
      course.destroy
      refute course.destroyed?

  end

  def 



end
