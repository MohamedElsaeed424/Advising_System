/* V Handle what to show when type = course and when type = CH*/
CREATE FUNCTION FN_Advisors_Requests (@advisorID INT)
	RETURNS TABLE
	AS
	RETURN (
		SELECT *
		FROM Request
		WHERE advisor_id = @advisorID
	);
GO

/*W What to do with semester code?????*/
Create PROC Procedures_AdvisorApproveRejectCHRequest
	@RequestID int, 
	@Current_semester_code varchar (40)
	AS
	IF Exists (Select s.student_id from request R INNER JOIN Student S on r.student_id = s.student_id AND r.type = 'CH' /*is type like this?*/
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
/*Y               NOT FINISHED     Missing semester code */
CREATE PROC Procedures_AdvisorApproveRejectCourseRequest
	@RequestID int,
	@studentID int,
	@advisorID int
	AS
	DECLARE @Current_semester_code varchar(40)
	SET @Current_semester_code = (SELECT TOP 1 semester_code from Semester 
			Where CURRENT_TIMESTAMP <= end_date and CURRENT_TIMESTAMP >= start_date)
	DECLARE @prereq BIT
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
	@AdvisorID int,
	@Table OUTPUT
	AS
	Select @Table = (Select * from request 
		where student_id in (Select student_id from student where advisor_id = @AdvisorID));
	GO


/* AA  */
CREATE FUNCTION  FN_StudentLogin(@StudentID int, @password varchar (40))
	RETURNS BIT
	AS
	BEGIN
		RETURN CASE WHEN EXISTS (SELECT 1 from Student
							WHERE student_id = @StudentID AND password = @password)
			   THEN 1 ELSE 0 END
	END;
GO

/*BB*/
CREATE PROC Procedures_StudentaddMobile
	@StudentID int, 
	@mobile_number varchar (40)
	AS
	IF NOT EXISTS(Select student_id from student where student_id = @StudentID) OR  @StudentID IS NULL OR @mobile_number IS NULL
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
		INSERT INTO Student_Phone values(@StudentID ,@mobile_number);
	END
	GO
/*DD*/
CREATE PROC Procedures_StudentSendingCourseRequest
	@StudentID int, 
	@courseID int, 
	@type varchar (40),
	@comment varchar (40) 
	AS
	IF @StudentID IS NULL OR @courseID IS NULL
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
		INSERT INTO request (student_id, course_id, type, comment) values (@StudentID ,@courseID ,@type ,@comment) 
	END
	GO
/*EE*/
CREATE PROC Procedures_StudentSendingCHRequest
	@StudentID int, 
	@credit_hours int, 
	@type varchar (40),
	@comment varchar (40) 
	AS
	IF @StudentID IS NULL OR @courseID IS NULL
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
		INSERT INTO request (student_id, course_id, type, comment) values (@StudentID ,@courseID ,@type ,@comment) 
	END
	GO

