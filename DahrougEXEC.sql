EXEC Procedures_AdvisorApproveRejectCHRequest @RequestID=3, @current_semester_code = 'W24'
EXEC Procedures_AdvisorViewAssignedStudents @AdvisorID=1, @major='CS'
EXEC Procedures_AdvisorApproveRejectCourseRequest @RequestID=1, @current_semester_code = 'W24'


SELECT * FROM FN_Advisors_Requests(8)

DROP FUNCTION FN_Advisors_Requests
DROP PROC Procedures_AdvisorApproveRejectCHRequest
DROP PROC Procedures_AdvisorViewAssignedStudents
DROP PROC Procedures_AdvisorApproveRejectCourseRequest
DROP PROC Procedures_AdvisorViewPendingRequests
DROP FUNCTION FN_StudentLogin
DROP PROC Procedures_StudentaddMobile
DROP PROC Procedures_StudentSendingCourseRequest
DROP PROC Procedures_StudentSendingCHRequest

--------------------------
EXEC clearAllTables