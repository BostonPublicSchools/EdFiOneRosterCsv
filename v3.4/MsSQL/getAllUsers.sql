/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Supported Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Users output based on a database.
-- Documentation: For documentation on OneRoster v1.1 Users, Students, Teachers please follow link bellow.
		Link: https://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452019
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllUsers
AS

SELECT DISTINCT
	STA.Id																								AS sourceId
	, CASE WHEN SEOAA.StaffCount = 1 AND  SEOAA.EndDate IS NULL THEN 'active' ELSE 'tobedeleted'  END	AS status 
	, CONVERT(VARCHAR(50),CAST(STA.LastModifiedDate AS datetimeoffset),127)								AS dateLastModified
	, NULL																								AS metadata
	, STA.LoginId																						AS username
	, NULL                                                                                              AS userIds
	, NULL																								AS type
	, CASE WHEN SEOAA.StaffCount = 1 AND  SEOAA.EndDate IS NULL THEN 1 ELSE 0 END						AS enabledUser
	, STA.FirstName																						AS givenName
	, STA.LastSurname																					AS familyName
	, STA.MiddleName																					AS middleName	
	, CASE WHEN SSA.ClassroomPositionDescriptorId IS NULL THEN 'user' ELSE 'teacher' END				AS role
	, STA.StaffUniqueId																					AS identifier
    , SEM.ElectronicMailAddress																			AS email
	, NULL																								AS sms
	, STE.TelephoneNumber																				AS phone
	, NULL																								AS agents
	, CONCAT('[{ "sourceId":"',SEOAA.StaffOrganization, '" }]')											AS orgs
	, NULL																								AS grades
	, CONCAT('e-' , STA.StaffUniqueId)																	AS password
FROM edfi.Staff STA
LEFT JOIN(
	SELECT ROW_NUMBER() over (partition by STEOT.StaffUSI ORDER BY STEOT.Id DESC) as StaffCount	
	, STEOT.StaffUSI
	, STEOT.EndDate
	, STEOT.EducationOrganizationId
	, EOT.Id AS StaffOrganization
	FROM edfi.StaffEducationOrganizationAssignmentAssociation STEOT
	LEFT JOIN edfi.educationorganization EOT ON STEOT.educationorganizationid = EOT.educationorganizationid
) SEOAA 
	ON STA.StaffUSI = SEOAA.StaffUSI
LEFT JOIN edfi.StaffSectionAssociation SSA 
	ON STA.StaffUSI = SSA.StaffUSI 
LEFT JOIN(
	SELECT
		StaffUSI
		, TelephoneNumber 
		, ROW_NUMBER() over (partition by StaffUSI ORDER BY TelephoneNumber DESC) as StaffCount
	FROM edfi.StaffTelephone STET 
)STE 
	ON STA.StaffUSI = STE.StaffUSI
	AND STE.StaffCount = 1
LEFT JOIN(
	SELECT
		StaffUSI
		, ElectronicMailAddress 
		, ROW_NUMBER() over (partition by StaffUSI ORDER BY ElectronicMailAddress DESC) as StaffCount
	FROM edfi.StaffElectronicMail SEMT 
)SEM 
	ON STA.StaffUSI = SEM.StaffUSI
	AND SEM.StaffCount = 1

UNION ALL 

