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
    l = Lesson.create(name: "Basketweaving")
    r = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)
    l.add_readings(r)
    assert_equal r, l.readings.last
  end

  def test_lessons_readings_removed_when_lessons_destroyed
    l = Lesson.new(name: "Basketweaving")
    r = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)
    l.add_readings(r)
    l.destroy
    assert r.destroyed?
  end

  def test_courses_are_associated_with_lessons
    c = Course.create(name: "Basketweaving 101", course_code: "12345")
    l = Lesson.create(name: "Basketweaving as a means of social engineering")
    c.add_lessons(l)
    assert_equal l, c.lessons.last
  end

  def test_a_course_can_not_be_destroyed_if_course_instructors_exit
    output = ""
    c = Course.create(name: "Basketweaving 101", course_code: "12345")
    ci = CourseInstructor.create
    c.add_course_instructor(ci)
    begin
      c.destroy
    rescue
      output = "can't destroy"
    end
    assert "can't destroy", output
  end

  def test_associate_lessons_with_in_class_assignments
    lesson = Lesson.create(name: "Basketweaving as a means of social engineering")
    assignment = Assignment.create(name: "Make the test pass")
    assert lesson.in_class_assignment = assignment
  end

  def test_course_has_many_readings_through_lessons
    course = Course.create(name: "Basketweaving 101", course_code: "12345")
    reading = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)
    lesson = Lesson.create(name: "Basketweaving as a means of social engineering")
    course.add_lessons(lesson)
    lesson.add_readings(reading)
    assert_equal reading, course.readings.last
  end

  def test_schools_must_have_a_name
    new_s = School.create(name: "Harvard")
    school = School.create()
    refute school.id
    assert new_s.name
  end

  def test_terms_must_have_name_starts_on_ends_on_and_school_id
    new_term1 = Term.create()
    new_term2 = Term.create(starts_on: Date.new(2016,2,19), ends_on: Date.new(2016,2,19) >> 3 , school_id: 4)
    refute new_term1.id
    assert Term.find(new_term2.id)
  end

  def test_user_has_a_first_name_a_last_name_and_an_email
    person = User.create()
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
    # refute person2.save
    # assert person1.save
  end

  def test_users_photo_url_is_formatted_correctly
    person1 = User.new(first_name: "Bill", last_name: "Colander", email: "bill2@gmail.com", photo_url: "https://lookatmypicture.com")
    person2 = User.new(first_name: "Sally", last_name: "Smith", email: "billgmailcom", photo_url: "htxl:/lookatme.com")
    assert person1.save
    refute person2.save
  end

end
