--l
GO
CREATE PROC Procedures_AdminIssueInstallment
	@paymentID INT 
	AS 
	IF @paymentID IS NULL
	BEGIN 
		PRINT 'INVALID INPUT'
	END
	ELSE 
	BEGIN
		SELECT COUNT(*)
		FROM Installment
		WHERE Installment.payment_id = @paymentID
	END
	GO 
	EXEC Procedures_AdminIssueInstallment

--m
GO
CREATE PROC Procedures_AdminDeleteCourse
	@courseID INT 
	AS
	IF @courseID IS NULL
	BEGIN 
		PRINT 'INVALID INPUT'
	END
	ELSE
	BEGIN 
		DELETE FROM Slot
			WHERE course_id = @courseID;
		DELETE FROM Course
			WHERE course_id = @courseID;
	END
	GO
	EXEC Procedures_AdminDeleteCourse

GO
CREATE PROC Procedure_AdminUpdateStudentStatus
	@StudentID int
	AS 
	IF @StudentID IS NULL
	BEGIN
		PRINT 'INVALID INPUT'
	END
	ELSE
	BEGIN
		UPDATE Student
		SET Student.financial_status = 0 
		FROM Student
		INNER JOIN Payment ON Payment.student_id = @StudentID
		WHERE Payment.status = 'notPaid' AND Payment.deadline<GETDATE()
	END
	GO 
	EXEC Procedure_AdminUpdateStudentStatus
--0
GO
CREATE VIEW all_Pending_Requests AS
	SELECT r.* , S.f_name , S.l_name , A.name
	FROM Request r 
	INNER JOIN Student S ON S.student_id = r.student_id
	INNER JOIN Advisor A ON A.advisor_id = r.advisor_id
	WHERE status = 'pending'
	GO
	EXEC all_Pending_Requests


--p
GO 
CREATE PROC Procedures_AdminDeleteSlots 
	@current_semester VARCHAR (40)
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
	EXEC Procedures_AdminDeleteSlots


--Q
GO
CREATE FUNCTION FN_AdvisorLogin 
	(@ID int, @password varchar (40))
	RETURNS BIT 
	AS
	BEGIN 
		DECLARE @Success bit 
	if EXISTS (SELECT Advisor FROM Advisor WHERE Advisor.advisor_id = @ID AND  Advisor.password = @password)
		SET @Success = 1
	ELSE 
		SET @Success = 0
	
	RETURN @Success  
	END
	

--R
--TO BE CHECKED SINCE THE INPUT IS A DATE AND IT SHOULD BE AN INTEGER REPRESENTING THE SEMESTER
--TO BE ASKED IN Q&A
GO 
CREATE PROC Procedures_AdvisorCreateGP 
	@Semestercode VARCHAR (40), 
	@expected_graduation_date DATE,
	@sem_credit_hours INT, 
	@advisorid INT,
	@studentid INT
	AS
	IF @Semestercode IS NULL OR @expected_graduation_date IS NULL OR @sem_credit_hours IS NULL OR @advisorid IS NULL OR @studenti IS NULL
	BEGIN 
		PRINT 'INVALID INPUT'
	END
	ELSE
	BEGIN
		INSERT INTO Graduation_Plan (semester_code , semester_credit_hours ,advisor_id , student_id  )
		VALUES (@Semestercode ,@sem_credit_hours ,@advisorid , @studentid )
	END
	GO
	EXEC Procedures_AdvisorCreateGP

--S
GO 
CREATE PROC Procedures_AdvisorAddCourseGP
	@student_Id int, 
	@Semester_code varchar (40), 
	@course_name varchar (40)
	AS 
	IF @student_Id IS NULL OR @Semester_code IS NULL OR @course_name IS NULL
	BEGIN
		PRINT 'INVALID INPUT'
	END
	ELSE
	BEGIN
		DECLARE @course_id INT  
		SELECT @course_id = course_id FROM Course WHERE Course.name = @course_name
		DECLARE @plan_id INT 
		SELECT @plan_id = plan_id FROM Graduation_Plan WHERE Graduation_Plan.student_id = @student_Id
		INSERT INTO GradPlan_Course (plan_id,semester_code,course_id)
		VALUES (@plan_id , @Semester_code , @course_id )
	END
	GO 
	EXEC Procedures_AdvisorAddCourseGP


--T
GO
CREATE PROC Procedures_AdvisorUpdateGP
	@expected_grad_semster varchar (40), 
	@studentID int
	AS
	IF @expected_grad_semster IS NULL OR @studentID IS NULL
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
	DECLARE @ExpectedGradSemInt INT = CAST(@expected_grad_semster AS INT)
	UPDATE Graduation_Plan 
	SET expected_grad_semester = @ExpectedGradSemInt
	WHERE Graduation_Plan.student_id = @studentID 
	END
	GO 
	EXEC Procedures_AdvisorUpdateGP



--U
GO 
CREATE PROC Procedures_AdvisorDeleteFromGP 
	@studentID INT, 
	@semesterCode varchar (40) ,
	@courseID INT
	AS
	IF @studentID IS NULL OR @semesterCode IS NULL OR @courseID IS NULL
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
	EXEC Procedures_AdvisorDeleteFromGP