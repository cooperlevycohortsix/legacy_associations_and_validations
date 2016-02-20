# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'byebug'
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

  def test_associate_lessons_with_readings
    lesson = Lesson.create(name: "Basketweaving")
    reading = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)
    lesson.add_readings(reading)
    assert_equal reading, lesson.readings.last
  end

  def test_lessons_readings_removed_when_lessons_destroyed
    lesson = Lesson.new(name: "Basketweaving")
    reading = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)
    lesson.add_readings(reading)
    lesson.destroy
    assert reading.destroyed?
  end

  def test_courses_are_associated_with_lessons
    course = Course.create(name: "Basketweaving 101", course_code: "Eng101")
    lesson = Lesson.create(name: "Basketweaving as a means of social engineering")
    course.add_lessons(lesson)
    assert_equal lesson, course.lessons.last
  end

  def test_a_course_can_not_be_destroyed_if_course_instructors_exit
    output = ""
    course = Course.create(name: "Basketweaving 101", course_code: "Eng101")
    course_instructor = CourseInstructor.create
    course.add_course_instructor(course_instructor)
    begin
      course.destroy
    rescue
      output = "can't destroy"
    end
    assert "can't destroy", output
  end

  def test_associate_lessons_with_in_class_assignments
    lesson = Lesson.create(name: "Basketweaving as a means of social engineering")
    assignment = Assignment.create(name: "Make the test pass",  percent_of_grade: 0.8)
    assert lesson.in_class_assignment = assignment
  end

  def test_course_has_many_readings_through_lessons
    course = Course.create(name: "Basketweaving 101", course_code: "Eng101")
    reading = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)
    lesson = Lesson.create(name: "Basketweaving as a means of social engineering")
    course.add_lessons(lesson)
    lesson.add_readings(reading)
    assert_equal reading, course.readings.last
  end

  def test_schools_must_have_a_name
    new_school = School.create(name: "Harvard")
    school = School.create()
    assert School.find(new_school.id)
    refute school.id
  end

  def test_terms_must_have_name_starts_on_ends_on_and_school_id
    new_term1 = Term.create()
    new_term2 = Term.create(starts_on: Date.new(2016,2,19), ends_on: Date.new(2016,2,19) >> 3 , school_id: 4)
    refute new_term1.id
    assert Term.find(new_term2.id)
  end

  def test_user_has_a_first_name_a_last_name_and_an_email
    person = User.create()
    person2 = User.create(first_name: "Bill", last_name: "Colander", email: "bill99@gmail.com")
    assert User.find(person2.id)
    refute person.id
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
    assert Assignment.find(assignment.id)
    refute new_assignment.id
  end
end
