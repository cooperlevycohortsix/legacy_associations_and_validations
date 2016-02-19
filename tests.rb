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

  # def test_associate_lessons_with_in_class_assignments
  #   l = Lesson.create(name: "Basketweaving as a means of social engineering")
  #   in_class_assignments_id = 8
  #   l.linked_to_assignment(l.in_class_assignments_id)
  #   assert_equal in_class_assignments_id, l.in_class_assignments_id.last
  # end

  # def test_course_has_many_readings_through_lessons
  #   c = Course.create(name: "Basketweaving 101", course_code: "12345")
  #   r = Reading.create(caption: "good read", url: "https://goodread.com", order_number: 1)
  #   c.readings << r
  #   assert_equal r, c.readings.last
  # end

  def test_schools_must_have_a_name
    new_s = School.create(name: "Harvard")
    school = School.create()
    refute school.name
    assert new_s.name
  end
end
