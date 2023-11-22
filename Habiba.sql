GO
CREATE VIEW view_Students AS 
SELECT * 
FROM student 
WHERE financial_status = 1;

GO
CREATE VIEW view_Course_prerequisites AS 
SELECT Course.* 
FROM Course
INNER JOIN PreqCourse_course on Course.course_id = PreqCourse_course.prerequisite_course_id;

GO
CREATE VIEW Instructors_AssignedCourses AS
SELECT *
FROM Instructor
INNER JOIN Instructor_Course on Instructor_Course.instructor_id = Instructor.instructor_id ;

GO
CREATE VIEW  Student_Payment AS
SELECT *
FROM Payment 
INNER JOIN Student on student.student_id = Payment.student_id;


/* recheck part E */
GO 
CREATE VIEW Courses_Slots_Instructor AS
SELECT course.course_id , Course.name , slot.slot_id , slot.day , slot.time , slot.location , Instructor.name
FROM Course 
INNER JOIN Slot on course.course_id = slot.course_id 
INNER JOIN Instructor_Course on Instructor_Course.Course_id = Course.Course_id;

GO 
CREATE VIEW Courses_MakeupExams AS
SELECT Course.name, Course.semester , MakeUp_Exam.*
FROM Course
INNER JOIN MakeUp_Exam on MakeUp_Exam.Course_id = Course.Course_id;

/* recheck part G */
GO 
CREATE VIEW Students_Courses_transcript AS
SELECT student.student_id, Student.f_name , student.l_name , course_id , Student_Instructor_Course_Take.exam_type , Student_Instructor_Course_Take.grade, student.semester, Instructor.name
FROM Student_Instructor_Course_Take 
INNER JOIN Student on student.student_id = Student_Instructor_Course_Take.student_id
INNER JOIN Instructor on Student_Instructor_Course_Take.Instructor_id = Instructor.Instructor_id;



GO
CREATE VIEW  Semster_offered_Courses AS 
SELECT Course_Semester.course_id , course.name , Course_Semester.semester_code
FROM Course_Semester 
INNER JOIN Semester on Semester.semester_code = Course_Semester.course_id
INNER JOIN course on course.course_id= Course_Semester.course_id;

GO 
CREATE VIEW Advisors_Graduation_Plan AS
SELECT Graduation_Plan.* , Advisor.advisor_id , Advisor.name
FROM Graduation_Plan 
INNER JOIN Advisor on Advisor.advisor_id = Graduation_Plan.advisor_id;

GO 
CREATE PROCEDURE Procedures_StudentRegistration 
@f_name varchar (40),
@l_name varchar (40),
@password varchar (40),
@faculty varchar (40),
@email varchar (40),
@major varchar (40),
@semester int,
@student_id INT OUTPUT
AS 
BEGIN 
INSERT INTO Students(f_name,l_name,password,faculty,email,major,semester)
VALUES(@f_name,@l_name,@password,@faculty,@email,@major,@semester)
SET @student_id = SCOPE_IDENTITY()   /* recheck */
END







