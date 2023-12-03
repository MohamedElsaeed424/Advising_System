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

/*              W             */
Create PROC Procedures_AdvisorApproveRejectCHRequest
	@RequestID int,
	@Current_semester_code varchar (40)
	AS
	Declare @stID INT
	Declare @ch INT
	IF @RequestID IS NULL OR @Current_semester_code IS NULL OR Not EXISTS (Select * from Request WHERE type LIKE 'credit%' AND @RequestID = request_id AND status = 'pending')
		Print 'No such pending request'

	ELSE IF Exists (Select s.student_id from Request R INNER JOIN Student S on r.student_id = s.student_id AND r.type LIKE 'credit%' /*is type like this?*/
		AND @RequestID = request_id And s.gpa <= 3.7 AND r.credit_hours <= 3 And r.credit_hours + s.assigned_hours <= 34) 
	Begin
	----
		UPDATE Request 
		Set status = 'approved'
		where @RequestID = request_id

		------
		SET @stID = (SELECT student_id from Request where @RequestID = request_id)
		SET @ch = (SELECT credit_hours from Request where @RequestID = request_id)
		UPDATE Student
		SET assigned_hours = (SELECT assigned_hours + @ch
							from Student where student_id = @stID)
		where student_id = @stID
		-----
		Declare @InstID1 INT
		Declare @InstID2 DATE
		SELECT TOP 1 @InstID1 = i.payment_id, @InstID2 = i.deadline
				from Installment i JOIN Payment p on i.payment_id = p.payment_id AND p.student_id = @stID 
				AND p.semester_code = @Current_semester_code AND i.status = 'notPaid'
				Order by i.deadline 
		
		UPDATE Installment
		SET amount = amount + @ch*1000
		where payment_id = @InstID1 AND deadline = @InstID2
	End
	ELSE
		UPDATE Request
		Set status = 'rejected'
		where @RequestID = request_id
	GO
/*X*/
CREATE PROC Procedures_AdvisorViewAssignedStudents
	@AdvisorID int,
	@major varchar (40)
	AS
	Select s.student_id as 'Student id', Concat(s.f_name, ' ', s.l_name) as 'Student name' , s.major as 'Student major', c.name as 'Course name'
				from student s INNER JOIN Student_Instructor_Course_Take t on s.student_id = t.student_id
				INNER JOIN Course c on t.course_id = c.course_id
				AND s.advisor_id = @AdvisorID And s.major = @major;
	GO
/*                              Y              */
CREATE PROC Procedures_AdvisorApproveRejectCourseRequest
	@RequestID int,
	@current_semester_code varchar(40)
	AS
	IF @RequestID IS NULL OR @current_semester_code IS NULL OR Not EXISTS (Select * from Request WHERE type = 'course' AND @RequestID = request_id AND status='pending')
	BEGIN
		Print 'ERROR' 
		RETURN
	END
	DECLARE @prereq_taken BIT
	SET @prereq_taken = CASE
		WHEN EXISTS (
			SELECT p.prerequisite_course_id
			FROM PreqCourse_course p
			INNER JOIN Request r ON p.course_id = r.course_id AND r.request_id = @RequestID
			LEFT JOIN Student_Instructor_Course_Take sic ON p.prerequisite_course_id = sic.course_id AND sic.student_id = r.student_id
			WHERE sic.course_id IS NULL OR sic.grade IS NULL OR sic.grade = 'FA'
		) THEN 0
		ELSE 1
		END;
	Declare @enough_hours BIT
	SET @enough_hours  = CASE
		WHEN EXISTS ( Select c.credit_hours from Request r JOIN Course c on r.course_id = c.course_id AND r.request_id = @RequestID
			JOIN Student s on r.student_id = s.student_id AND s.assigned_hours >= c.credit_hours
			) THEN 1
			ELSE 0
			END;
	Declare @already_taken BIT 
	SET @already_taken= CASE 
				WHEN EXISTS (Select * from Request r JOIN Student_Instructor_Course_Take sic 
				on r.student_id = sic.student_id AND r.course_id = sic.course_id AND r.request_id = @RequestID
				AND sic.semester_code = @current_semester_code) THEN 1 ELSE 0 END
	Declare @studentID INT
	Declare @course_hours INT
	Declare @courseID INT
	Select @studentID = r.student_id, @course_hours = c.credit_hours, @courseID = c.course_id
	from Request r JOIN Course c on r.course_id = c.course_id AND r.request_id = @RequestID

	IF @prereq_taken = 1 AND @enough_hours = 1 AND @already_taken = 0
	BEGIN
		UPDATE Request
		SET status = 'approved'
		WHERE @RequestID = request_id

		UPDATE Student
		SET assigned_hours = assigned_hours - @course_hours
		WHERE student_id = @studentID

		INSERT INTO Student_Instructor_Course_Take(student_id, course_id, semester_code) VALUES
		(@studentID, @courseID, @current_semester_code)
	END
	ELSE
	BEGIN
		UPDATE Request
		SET status = 'rejected'
		WHERE @RequestID = request_id
	END

	GO
/*Z*/
CREATE PROC Procedures_AdvisorViewPendingRequests
	@AdvisorID int
	AS
	Select * from request 
		where status = 'pending' AND student_id in (Select student_id from student where advisor_id = @AdvisorID);
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
/*CC*/
CREATE FUNCTION FN_SemsterAvailableCourses (@semester_code varchar (40))
	RETURNS TABLE
	AS
	RETURN (
		Select c.* ----- basss????
		from Course c JOIN Course_Semester cs on c.course_id = cs.course_id AND cs.semester_code = @semester_code
	);
GO
/*DD*/
CREATE PROC Procedures_StudentSendingCourseRequest
	@StudentID int, 
	@courseID int, 
	@type varchar (40),
	@comment varchar (40) 
	AS
	IF @StudentID IS NULL OR @courseID IS NULL OR @type NOT LIKE 'course%'
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
	IF @StudentID IS NULL OR @credit_hours IS NULL OR @type NOT LIKE 'credit%'
	BEGIN
		PRINT 'ERROR';
	END
	ELSE
	BEGIN
		INSERT INTO request (student_id, credit_hours, type, comment) values (@StudentID ,@credit_hours ,@type ,@comment) 
	END
	GO

