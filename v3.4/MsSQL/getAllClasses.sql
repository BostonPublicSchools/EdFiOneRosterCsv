/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Credits: Originally base off of SQLs provided by MNPS - Metro Nashville Public Schools 
            Sundaresh Srinivasa, Lee Barber, Chris Weber
-- Supported Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Classes output based on a database.
-- Documentation: For documentation on OneRoster v1.1 Class please follow link bellow.
		Link: https://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452010
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllClasses
AS
SELECT DISTINCT
    SEC.Id																										AS sourceId
	, 'active'																									AS status
	, CONVERT(VARCHAR(50),CAST(SEC.LastModifiedDate AS datetimeoffset),127)										AS dateLastModified  
	, NULL																										AS metadata
	, CONCAT(SEC.LocalCourseCode, ' ', SEC.SequenceOfCourse, ' ', COU.CourseTitle)								AS title
	--, TRIM(CONCAT(SEC.LocalCourseCode, '-', STA.LastSurname, ', ', STA.FirstName, ' ', STA.MiddleName))			AS classCode
	, (CONCAT(SEC.LocalCourseCode, '-', STA.LastSurname, ', ', STA.FirstName, ' ', STA.MiddleName))			AS classCode
	, CASE WHEN STU.HomeroomIndicator = '1' THEN 'homeroom' ELSE 'scheduled' END								AS classType
    , SEC.LocationClassroomIdentificationCode																	AS location
    , CONCAT('[', 
	--(SELECT STRING_AGG(
	 STUFF((SELECT ', '+(
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
			END
			--, ', ')
			)
	  FROM edfi.CourseOfferedGradeLevel AS COG
	  INNER JOIN edfi.Descriptor AS COGLD ON COG.GradeLevelDescriptorId = COGLD.DescriptorId 
		WHERE COG.CourseCode=COU.CourseCode and COG.EducationOrganizationId=COU.EducationOrganizationId
		FOR XML PATH('')) ,1,1,'') 
		
		,']')	AS grades
	, CONCAT('["', ASD.CodeValue, '"]')																			AS subjects
    , CONCAT('{ "sourceId":"', COU.Id, '" }')																	AS course
	, CONCAT('{ "sourceId":"', EDO.Id, '" }')																	AS school
	, CONCAT('{ "sourceId":"', TDE.Id, '" }')																	AS terms
	, NULL																										AS subjectCodes 
	, CONCAT('[', STUFF((SELECT ', '+ (CONCAT('"',SCP.ClassPeriodName,'"'))
	  FROM edfi.SectionClassPeriod AS SCP 
		WHERE  SCP.LocalCourseCode = SEC.LocalCourseCode
		AND SCP.SchoolId = SEC.SchoolId 
		AND SCP.SchoolYear = SEC.SchoolYear
		AND SCP.SectionIdentifier = SEC.SectionIdentifier
		AND SCP.SessionName = SEC.SessionName FOR XML PATH('')),1,1,''), ']')															AS periods
	, NULL																										AS resources
FROM edfi.Section AS SEC
INNER JOIN edfi.EducationOrganization EDO ON SEC.SchoolId = EDO.EducationOrganizationId
INNER JOIN edfi.CourseOffering AS CO 
	ON	SEC.LocalCourseCode=CO.LocalCourseCode 
	AND SEC.SchoolId=CO.SchoolId 
	AND SEC.SchoolYear=CO.SchoolYear 
	AND SEC.SessionName=CO.SessionName
INNER JOIN edfi.Course AS COU 
	ON COU.CourseCode = CO.CourseCode
	AND COU.EducationOrganizationId = CO.EducationOrganizationId
INNER JOIN edfi.Descriptor AS ASD ON COU.AcademicSubjectDescriptorId = ASD.DescriptorId
LEFT JOIN edfi.StudentSectionAssociation AS STU
	ON SEC.LocalCourseCode = STU.LocalCourseCode
	AND SEC.SchoolId = STU.SchoolId
	AND SEC.SchoolYear = STU.SchoolYear
	AND SEC.SectionIdentifier = STU.SectionIdentifier
	AND SEC.SessionName = STU.SessionName
LEFT JOIN edfi.StaffSectionAssociation AS SSA
	ON SEC.LocalCourseCode = SSA .LocalCourseCode
	AND SEC.SchoolId = SSA.SchoolId
	AND SEC.SchoolYear = SSA.SchoolYear
	AND SEC.SectionIdentifier = SSA.SectionIdentifier
	AND SEC.SessionName = SSA.SessionName
LEFT JOIN edfi.Staff AS STA ON SSA.StaffUSI = STA.StaffUSI
LEFT JOIN edfi.Descriptor AS CPD ON SSA.ClassroomPositionDescriptorId = CPD.DescriptorId
INNER JOIN edfi.Session AS SES 
	ON SEC.SchoolId=SES.SchoolId 
	AND SEC.SchoolYear=SES.SchoolYear 
	AND SEC.SessionName=SES.SessionName
LEFT JOIN edfi.Descriptor TDE ON SES.TermDescriptorId = TDE.DescriptorId
-- We are grouping by all these fields to get the unique classes
GROUP BY	SEC.Id, SEC.LastModifiedDate, SEC.LocalCourseCode, SEC.SequenceOfCourse, SEC.LocationClassroomIdentificationCode, 
			SEC.SchoolId, SEC.SchoolYear, SEC.SectionIdentifier, SEC.SessionName,
			COU.Id, COU.CourseTitle, COU.CourseCode, COU.EducationOrganizationId, 
			STA.LastSurname, STA.FirstName, STA.MiddleName, 
			STU.HomeroomIndicator, 
			EDO.Id, ASD.CodeValue, TDE.id
ORDER BY sourceId OFFSET 0 ROWS;
