
/* =============================================
-- Author: NearShoreDevs.com 
		   Roberto Norton, Douglas Loyo, Emilio Baez
-- Created for:  Great Oaks Charter with support from MSDF - The Michael and Susan Dell Foundation
-- Credits: Originally base off of SQLs provided by MNPS - Metro Nashville Public Schools 
            Sundaresh Srinivasa, Lee Barber, Chris Weber
-- Supported  Version: 3.4.0
-- Description: This view provides IMS Global OneRoster v1.1 Demographics output based on a database.
-- Documentation: For documentation on OneRoster v1.1 Demographic Data please follow link bellow.
		Link: https://www.imsglobal.org/oneroster-v11-final-specification#_Toc480452012
-- ============================================= */

CREATE VIEW onerosterv11csv.getAllDemographics
AS
SELECT 
	STA.Id																															AS sourceId
	, CASE WHEN (SELECT TOP 2 COUNT(SEOAAT.StaffUSI) FROM edfi.StaffEducationOrganizationAssignmentAssociation SEOAAT 
	WHERE SEOAAT.StaffUSI = SEOAA.StaffUSI GROUP BY SEOAAT.StaffUSI) = 1 AND SEOAA.EndDate IS NULL 
	THEN 'active' ELSE 'tobedeleted' END 																							AS status
    , CONVERT(VARCHAR(50),CAST(STA.LastModifiedDate AS datetimeoffset),127)                                                       	AS dateLastModified
	, NULL                     																										AS metadata
	, CASE WHEN SED.CodeValue = 'Female' THEN 'female' ELSE 'male' END																AS sex
	, CAST(CASE WHEN RAD.CodeValue = 'American Indian - Alaska Native' THEN 1 ELSE 0 END AS BIT)									AS americanIndianOrAlaskaNative 
	, CAST(CASE WHEN RAD.CodeValue = 'Asian' THEN 1 ELSE 0 END AS BIT)																AS asian
    , CAST(CASE WHEN RAD.CodeValue = 'Black - African American' THEN 1 ELSE 0 END AS BIT)											AS blackOrAfricanAmerican
    , CAST(CASE WHEN RAD.CodeValue = 'Native Hawaiian - Pacific Islander' THEN 1 ELSE 0 END AS BIT)									AS nativeHawaiianOrOtherPacificIslander
	, CAST(CASE WHEN RAD.CodeValue = 'White' THEN 1 ELSE 0 END AS BIT)																AS white
    , CAST(CASE WHEN RAD.CodeValue = 'Other' THEN 1 ELSE 0 END AS BIT)																AS demographicRaceTwoOrMoreRaces
	, STA.HispanicLatinoEthnicity																									AS hispanicOrLatinoEthnicity
	, NULL																															AS countryOfBirthCode
	, NULL																															AS stateOfBirthAbbreviation
    , NULL																															AS cityOfBirth
    , NULL																															AS publicSchoolResidenceStatus
FROM edfi.Staff STA
INNER JOIN edfi.StaffEducationOrganizationAssignmentAssociation SEOAA
	ON STA.StaffUSI = SEOAA.StaffUSI
LEFT JOIN edfi.Descriptor SED 
	ON STA.SexDescriptorId = SED.DescriptorId
INNER JOIN edfi.StaffRace SRA 
	ON STA.StaffUSI = SRA.StaffUSI
LEFT JOIN edfi.Descriptor RAD 
	ON SRA.RaceDescriptorId = RAD.DescriptorId

UNION ALL

SELECT 
	STU.Id																															AS sourceId
	, CASE WHEN (SELECT TOP 2 COUNT(SSAT.StudentUSI) FROM edfi.StudentSchoolAssociation SSAT 
	WHERE SSAT.StudentUSI = SSA.StudentUSI GROUP BY SSAT.StudentUSI) = 1 AND SSA.ExitWithdrawDate IS NULL 
	THEN 'active' ELSE 'tobedeleted' END 																							AS status
    , CONVERT(VARCHAR(50),CAST(STU.LastModifiedDate AS datetimeoffset),127)                                                        	AS dateLastModified
	, NULL                                                                                                                          AS metadata
	, CASE WHEN SED.CodeValue = 'Female' THEN 'female' ELSE 'male' END																AS sex
	, CAST(CASE WHEN RAD.CodeValue = 'American Indian - Alaska Native' THEN 1 ELSE 0 END AS BIT)									AS americanIndianOrAlaskaNative 
	, CAST(CASE WHEN RAD.CodeValue = 'Asian' THEN 1 ELSE 0 END AS BIT)																AS asian
    , CAST(CASE WHEN RAD.CodeValue = 'Black - African American' THEN 1 ELSE 0 END AS BIT)											AS blackOrAfricanAmerican
    , CAST(CASE WHEN RAD.CodeValue = 'Native Hawaiian - Pacific Islander' THEN 1 ELSE 0 END AS BIT)									AS nativeHawaiianOrOtherPacificIslander
	, CAST(CASE WHEN RAD.CodeValue = 'White' THEN 1 ELSE 0 END AS BIT)																AS white
    , CAST(CASE WHEN RAD.CodeValue = 'Other' THEN 1 ELSE 0 END AS BIT)																AS demographicRaceTwoOrMoreRaces
	, SEOA.HispanicLatinoEthnicity																									AS hispanicOrLatinoEthnicity
	, COD.CodeValue																													AS countryOfBirthCode
    , SAD.CodeValue																													AS stateOfBirthAbbreviation
	, STU.BirthCity																													AS cityOfBirth
	, NULL																															AS publicSchoolResidenceStatus
FROM edfi.Student STU
INNER JOIN edfi.StudentSchoolAssociation SSA 
	ON STU.StudentUSI = SSA.StudentUSI
LEFT JOIN edfi.Descriptor SED 
	ON STU.BirthSexDescriptorId = SED.DescriptorId
INNER JOIN edfi.StudentEducationOrganizationAssociation SEOA 
	ON STU.StudentUSI = SEOA.StudentUSI
INNER JOIN edfi.StudentEducationOrganizationAssociationRace SEOAR
	ON STU.StudentUSI = SEOAR.StudentUSI
LEFT JOIN edfi.Descriptor RAD 
	ON SEOAR.RaceDescriptorId = RAD.DescriptorId
LEFT JOIN edfi.Descriptor SAD
	ON STU.BirthStateAbbreviationDescriptorId = SAD.DescriptorId
LEFT JOIN edfi.Descriptor COD
	ON STU.BirthCountryDescriptorId = COD.DescriptorId