SELECT DISTINCT 
	STU.Id																													AS sourceId
	, CASE WHEN SSA.studentCount = 1 AND  SSA.ExitWithdrawDate IS NULL THEN 'active' ELSE 'tobedeleted'  END				AS status
	, CONVERT(VARCHAR(50),CAST(SEOA.LastModifiedDate AS datetimeoffset),127) 												AS dateLastModified
	, NULL																													AS metadata
	, SEOA.LoginId																											AS username
	, NULL																													AS userIds
	, NULL																													AS type
	, CASE WHEN SSA.studentCount = 1 AND  SSA.ExitWithdrawDate IS NULL THEN 1 ELSE 0  END									AS enabledUser
	, STU.FirstName																											AS givenName
    , STU.LastSurname																										AS familyName
    , STU.MiddleName																										AS middleName
    , 'student'																												AS role 
    , STU.StudentUniqueId																									AS identifier
    , SEOAE.ElectronicMailAddress 																							AS email
	, NULL																													AS sms
    , SEOAT.TelephoneNumber																									AS phone
	, NULL																													AS agents
    , CONCAT('[{ "sourceId":"',SSA.StudentOrganization, '" }]')																AS orgs
    , CONCAT('[',
	STUFF
		 ((SELECT  DISTINCT ', '+
			CASE 
				WHEN  COGLD.CodeValue = 'Infant/toddler' THEN '"IT"' 
				WHEN  COGLD.CodeValue = 'Preschool/Prekindergarten' THEN '"PR/PK"' 
				WHEN  COGLD.CodeValue = 'Transitional Kindergarten' THEN '"TK"' 
				WHEN  COGLD.CodeValue = 'Kindergarten' THEN '"KG"' 
				WHEN  COGLD.CodeValue = 'First grade' THEN '"01"'
				WHEN  COGLD.CodeValue = 'Second grade' THEN '"02"'
				WHEN  COGLD.CodeValue = 'Third grade' THEN '"03"'
				WHEN  COGLD.CodeValue = 'Fourth grade' THEN '"04"' 
				WHEN  COGLD.CodeValue = 'Fifth grade' THEN '"05"' 
				WHEN  COGLD.CodeValue = 'Sixth grade' THEN '"06"' 
				WHEN  COGLD.CodeValue = 'Seventh grade' THEN '"07"' 
				WHEN  COGLD.CodeValue = 'Eighth grade' THEN '"08"' 
				WHEN  COGLD.CodeValue = 'Ninth grade' THEN '"09"' 
				WHEN  COGLD.CodeValue = 'Tenth grade' THEN '"10"' 
				WHEN  COGLD.CodeValue = 'Eleventh grade' THEN '"11"' 
				WHEN  COGLD.CodeValue = 'Twelfth grade' THEN '"12"'
				WHEN  COGLD.CodeValue = 'Grade 13' THEN '"13"' 
				WHEN  COGLD.CodeValue = 'Postsecondary' THEN '"PS"' 
				WHEN  COGLD.CodeValue = 'Ungraded' THEN '"UG"' 
				WHEN  COGLD.CodeValue = 'Other' THEN '"Other"' 
				ELSE 'NA'
			END AS grade
		  FROM edfi.StudentSectionAssociation SSAG
		  INNER JOIN edfi.Section SEC
			ON SSAG.LocalCourseCode = SEC.LocalCourseCode
			AND SSAG.SchoolId = SEC.SchoolId
			AND SSAG.SchoolYear = SEC.SchoolYear
			AND SSAG.SectionIdentifier = SEC.SectionIdentifier
		  INNER JOIN edfi.CourseOffering CO 
			ON SEC.LocalCourseCode = CO.LocalCourseCode
			AND SEC.SchoolId = CO.SchoolId
			AND SEC.SchoolYear = CO.SchoolYear
			AND SEC.SessionName = CO.SessionName
		  INNER JOIN edfi.Course COU 
			ON  CO.CourseCode = COU.CourseCode
			AND CO.EducationOrganizationId = COU.EducationOrganizationId
		  INNER JOIN edfi.CourseOfferedGradeLevel COG
			ON COU.CourseCode = COG.CourseCode
			AND COU.EducationOrganizationId = COG.EducationOrganizationId
		  INNER JOIN edfi.Descriptor AS COGLD 
			ON COG.GradeLevelDescriptorId = COGLD.DescriptorId 
			WHERE SSAG.StudentUSI = STU.StudentUSI
		FOR XML PATH('')),1,1,'' ) 
		,']')																												AS grades
    , CONCAT('s-' , STU.StudentUniqueId)																					AS password
FROM edfi.Student STU
LEFT JOIN(
	SELECT ROW_NUMBER() over (partition by SSAT.StudentUSI ORDER BY SSAT.id DESC) as studentCount	
		, SSAT.StudentUSI
		, SSAT.SchoolId
		, SSAT.ExitWithdrawDate
		, EOT.Id AS StudentOrganization
		FROM edfi.StudentSchoolAssociation SSAT
		LEFT JOIN edfi.EducationOrganization EOT ON SSAT.SchoolId = EOT.educationOrganizationId
) SSA ON STU.StudentUSI = SSA.StudentUSI
LEFT JOIN edfi.StudentEducationOrganizationAssociation SEOA 
	ON STU.StudentUSI = SEOA.StudentUSI
LEFT JOIN(
	SELECT 
		StudentUSI, ElectronicMailAddress 
		, ROW_NUMBER() over (partition by StudentUSI ORDER BY ElectronicMailAddress DESC) as studentCount 
		FROM edfi.StudentEducationOrganizationAssociationElectronicMail
)SEOAE 
	ON STU.StudentUSI = SEOAE.StudentUSI
	AND SEOAE.studentCount = 1
LEFT JOIN(
	SELECT 
		StudentUSI, TelephoneNumber 
		, ROW_NUMBER() over (partition by StudentUSI ORDER BY TelephoneNumber DESC) as studentCount 
	 FROM edfi.StudentEducationOrganizationAssociationTelephone
)SEOAT 
	ON STU.StudentUSI = SEOAT.StudentUSI
	AND SEOAT.studentCount = 1
