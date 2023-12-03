--W
EXEC Procedures_AdvisorApproveRejectCHRequest @RequestID=3, @current_semester_code = 'W24'
--X
EXEC Procedures_AdvisorViewAssignedStudents @AdvisorID=1, @major='CS'
--Y
EXEC Procedures_AdvisorApproveRejectCourseRequest @RequestID=1, @current_semester_code = 'W24'
--Z
EXEC Procedures_AdvisorViewPendingRequests @AdvisorID=1
--BB
EXEC Procedures_StudentaddMobile @StudentID=1, @mobile_number='543209463'
--DD
EXEC Procedures_StudentSendingCourseRequest @StudentID=3, @courseID=4, @type='course', @comment='null ba3d keda'
--EE
EXEC Procedures_StudentSendingCourseRequest @StudentID=5, @credit_hours=1, @type='credit', @comment='null ba3d keda'


--V
SELECT * FROM FN_Advisors_Requests(8)
--AA
DECLARE @x INT
SET @x = dbo.FN_StudentLogin(1, 'password123')
PRINT @x
--CC
SELECT * FROM FN_SemsterAvailableCourses('S23')


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