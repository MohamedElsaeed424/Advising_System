--l


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
--CREATE PROC Procedure_AdminUpdateStudentStatus
--	@StudentID int

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


--Q
--GO
--FN_AdvisorLogin


--R
--TO BE CHECKED SINCE THE INPUT IS A DATE AND IT SHOULD BE AN INTEGER REPRESENTING THE SEMESTER
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