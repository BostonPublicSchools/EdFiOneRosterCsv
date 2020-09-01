/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Supported Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Enrollments output based on a database.
-- Documentation: For documentation on OneRoster v1.1 Enrollments please follow link bellow.
		Link: https://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452013
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllEnrollments
AS
SELECT DISTINCT
		STA.id																								AS userId
		, SSA.Id																							AS sourceId
		, CASE WHEN STSA.endDate >= DATEADD(day,1,GETDATE()) THEN 'active' ELSE 'tobedeleted' END			AS status
		, CONVERT(VARCHAR(50),CAST(SEC.LastModifiedDate AS datetimeoffset),127)								AS dateLastModified
		, NULL																								AS metadata
		, CONCAT('[{ "sourceId":"',STA.id, '" }]')															AS [user]
		, CONCAT('[{ "sourceId":"',SEC.Id, '" }]')															AS class
		, CONCAT('[{ "sourceId":"',EO.id, '" }]')															AS school
		, 'teacher'																							AS role
		, CAST(CASE WHEN CD.CodeValue = 'Teacher Of Record' THEN 1 ELSE 0 END AS BIT)               		AS [primary]
		, CONVERT(VARCHAR(50),CAST(SSA.BeginDate AS datetimeoffset),127)									AS beginDate
		, CONVERT(VARCHAR(50),CAST(SSA.EndDate AS datetimeoffset),127)										AS endDate
FROM edfi.Staff STA 
LEFT JOIN edfi.StaffSectionAssociation SSA 
	ON STA.StaffUSI = SSA.StaffUSI
LEFT JOIN  edfi.Section SEC
	ON SSA.SectionIdentifier = SEC.SectionIdentifier 
LEFT JOIN edfi.EducationOrganization EO 
	ON SEC.SchoolId = EO.educationOrganizationId
LEFT JOIN edfi.StudentSectionAssociation AS STSA
	ON SEC.LocalCourseCode = STSA.LocalCourseCode
	AND SEC.SchoolId = STSA.SchoolId
	AND SEC.SchoolYear = STSA.SchoolYear
	AND SEC.SectionIdentifier = STSA.SectionIdentifier
	AND SEC.SessionName = STSA.SessionName
LEFT JOIN edfi.Descriptor CD 
	ON SSA.ClassroomPositionDescriptorId = CD.DescriptorId
	WHERE SSA.Id IS NOT NULL

UNION ALL

SELECT DISTINCT
	STU.id																								AS userId
	, STSA.Id																							AS sourceId
	, CASE WHEN STSA.EndDate >= DATEADD(day,1,GETDATE()) THEN 'active' ELSE 'tobedeleted' END			AS status
	, CONVERT(VARCHAR(50),CAST(SEC.LastModifiedDate AS datetimeoffset),127)								AS dateLastModified
	, NULL																								AS metadata
	, CONCAT('[{ "sourceId":"',STU.id, '" }]')															AS [user]
	, CONCAT('[{ "sourceId":"',SEC.Id, '" }]')															AS class
	, CONCAT('[{ "sourceId":"',EO.id, '" }]')															AS school
	, 'student'																							AS role
	, CAST(NULL AS BIT)																					AS [primary]
	, CONVERT(VARCHAR(50),CAST(STSA.BeginDate AS datetimeoffset),127)									AS beginDate
	, CONVERT(VARCHAR(50),CAST(STSA.EndDate AS datetimeoffset),127)										AS endDate
FROM edfi.Staff STA 
LEFT JOIN edfi.StaffSectionAssociation SSA 
	ON STA.StaffUSI = SSA.StaffUSI
-- Section
LEFT JOIN  edfi.Section SEC
	ON SSA.SectionIdentifier = SEC.SectionIdentifier 
LEFT JOIN edfi.EducationOrganization EO 
	ON SEC.SchoolId = EO.educationOrganizationId
-- Students of section
LEFT JOIN edfi.StudentSectionAssociation AS STSA
	ON SEC.LocalCourseCode = STSA.LocalCourseCode
	AND SEC.SchoolId = STSA.SchoolId
	AND SEC.SchoolYear = STSA.SchoolYear
	AND SEC.SectionIdentifier = STSA.SectionIdentifier
	AND SEC.SessionName = STSA.SessionName
LEFT JOIN edfi.Student STU
	ON STSA.StudentUSI = STU.StudentUSI
	WHERE STSA.Id IS NOT NULL