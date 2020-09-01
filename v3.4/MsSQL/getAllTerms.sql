/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Supported Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Terms output based on a database.
-- Documentation: The school year usually runs from early September until May or June (nine months) and is divided into 
'quarters' or terms (semesters). Most schools use a semester system made up of two sessions: fall (September to December) and spring (January to May).
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllTerms
AS
SELECT       
	TDE.Id										AS sourceId
    , CASE 		
	  WHEN  currentschoolyear='1' THEN 'active'		
	  ELSE 'tobedeleted' END					AS status
	, CONCAT('{ "sourceId":"', SYT.Id, '" }')	AS parent
	, SES.sessionName                           AS sessionName
	, SYT.SchoolYear							AS schoolYear
	, TDE.nameSpace                             AS nameSpace
	, TDE.CodeValue								AS term
FROM edfi.SchoolYearType AS SYT
INNER JOIN edfi.Session AS SES ON SYT.SchoolYear = SES.SchoolYear
INNER JOIN edfi.Descriptor TDE ON ses.TermDescriptorId = TDE.DescriptorId
Group by SYT.Id, SYT.SchoolYear, SYT.CurrentSchoolYear, SYT.SchoolYearDescription, SES.sessionName, TDE.Id, TDE.CodeValue, TDE.nameSpace