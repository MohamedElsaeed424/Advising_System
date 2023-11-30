
--L)
CREATE PROC Procedures_AdminIssueInstallment @paymentID INT --mahmoud mabsoot
AS
IF @paymentID IS NULL OR EXISTS(SELECT * FROM Installment WHERE payment_id = @paymentID)
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN ------ add condition if procedure is done twice on same payment_id i.e. if exists installment with payment_id
	DECLARE @num_instalments INT ,
			@i INT ,
			@date DATE ,
			@start_date DATE ,
			@end_date DATE ,
			@amount INT
	SELECT @amount = amount ,
		   @start_date = start_date,
		   @end_date = deadline
	FROM Payment 
	WHERE payment_id = @paymentID
	SET @num_instalments = MONTH(@end_date) - MONTH(@start_date)
	SET @amount = @amount / @num_instalments
	SET @i = 0 

	WHILE @i < @num_instalments
	BEGIN
		SET @end_date = DATEADD(MONTH, 1, @start_date)
		INSERT INTO Installment VALUES(@paymentID ,@end_date ,@amount ,'notPaid',@start_date)
		SET @start_date = DATEADD(MONTH, 1, @start_date)
		SET @i = @i +1
	END
END
GO
--M)
CREATE PROC Procedures_AdminDeleteCourse @courseID INT
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
--N) moved before the Tables creation 
--O)
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
--P)
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
--Q)
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
GO

--R)
--TO BE CHECKED SINCE THE INPUT IS A DATE AND IT SHOULD BE AN INTEGER REPRESENTING THE SEMESTER
--TO BE ASKED IN Q&A
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
--S)
CREATE PROC Procedures_AdvisorAddCourseGP 
	 @student_Id INT
	,@Semester_code VARCHAR(40)
	,@course_name VARCHAR(40)
AS
IF  @student_Id IS NULL
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
--T)
CREATE PROC Procedures_AdvisorUpdateGP 
	 @expected_grad_date DATE
	,@studentID INT
AS
IF    @expected_grad_date IS NULL
	OR @studentID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN

	UPDATE Graduation_Plan
	SET expected_grad_date = @expected_grad_date
	WHERE Graduation_Plan.student_id = @studentID
END
GO
--U)
CREATE PROC Procedures_AdvisorDeleteFromGP 
	 @studentID INT
	,@semesterCode VARCHAR(40)
	,@courseID INT
AS
IF  @studentID IS NULL
	OR @semesterCode IS NULL
	OR @courseID IS NULL
BEGIN
	PRINT 'INVALID INPUT'
END
ELSE
BEGIN
	DECLARE @planid  INT ;
	SELECT @planid = plan_id
	FROM Graduation_Plan
	WHERE student_id= @studentID
	
	DELETE 
	FROM GradPlan_Course
	WHERE plan_id= @planid AND
		  course_id =@courseID AND
		  semester_code = @semesterCode
END
GO


