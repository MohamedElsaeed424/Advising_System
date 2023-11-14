/*W What to do with semester code?????*/
Create PROC Procedures_AdvisorApproveRejectCHRequest
	@RequestID int, 
	@Current_semester_code varchar (40)
	AS
	IF Exists (Select s.student_id from request R INNER JOIN Student S on r.student_id = s.student_id
		where @RequestID = request_id And s.gpa <= 3.7 AND r.credit_hours <= 3 And r.credit_hours + s.assigned_hours < 34)
	Begin
		UPDATE request 
		Set status = 'accepted'
		where @RequestID = request_id
		UPDATE student
		SET assigned_hours = (SELECT TOP 1 s.assigned_hours + r.credit_hours
							from student s INNER JOIN request r on s.student_id = r.student_id AND r.request_id = @RequestID);
	End
	ELSE
		UPDATE request
		Set status = 'rejected'
		where @RequestID = request_id
	GO
/*X*/
CREATE PROC Procedures_AdvisorViewAssignedStudents
	@AdvisorID int,
	@major varchar (40),
	@Table OUTPUT
	AS
	Select @Table = (Select s.student_id, Concat(s.f_name, ' ', s.l_name) as Student_name , s.major as Student_major, c.name as course_name 
				from student s INNER JOIN Student_Instructor_Course_Take t on s.student_id = t.student_id
				INNER JOIN Course c on t.course_id = c.course_id
				where s.advisor_id = @AdvisorID And s.major = @major);
	GO
/*Y               NOT FINISHED                        */
CREATE PROC Procedures_AdvisorApproveRejectCourseRequest
	@RequestID int,
	@studentID int,
	@advisorID int
	AS
	Declare @prereq BIT
	SET @prereq = CASE
		WHEN EXISTS (
			SELECT p.prerequisite_course_id
			FROM PreqCourse_course p
			INNER JOIN request r ON p.course_id = r.course_id AND r.request_id = @RequestID
			LEFT JOIN Student_Instructor_Course_Take sic ON p.prerequisite_course_id = sic.course_id AND sic.student_id = @studentID
			WHERE sic.course_id IS NULL
		) THEN 1
		ELSE 0
		END;
	Declare @check_advisor_and_enough_hours BIT
	SET @check_advisor_and_enough_hours  = CASE
		WHEN EXISTS (Select * from
			(Select student_id from student where student_id = @studentID AND advisor_id = @advisorID) s 
			INNER JOIN Student_Instructor_Course_Take sic on s.student_id = sic.student_id INNER JOIN Course c on c.course_id = sic.course_id

			) THEN 1
			ELSE 0
			END;
	

	GO
/*Z*/
CREATE PROC Procedures_AdvisorViewPendingRequests
	@AdvisorID int 
	AS
	Select * from request 
	where student_id in (Select student_id from student where advisor_id = @AdvisorID);
	GO

