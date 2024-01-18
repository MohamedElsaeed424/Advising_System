SELECT * FROM  view_Students ;
SELECT * FROM  view_Course_prerequisites;
SELECT * FROM  Instructors_AssignedCourses;
SELECT * FROM  Student_Payment;
SELECT * FROM  Courses_Slots_Instructor;
SELECT * FROM  Courses_MakeupExams;
SELECT * FROM  Students_Courses_transcript;
SELECT * FROM  Semster_offered_Courses;
SELECT * FROM  Advisors_Graduation_Plan;

DECLARE 
	 @Student_id INT;
EXEC Procedures_StudentRegistration 
	 @first_name = '' ,
	 @last_name = '' ,
	 @password = '' ,
	 @faculty = '' ,
	 @email  = '' ,
	 @major = '' ,
	 @Semester = 1 ,
	 @student_id = @Student_id OUTPUT;


DROP VIEW view_Students ;
DROP VIEW view_Course_prerequisites;
DROP VIEW Instructors_AssignedCourses;
DROP VIEW Student_Payment;
DROP VIEW Courses_Slots_Instructor;
DROP VIEW Courses_MakeupExams;
DROP VIEW Students_Courses_transcript;
DROP VIEW Semster_offered_Courses;
DROP VIEW Advisors_Graduation_Plan;
DROP PROCEDURE Procedures_StudentRegistration;
