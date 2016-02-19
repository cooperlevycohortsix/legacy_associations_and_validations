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
    assert term.courses.include?(course)
    assert_equal term, course.term
    term.destroy
    refute term.destroyed?
  end


  def test_associate_course_with_course_students_not_deletable_if
    course = Course.create(name: "Metalurgy")
    course_student = CourseStudent.create(student_id: 100)
    course.course_students <<  course_student
    assert course.course_students.include?(course_student)
    assert_equal course, course_student.course
    course.destroy
    refute course.destroyed?

  end

  def test_associate_assignments_with_courses_deletable_if
    course = Course.create(name: "Hermaphroditic_Postulations")
    assignment = Assignment.create(name: "slug_obstetrics")
    course.assignments << assignment
    assert course.assignments.include?(assignment)
    assert_equal assignment, course.assignments.last
    course.destroy
    assert course.destroyed?

  end

  #def test_associates_lessons_with_pre_class_assignments
  #end

  def test_set_school_to_have_many_courses_through_school_terms
    school = School.create(name: "Haavad")
    term = Term.create(name: "Fall")
    c1 = Course.create(name: "Hermaphroditic_Postulations")
    c2 = Course.create(name: "Phrenologystical metapharmacology2")
    c3 = Course.create(name: "history of humor")
    

  end
end
