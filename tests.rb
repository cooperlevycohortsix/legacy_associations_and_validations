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
    course = Course.create(course_code: "ttt666", name: "Biologie")
    term.courses << course
    assert term.courses.include?(course)
    assert_equal term, course.term
    term.destroy
    refute term.destroyed?
  end


  def test_associate_course_with_course_students_not_deletable_if
    course = Course.create(course_code: "yys707", name: "Metalurgy")
    course_student = CourseStudent.create(student_id: 100)
    course.course_students <<  course_student
    assert course.course_students.include?(course_student)
    assert_equal course, course_student.course
    course.destroy
    refute course.destroyed?
    assert Course.find(course.id)

  end

  def test_associate_assignments_with_courses_deletable_if
    course = Course.create(course_code: "yys737", name: "Hermaphroditic_Postulations")
    assignment = Assignment.create(name: "slug_obstetrics")
    course.assignments << assignment
    assert course.assignments.include?(assignment)
    assert_equal assignment, course.assignments.last
    course.destroy
    assert course.destroyed?
  end

  def test_associates_lessons_with_pre_class_assignments
    l = Lesson.create(name: "biostatistics")
    a = Assignment.create(name: "do_crack_cocaine")
    assert l.pre_class_assignment = a
  end

  def test_set_school_to_have_many_courses_through_school_terms
    school = School.create(name: "Haavad")
    term = Term.create(name: "Fall")
    c1 = Course.create(name: "Hermaphroditic_Postulations", course_code: "rrr494")
    school.terms << term
    term.courses << c1
    assert_equal c1, school.courses.last
  end

  def test_lessons_have_names
    new_lesson = Lesson.create(name: "biostatistics")
    assert new_lesson.name
  end

  def test_readings_have_order_numbers_lesson_ids_and_url
    new_reading = Reading.create()
    refute new_reading.valid?
  end

  def test_readings_url_start_with_http_or_https
    nr = Reading.create(url: "https://dantheman.com", order_number: 9999, lesson_id: 5555)
    new_reading = Reading.create()
    assert_equal 1, Reading.first(2).length
  end

  def test_courses_include_course_code_and_name
    nc = Course.create(course_code: "kyy999", name: "metalurgy")
    nc1 = Course.create()
    refute nc1.id
    assert Course.find(nc.id)
  end

  def test_course_code_is_unique_within_a_given_id
    nc = Course.create(course_code: "yyy999", name: "metalurgy")
    nc1 = Course.create(course_code: "yyy999", name: "halitoses")
    new_term2 = Term.create(starts_on: Date.new(2016,2,19), ends_on: Date.new(2016,2,19) >> 3 , school_id: 8)
    new_term2.courses << nc
    new_term2.courses << nc1
    assert Term.find(nc.id)
    refute nc1.id
  end

  def test_course_code_starts_with_three_letters_and_ends_with_three_numbers_using_regex
    nc = Course.create(course_code: "yyp999", name: "metalurgy")
    nc1 = Course.create(course_code: "yy999", name: "halitoses")
    assert Course.find(nc.id)
    refute nc1.id
  end

end
