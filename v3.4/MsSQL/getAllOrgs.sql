/* =============================================
-- Author: NearShoreDevs.com 
		   Douglas Loyo, Emilio Baez, Roberto Norton
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Supported Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Orgs output based on a database.
-- Documentation: For documentation on OneRoster v1.1 Org please follow link bellow.
		Link: https://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452016
		Assumptions: We are representing the hirearchy between State -> LEAs -> Schools
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllOrgs
AS
--Types: department, school,district,local,state,national
SELECT 
	EO.Id																	AS sourcedId
	, CASE WHEN SD.CodeValue = 'Active' THEN 'active'
		   WHEN SD.CodeValue IS NULL THEN 'active' --Usually LEAs are null ns active.
	  ELSE 'tobedeleted' END												AS status
	, CONVERT(VARCHAR(50),CAST(EO.LastModifiedDate AS datetimeoffset),127)	AS dateLastModified
	, EO.NameOfInstitution													AS name
	, CASE WHEN SEA.StateEducationAgencyId IS NOT NULL THEN 'state'
		   WHEN LEA.LocalEducationAgencyId IS NOT NULL THEN 'district' 
		   WHEN SCH.SchoolId IS NOT NULL THEN 'school'
	  ELSE 'local' END														AS type
    , EO.EducationOrganizationId											AS identifier
    , CASE WHEN SPA.StateEducationAgencyId IS NOT NULL THEN SEP.Id
		   WHEN LPA.LocalEducationAgencyId IS NOT NULL THEN SLP.Id
	  ELSE NULL END															AS parentSourcedId
	, EO.EducationOrganizationId											AS EducationOrganizationId	
	
FROM edfi.EducationOrganization	AS EO
LEFT JOIN edfi.Descriptor SD ON EO.OperationalStatusDescriptorId = SD.DescriptorId
LEFT JOIN edfi.StateEducationAgency SEA ON EO.EducationOrganizationId = SEA.StateEducationAgencyId
LEFT JOIN edfi.LocalEducationAgency LEA ON EO.EducationOrganizationId = LEA.LocalEducationAgencyId
LEFT JOIN edfi.School SCH ON EO.EducationOrganizationId = SCH.SchoolId
-- Joining to find the Parent of LEAs which should be the State
LEFT JOIN edfi.StateEducationAgency SPA ON LEA.StateEducationAgencyId = SPA.StateEducationAgencyId
LEFT JOIN edfi.EducationOrganization SEP ON SPA.StateEducationAgencyId = SEP.EducationOrganizationId
-- Joining to find the Parent of Schools which should be LEA.
LEFT JOIN edfi.LocalEducationAgency LPA ON SCH.LocalEducationAgencyId = LPA.LocalEducationAgencyId
LEFT JOIN edfi.EducationOrganization SLP ON LPA.LocalEducationAgencyId = SLP.EducationOrganizationId;