Create PROC Procedures_AdvisorApproveRejectCHRequest
	@RequestID int, 
	@Current_semester_code varchar (40)
	AS
	UPDATE Request
	SET status = 'accepted'
	where request_id = @RequestID;
	GO