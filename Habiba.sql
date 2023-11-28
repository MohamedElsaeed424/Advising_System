GO
CREATE VIEW view_Students AS 
SELECT * 
FROM student 
WHERE financial_status = 1;

GO
CREATE VIEW view_Course_prerequisites AS 
SELECT c.course_id , c.name ,c.credit_hours ,c.is_offered ,c.major ,c.semester ,PC.prerequisite_course_id 
FROM Course c INNER JOIN PreqCourse_course PC on c.course_id = PC.prerequisite_course_id; 

GO
CREATE VIEW Instructors_AssignedCourses AS
SELECT I.instructor_id ,I.name AS 'Instructor name' ,I.email ,I.faculty ,I.office ,
	  c.course_id , c.name AS 'Course name',c.credit_hours ,c.is_offered ,c.major ,c.semester 
FROM ( Instructor I INNER JOIN Instructor_Course IC on I.instructor_id = IC.instructor_id 
					INNER JOIN Course c ON IC.course_id = c.course_id )

GO
CREATE VIEW  Student_Payment AS
SELECT P.amount ,P.deadline ,P.fund_percentage ,P.n_installments ,P.payment_id ,P.semester_code ,
		P.start_date ,P.status ,S.f_name ,S.l_name ,S.student_id ,S.email 
FROM Payment P INNER JOIN Student S on S.student_id = P.student_id;

GO 
CREATE VIEW Courses_Slots_Instructor AS
SELECT c.course_id , c.name AS 'Course name' , S.slot_id , S.day , S.time , S.location , I.name AS 'Instructor name'
FROM (( Course c INNER JOIN Slot S on c.course_id = c.course_id 
                 INNER JOIN Instructor_Course IC on IC.Course_id = c.Course_id)
				 INNER JOIN Instructor I ON I.instructor_id = IC.instructor_id);

GO 
CREATE VIEW Courses_MakeupExams AS
SELECT c.name , c.semester , ME.course_id ,ME.date ,ME.exam_id ,ME.type
FROM Course c INNER JOIN MakeUp_Exam ME on c.course_id = ME.course_id;

/* recheck part G */
GO 
CREATE VIEW Students_Courses_transcript AS
	SELECT S.student_id , (S.f_name + ' ' +S.l_name) As 'student name' , SC.course_id , c.name AS 'Course name' ,
		   SC.exam_type , SC.grade AS ' course grade' , SC.semester_code AS 'Semester', I.name AS 'Instructor name' 
	FROM (((Student_Instructor_Course_Take SC 
	INNER JOIN Student S on S.student_id = SC.student_id )
	INNER JOIN Course c on SC.course_id = c.course_id )
	INNER JOIN Instructor I on SC.Instructor_id = I.Instructor_id)
	WHERE SC.grade IS NOT NULL
	;
	


GO
CREATE VIEW  Semster_offered_Courses AS 
SELECT CS.course_id , c.name AS ' Course name' , CS.semester_code
FROM ((Course_Semester  CS
		INNER JOIN Semester S on S.semester_code = CS.semester_code)
		INNER JOIN course c on c.course_id= CS.course_id );

GO 
CREATE VIEW Advisors_Graduation_Plan AS
SELECT GP.expected_grad_semester ,GP.student_id ,GP.semester_credit_hours , 
	   GP.semester_code ,GP.plan_id  , A.advisor_id , A.name AS 'Advisor name'
FROM Graduation_Plan GP INNER JOIN Advisor A on A.advisor_id = GP.advisor_id;

GO 
CREATE PROCEDURE Procedures_StudentRegistration 
@first_name varchar (40),
@last_name varchar (40), 
@password varchar (40),
@faculty varchar (40),
@email varchar (40), 
@major varchar (40), 
@Semester int,
@student_id INT OUTPUT
AS 
BEGIN 
	INSERT INTO Student(f_name,l_name,password,faculty,email,major,semester)
			VALUES(@first_name,@last_name,@password,@faculty,@email,@major,@Semester)
	SET @student_id = SCOPE_IDENTITY();
END









