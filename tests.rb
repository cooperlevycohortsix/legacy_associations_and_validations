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

  def test_associate_lessons_with_readings
    lesson = Lesson.create(name: "Basketweaving")
    reading = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)

    lesson.readings << reading
    assert_equal [reading], Lesson.last.readings
  end

  def test_readings_removed_when_lessons_destroyed
    lesson = Lesson.new(name: "Basketweaving")
    reading = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)

    lesson.readings << reading
    lesson.destroy
    refute reading.id
  end

  def test_courses_are_associated_with_lessons
    course1 = Course.create(name: "Basketweaving 101", course_code: "Eng106")
    lesson1 = Lesson.create(name: "Basketweaving as a means of social engineering")

    course1.lessons << lesson1
    assert Course.find(lesson1.id)
  end

  def test_a_course_can_not_be_destroyed_if_course_instructors_exit
    output = ""
    course = Course.create(name: "Basketweaving 101", course_code: "Eng101")
    course_instructor = CourseInstructor.create
    course.course_instructors << course_instructor
    begin
      course.destroy
    rescue
      output = "can't destroy"
    end
    assert "can't destroy", output
  end

  def test_associate_lessons_with_in_class_assignments
    course = Course.create(name: "Basketweaving 101", course_code: "Eng101")
    lesson = Lesson.create(name: "Basketweaving as a means of social engineering")
    assignment = Assignment.create(name: "Make the test pass",  percent_of_grade: 0.8)
    course.assignments << assignment
    assert assignment.in_class_assignments << lesson
  end

  def test_course_has_many_readings_through_lessons
    course = Course.create(name: "Basketweaving", course_code: "Eng101")
    reading3 = Reading.create(caption: "tasty pages", url: "https://goodread.com", order_number: 1)
    lesson3 = Lesson.create(name: "Basketweaving as a means of social engineering")
    course.lessons << lesson3
    lesson3.readings << reading3
    assert Course.find(reading3.id)
  end

  def test_schools_must_have_a_name
    new_school = School.create(name: "Harvard")
    school = School.new()
    assert School.find(new_school.id)
    refute school.save
  end

  def test_terms_must_have_name_starts_on_ends_on_and_school_id
    new_term1 = Term.new()
    refute new_term1.save
  end

  def test_user_has_a_first_name_a_last_name_and_an_email
    person = User.new()
    person2 = User.create(first_name: "Bill", last_name: "Colander", email: "bill99@gmail.com")
    assert User.find(person2.id)
    refute person.save
  end

  def test_that_the_users_email_is_unique
    person1 = User.create(first_name: "Bill", last_name: "Colander", email: "bill@gmail.com")
    person2 = User.create(first_name: "Sally", last_name: "Smith", email: "bill@gmail.com", photo_url: "https://lookatmypicture.com")
    assert_raises do person2.save! end
    person1.save!
  end

  def test_users_email_is_formatted_correctly
    person1 = User.new(first_name: "Bill", last_name: "Colander", email: "bill1@gmail.com", photo_url: "https://lookatmypicture.com")
    person2 = User.new(first_name: "Sally", last_name: "Smith", email: "billgmailcom")
    assert_raises do person2.save! end
    person1.save!
  end

  def test_associate_schools_with_terms
    school = School.create(name: "Haavad")
    term = Term.create(name: "Fall", starts_on: Time.new(2001,2,3).to_date, ends_on: Time.new(2001,5,3).to_date, school_id: nil)
    school.terms << term
    assert school.terms.include?(term)
    assert_equal school, term.school

  end

  def test_associate_terms_with_courses_not_deletable_if
    term = Term.create(name: "Winter", starts_on: Time.new(2001,2,3).to_date, ends_on: Time.new(2001,5,3).to_date, school_id: nil)
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
    course = Course.create(course_code: "yys737", name: "Hermaphroditic_Postulations")
    lesson = Lesson.create(name: "biostatistics")
    assignment = Assignment.create(name: "do_crack_cocaine")
    course.assignments << assignment
    assert assignment.in_class_assignments << lesson
  end

  def test_set_school_to_have_many_courses_through_school_terms
    school = School.create(name: "Haavad")
    term = Term.create(name: "Summer", starts_on: Time.new(2001,2,3).to_date, ends_on: Time.new(2001,5,3).to_date, school_id: nil)
    c1 = Course.create(name: "Hermaphroditic_Postulations", course_code: "rrr494")
    school.terms << term
    term.courses << c1
    assert Course.find(c1.id)
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
    new_reading = Reading.create(url: "htutps://dantheman", order_number: 4567, lesson_id: 4543)
    assert Reading.find(nr.id)
    refute new_reading.id
  end

  def test_courses_include_course_code_and_name
    nc = Course.create(course_code: "kyy999", name: "metalurgy")
    nc1 = Course.create()
    refute nc1.id
    assert Course.find(nc.id)
  end

  def test_course_code_is_unique_within_a_given_id
    nc = Course.create(course_code: "yyy999", name: "metalurgy", term_id: 1)
    nc1 = Course.create(course_code: "yyy999", name: "halitoses", term_id: 1)
    refute nc1.id
  end

  def test_course_code_starts_with_three_letters_and_ends_with_three_numbers_using_regex
    nc = Course.create(course_code: "yyp999", name: "metalurgy")
    nc1 = Course.create(course_code: "yy999", name: "halitoses")
    assert Course.find(nc.id)
    refute nc1.id
  end

  def test_users_photo_url_is_formatted_correctly
    person1 = User.new(first_name: "Bill", last_name: "Colander", email: "bill2@gmail.com", photo_url: "https://lookatmypicture.com")
    person2 = User.new(first_name: "Sally", last_name: "Smith", email: "billgmailcom", photo_url: "htxl:/lookatme.com")
    assert person1.save
    refute person2.save
  end

  def test_Assignments_have_a_course_id_name_and_percent_of_grade
    assignment = Assignment.create(name: "Make the test pass", course_id: 8, percent_of_grade: 0.80)
    new_assignment = Assignment.new()
    assert Assignment.find(assignment.id)
    refute new_assignment.id
  end

  def test_assignment_name_is_unique_within_a_given_course_id
    course = Course.create(name: "Basketweaving 101", course_code: "Eng101")
    assignment = Assignment.create(name: "Make the test pass",  percent_of_grade: 0.8)
    new_assignment = Assignment.create(name: "Make the test pass", percent_of_grade: 0.8)
    course.assignments << assignment
    course.assignments << new_assignment
    refute new_assignment.id
  end

  # def test_coursestudents_are_associated_with_students
  #   person1 = User.create(first_name: "Will", last_name: "Engles", email: "will@gmail.com", photo_url: "https://checkmeout.com")
  #   student1 = CourseStudent.create(created_at: DateTime.now)
  #   assert
  # end


end
