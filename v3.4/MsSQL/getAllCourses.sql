/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Credits: Originally base off of SQLs provided by MNPS - Metro Nashville Public Schools 
            Sundaresh Srinivasa, Lee Barber, Chris Weber
-- Supported   Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Courses output based on a database.
-- Documentation: For documentation on OneRoster v1.1 Course please follow link bellow.
		Link: https://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452011
-- ============================================= */

CREATE OR ALTER VIEW onerosterv11csv.getAllCourses
AS
SELECT DISTINCT
	COU.Id																										AS sourceId
    , 'active'																									AS status
    , CONVERT(VARCHAR(50),CAST(COU.LastModifiedDate AS datetimeoffset),127)										AS dateLastModified
	, COU.CourseTitle																							AS title
	, SYT.SchoolYear																							AS schoolYear
	, SYT.Id																									AS schoolYearSourcedId
	, COU.CourseCode																							AS courseCode
	, CONCAT('[',-- (SELECT STRING_AGG( 
	 STUFF((SELECT ', '+ (
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
		FOR XML PATH('')),1,1,'') 
		
		,']')	AS grades
	, CONCAT('[','"',SUD.CodeValue,'"',']')                                                                     AS subjects
	, CONCAT('{ "sourceId":"', Edo.Id, '" }')																	AS org
	, NULL																										AS subjectCodes 
	, NULL																										AS resources
	,EDO.EducationOrganizationId
	--/.,COO.SchoolId
FROM edfi.CourseOffering AS COO --edfi.Course					AS COU
INNER JOIN edfi.Course					AS COU  --edfi.CourseOffering COO  
	ON COU.CourseCode = COO.CourseCode
	--AND COU.EducationOrganizationId = COO.EducationOrganizationId
	AND COU.EducationOrganizationId = COO.EducationOrganizationId	 
INNER JOIN edfi.EducationOrganization EDO 
	ON COU.EducationOrganizationId = EDO.EducationOrganizationId
	--ON  COO.SchoolId = EDO.EducationOrganizationId
LEFT JOIN edfi.SchoolYearType SYT	
	ON COO.SchoolYear = SYT.SchoolYear
INNER JOIN edfi.AcademicSubjectDescriptor ASD 
	ON COU.AcademicSubjectDescriptorId = ASD.AcademicSubjectDescriptorId
INNER JOIN edfi.Descriptor SUD ON ASD.AcademicSubjectDescriptorId = SUD.DescriptorId 




