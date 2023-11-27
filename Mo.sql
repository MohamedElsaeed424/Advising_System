	--l
GO

CREATE PROC Procedures_AdminIssueInstallment @paymentID INT --mahmoud medaye2
AS
IF @paymentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	SELECT n_installments
	FROM Payment 
	WHERE payment_id = @paymentID
END
GO

	--m
GO

CREATE PROC Procedures_AdminDeleteCourse @courseID INT --delete slot or update it ??
AS
IF @courseID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	UPDATE Slot
	SET course_id = NULL
	WHERE course_id = @courseID;

	DELETE
	FROM Course
	WHERE course_id = @courseID;
END
GO


GO

CREATE PROC Procedure_AdminUpdateStudentStatus @StudentID INT
AS
IF @StudentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
DECLARE @isBlocked INT ;
		Select @isBlocked = COUNT(*)
		FROM  Student INNER JOIN Payment ON Payment.student_id = Student.student_id
			 WHERE Payment.STATUS = 'notPaid'
				AND Payment.deadline < GETDATE()
				AND Student.student_id = @StudentId

		if (@isBlocked = 0 ) -- no passed deadlines 
			BEGIN 
				UPDATE Student
				SET Student.financial_status = 1
				WHERE student_id = @StudentID
			END
		ELSE
			BEGIN 
				UPDATE Student
				SET Student.financial_status = 0
				WHERE student_id = @StudentID
			END
END
GO

-- saeed added
CREATE FUNCTION CALC_STUDENT_FINANTIAL_STATUS_HELPER (@StudentId INT)
	RETURNS BIT
	BEGIN
		DECLARE @financial_status BIT
		DECLARE @isBlocked INT ;

		Select @isBlocked = COUNT(*)
		FROM  Student INNER JOIN Payment ON Payment.student_id = Student.student_id
			 WHERE Payment.STATUS = 'notPaid'
				AND Payment.deadline < GETDATE()
				AND Student.student_id = @StudentId

		if (@isBlocked = 0 )
			BEGIN SET @financial_status = 1 END
		ELSE
			BEGIN SET @financial_status = 0 END

	RETURN @financial_status
	END
GO

--0
CREATE VIEW all_Pending_Requests
	AS
	SELECT R.*
		  ,S.f_name
		  ,S.l_name
		  ,A.name
	FROM Request R
		INNER JOIN Student S ON S.student_id = R.student_id
		INNER JOIN Advisor A ON A.advisor_id = R.advisor_id
	WHERE R.status = 'pending'
GO


	--p revise here ..
GO

CREATE PROC Procedures_AdminDeleteSlots @current_semester VARCHAR(40)
AS
IF @current_semester IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DELETE S
	FROM Slot S
	INNER JOIN Course C ON S.course_id = C.course_id
	INNER JOIN Course_Semester CS ON @current_semester = CS.semester_code
	WHERE C.is_offered = 0
END
GO


	--Q
GO

CREATE FUNCTION FN_AdvisorLogin (
	@ID INT
	,@password VARCHAR(40)
	)
RETURNS BIT
AS
BEGIN
	DECLARE @Success BIT

	IF EXISTS (
			SELECT *
			FROM Advisor
			WHERE Advisor.advisor_id = @ID
				AND Advisor.password = @password
			)
		SET @Success = 1
	ELSE
		SET @Success = 0

	RETURN @Success
END
	--R
	--TO BE CHECKED SINCE THE INPUT IS A DATE AND IT SHOULD BE AN INTEGER REPRESENTING THE SEMESTER
	--TO BE ASKED IN Q&A
GO

CREATE PROC Procedures_AdvisorCreateGP @Semestercode VARCHAR(40)
	,@expected_graduation_date DATE
	,@sem_credit_hours INT
	,@advisorid INT
	,@studentid INT
AS
	-- saeed added
	DECLARE @std_acq_hours INT

	SELECT @std_acq_hours= acquired_hours
	FROM Student
	WHERE student_id = @studentid
IF @std_acq_hours <= 157
	BEGIN PRINT 'INVALID ACTION the student dont have enough acquired_hours' END
ELSE IF @Semestercode IS NULL
	OR @expected_graduation_date IS NULL
	OR @sem_credit_hours IS NULL
	OR @advisorid IS NULL
	OR @studentid IS NULL
	BEGIN
		PRINT 'INVALID INPUT'
	END
ELSE
	BEGIN
	
		INSERT INTO Graduation_Plan (
			semester_code
			,semester_credit_hours
			,expected_grad_date
			,advisor_id
			,student_id
			)
		VALUES (
			@Semestercode
			,@sem_credit_hours
			,@expected_graduation_date
			,@advisorid
			,@studentid
			)
	END
GO


	--S
GO

CREATE PROC Procedures_AdvisorAddCourseGP @student_Id INT
	,@Semester_code VARCHAR(40)
	,@course_name VARCHAR(40)
AS
IF @student_Id IS NULL
	OR @Semester_code IS NULL
	OR @course_name IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DECLARE @course_id INT

	SELECT @course_id = course_id
	FROM Course
	WHERE Course.name = @course_name

	DECLARE @plan_id INT

	SELECT @plan_id = plan_id
	FROM Graduation_Plan
	WHERE Graduation_Plan.student_id = @student_Id

	INSERT INTO GradPlan_Course (
		plan_id
		,semester_code
		,course_id
		)
	VALUES (
		@plan_id
		,@Semester_code
		,@course_id
		)
END
GO


	--T
GO

CREATE PROC Procedures_AdvisorUpdateGP @expected_grad_semster VARCHAR(40)
	,@studentID INT
AS
IF @expected_grad_semster IS NULL
	OR @studentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	--type cast varchar semester into an int to match data types
	--assuming that the input is a semester as an integer value
	--since it isn't called semester code 
	--wala eh
	--hab2a as2al kamilia fel mawdo3 dah
	--bas 5aleeha kda delwa2ty
	--all the comments above to be ignored till another announcment
	UPDATE Graduation_Plan
	SET expected_grad_semester = @expected_grad_semster
	WHERE Graduation_Plan.student_id = @studentID
END
GO


	--U
GO

CREATE PROC Procedures_AdvisorDeleteFromGP @studentID INT
	,@semesterCode VARCHAR(40)
	,@courseID INT
AS
IF @studentID IS NULL
	OR @semesterCode IS NULL
	OR @courseID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DELETE C
	FROM Course C
	INNER JOIN Graduation_Plan GP ON GP.student_id = @studentID
	INNER JOIN Semester S ON S.semester_code = @semesterCode
	WHERE C.course_id = @courseID
END
GO


