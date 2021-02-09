/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Credits: Originally base off of SQLs provided by MNPS - Metro Nashville Public Schools 
            Sundaresh Srinivasa, Lee Barber, Chris Weber
-- SupportedVersion: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 AcademicSessions output based on a database.
-- Documentation: For documentation on OneRoster v1.1 AcademicSessions please follow link bellow.
		Link: http://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452009
		Note: In the OneRoster documentation it mentions that Academic Sessions is a hirearchy.
		In Database this should be: SchoolYear 
								-> Terms in the School Year
								 	-> Sessions in the Term
								 		-> Grading periods in the Session
		Assumptions: If the edfi school year is not current we are making the one roster status 'tobedeleted'

--Notes
	Date Format: You must write all the dates on the views in the required format: CONVERT(varchar(50), CAST(<your date> AS datetimeoffset), 127)
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllAcademicSessions
AS

-- SchoolYears
SELECT       
	SYT.Id									AS sourceId
    , CASE 		
	  WHEN  currentschoolyear='1' THEN 'active'		
	  ELSE 'tobedeleted' END				AS status
    , SYT.LastModifiedDate					AS dateLastModified
	, NULL									AS metadata
	, SYT.SchoolYearDescription				AS title
    , MIN(SES.BeginDate)					AS startDate
    , MAX(SES.EndDate)						AS endDate
	, 'schoolYear'							AS type
	, CONCAT('{ "sourceId":"', NULL, '" }')	AS parent
	, NULL									AS children
    , SYT.SchoolYear						AS schoolYear
	, ''									AS schoolId
FROM edfi.SchoolYearType AS SYT
INNER JOIN edfi.Session AS SES ON SYT.SchoolYear = SES.SchoolYear
--WHERE SES.SchoolId=1010
Group by SYT.Id, SYT.SchoolYear, SYT.CurrentSchoolYear, SYT.LastModifiedDate, SYT.SchoolYearDescription--,SES.SchoolId
UNION ALL
--Terms
SELECT       
	TDE.Id										AS sourceId
    , CASE 		
	  WHEN  currentschoolyear='1' THEN 'active'		
	  ELSE 'tobedeleted' END					AS status
    , MAX(SES.LastModifiedDate)					AS dateLastModified
	, NULL										AS metadata
	, TDE.CodeValue								AS title
    , MIN(SES.BeginDate)						AS startDate
    , MAX(SES.EndDate)							AS endDate
	, 'term'									AS type
	, CONCAT('{ "sourceId":"', SYT.Id, '" }')	AS parent
	, NULL										AS children
    , SYT.SchoolYear							AS schoolYear
	, ''										AS SchoolId
FROM edfi.SchoolYearType AS SYT
INNER JOIN edfi.Session AS SES ON SYT.SchoolYear = SES.SchoolYear
INNER JOIN edfi.Descriptor TDE ON ses.TermDescriptorId = TDE.DescriptorId
Group by SYT.Id, SYT.SchoolYear, SYT.CurrentSchoolYear, TDE.Id, TDE.CodeValue--,SES.SchoolId
UNION ALL
-- Sessions
SELECT       
	SES.Id									  	AS sourceId
    , CASE 
	  WHEN SYT.CurrentSchoolYear = '1' THEN 'active'
	  ELSE 'tobedeleted' END					AS status
    , SES.LastModifiedDate						AS dateLastModified
	, NULL										AS metadata
	, SES.SessionName							AS title
    , SES.BeginDate								AS startDate
    , SES.EndDate								AS endDate
	, 'semester'								AS type
	, CONCAT('{ "sourceId":"', TDE.Id, '" }')	AS parent
	, NULL										AS children
    , SES.SchoolYear							AS schoolYear
	, SES.SchoolId								AS SchoolId
FROM edfi.Session AS SES
INNER JOIN edfi.SchoolYearType AS SYT ON SES.SchoolYear = SYT.SchoolYear
LEFT JOIN edfi.Descriptor TDE ON ses.TermDescriptorId = TDE.DescriptorId
UNION ALL
-- Grading Periods
SELECT 
	GP.Id										AS sourceId
	, CASE  
	  WHEN SYT.CurrentSchoolYear = '1' THEN 'active'
	  ELSE 'tobedeleted' END					AS status
	, GP.LastModifiedDate						AS dateLastModified
	, NULL										AS metadata
	, DES.CodeValue								AS title
	, GP.BeginDate								AS startDate
	, GP.EndDate								AS endDate
	, 'gradingPeriod'							AS type
	, CONCAT('{ "sourceId":"', SES.Id, '" }')	AS parent
	, NULL										AS children
	, GP.SchoolYear								AS schoolYear
	, GP.SchoolId								AS SchoolId
FROM edfi.GradingPeriod AS GP
INNER JOIN edfi.Descriptor AS DES ON DES.DescriptorId = GP.GradingPeriodDescriptorId
INNER JOIN edfi.SessionGradingPeriod AS SGP 
	ON SGP.GradingPeriodDescriptorId = GP.GradingPeriodDescriptorId 
	AND SGP.SchoolId = GP.SchoolId
INNER JOIN edfi.Session AS SES 
	ON SGP.SessionName = SES.SessionName 
	AND SES.SchoolId = SGP.SchoolId 
	AND SES.SchoolYear = SGP.SchoolYear
INNER JOIN edfi.SchoolYearType AS SYT ON SES.SchoolYear = SYT.SchoolYear;
