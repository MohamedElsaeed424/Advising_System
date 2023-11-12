--l
GO
CREATE PROC Procedures_AdminIssueInstallment
	@paymentID INT 
	AS 
	SELECT COUNT(Installment)
	FROM Installment
	WHERE Installment.payment_id = @paymentID
	GO 
	EXEC Procedures_AdminIssueInstallment

--m
GO
CREATE PROC Procedures_AdminDeleteCourse
	@courseID INT 
	AS
	DELETE FROM Slot
		WHERE course_id = @courseID;

	DELETE FROM Course
       WHERE course_id = @courseID;
	GO
	EXEC Procedures_AdminDeleteCourse

GO
CREATE PROC Procedure_AdminUpdateStudentStatus
	@StudentID int
	AS 
	UPDATE Student
	SET Student.financial_status = 0 
	FROM Student
	INNER JOIN Payment ON Payment.student_id = @StudentID
	WHERE Payment.status = 'notPaid' AND Payment.deadline<GETDATE()
	GO 
	EXEC Procedure_AdminUpdateStudentStatus
--0
GO
CREATE VIEW all_Pending_Requests AS
	SELECT r.request_id ,
	r.type ,
	r.comment ,
	r.status , 
	r.credit_hours ,
	r.student_id ,
	r.advisor_id 
	FROM Request r
	WHERE status = 'pending'
	GO
	EXEC all_Pending_Requests


--p
GO 
CREATE PROC Procedures_AdminDeleteSlots 
	@current_semester VARCHAR (40)
	AS
	DELETE S
	FROM Slot S
	INNER JOIN Course C on S.course_id = C.course_id
	WHERE C.is_offered = 0 AND
	C.semester <> @current_semester;
	GO
	EXEC Procedures_AdminDeleteSlots


--Q
--GO
--FN_AdvisorLogin


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
	INSERT INTO Graduation_Plan (semester_code , semester_credit_hours ,advisor_id , student_id  )
	VALUES (@Semestercode ,@sem_credit_hours ,@advisorid , @studentid )
	GO
	EXEC Procedures_AdvisorCreateGP


--S
GO 
CREATE PROC Procedures_AdvisorAddCourseGP
	@student_Id int, 
	@Semester_code varchar (40), 
	@course_name varchar (40)
	AS 
	DECLARE @course_id INT  
	SELECT @course_id = course_id FROM Course WHERE Course.name = @course_name
	DECLARE @plan_id INT 
	SELECT @plan_id = plan_id FROM Graduation_Plan WHERE @student_Id = student_id
	INSERT INTO GradPlan_Course (plan_id,semester_code,course_id)
	VALUES (@plan_id , @Semester_code , @course_id )
	GO 
	EXEC Procedures_AdvisorAddCourseGP


--T
GO
CREATE PROC Procedures_AdvisorUpdateGP
	@expected_grad_semster varchar (40), 
	@studentID int
	AS
	--type cast varchar semester into an int to match data types
	DECLARE @ExpectedGradSemInt INT = CAST(@expected_grad_semster AS INT)
	UPDATE Graduation_Plan 
	SET expected_grad_semester = @ExpectedGradSemInt
	WHERE Graduation_Plan.student_id = @studentID 
	GO 
	EXEC Procedures_AdvisorUpdateGP



--U
GO 
CREATE PROC Procedures_AdvisorDeleteFromGP 
	@studentID INT, 
	@semesterCode varchar (40) ,
	@courseID INT
	AS
	DELETE C
	FROM Course C
	INNER JOIN Graduation_Plan GP ON GP.student_id = @studentID
	INNER JOIN Semester S ON S.semester_code = @semesterCode
	WHERE C.course_id = @courseID
	GO 
	EXEC Procedures_AdvisorDeleteFromGP