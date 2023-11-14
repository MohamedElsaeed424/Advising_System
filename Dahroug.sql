Create PROC Procedures_AdvisorApproveRejectCHRequest
	@RequestID int, 
	@Current_semester_code varchar (40)
	AS
	IF Exists (Select s.student_id from request R JOIN Student S on r.student_id = s.student_id
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