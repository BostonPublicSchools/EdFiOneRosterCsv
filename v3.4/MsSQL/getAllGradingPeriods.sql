/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Supported Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Grading Periods output based on a database.
-- Documentation: A Grading Period (GP) is the period of time for the entire length of a course or class.  
Most school configurations involve one grading period that lasts an entire year; however, if courses last for shorter 
periods of time (e.g., one month) and do not need to be averaged for final grades, schools may opt to use multiple periods per year. 
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllGradingPeriods
AS
SELECT 
	GP.Id																AS sourceId
	, CASE  
	  WHEN SYT.CurrentSchoolYear = '1' THEN 'active'
	  ELSE 'tobedeleted' END											AS status
	, CONCAT(SGP.SessionName , '-' , REPLACE(des.CodeValue, ' ', '-'))	AS period
	, CONCAT('{ "sourceId":"', SES.Id, '" }')							AS parent
	, GP.SchoolYear														AS schoolYear
	, SGP.schoolId														AS schoolId
	, SGP.sessionName                                          		 	AS sessionName
FROM edfi.GradingPeriod				AS GP
INNER JOIN edfi.Descriptor AS DES ON DES.DescriptorId = GP.GradingPeriodDescriptorId
INNER JOIN edfi.SessionGradingPeriod AS SGP 
	ON SGP.GradingPeriodDescriptorId = GP.GradingPeriodDescriptorId 
	AND SGP.SchoolId = GP.SchoolId
INNER JOIN edfi.Session AS SES 
	ON SGP.SessionName = SES.SessionName 
	AND SGP.SchoolId = SES.SchoolId 
	AND SGP.SchoolYear = SES.SchoolYear
INNER JOIN edfi.SchoolYearType AS SYT ON SES.SchoolYear = SYT.SchoolYear;