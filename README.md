# School System Organizer

## Description

Allows a School System to more efficiently manage its staff, students, and curriculum.

Your School System will now be able to:
* To create a new instance of `Schools` a `name` must be entered.  `Terms` and `Courses` can be accessed through `Schools`.

* `Terms` must have a `name`, `starts_on`, `ends_on`, and `school_id`.  `Terms` have access to `Courses` directly.

* `Courses` need `course_code`(begins with three letters and finishes with three numbers) and a `name`.  If a `Course` has `course_students` or `course_instructor` associated with it, it will not be deletable.  If an instance of `Courses` is deleted, its `Lessons` will be deleted as well.  `Courses` have access to `course_students`, `course_instructors`, `Assignments`, `Readings` and `Lessons`.  `course_code` is unique within a given `term_id`.  

* `Lessons` must have a `name` to be created.  `Lessons` have access to `pre_class_assignments`, `in_class_assignments`, and `Readings`.  If an instance of `Lessons` is destroyed, its `Readings` will be destroyed!

* `Readings` must have an `order_number`, a `lesson_id`, and a `url`.  The `url` must begin with `'http:// | https://'`

* To create a new instance of `Assignments` a `name`, `course_id`, and `percent_of_grade` must be entered. `name` is unique within a given `course_id`.

* To create a new instance of `Users` a `first_name`, `last_name`, and `email` must be entered. A `Users` `email` must be unique and have the appropriate form for an email address. 'url' must start with `http:// | https://`.
