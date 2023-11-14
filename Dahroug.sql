/*W*/
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


