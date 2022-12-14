USE equipment

SELECT
	CodeNo,
	Description,
	Make,
	Model,
	Capacity,
	PurchYear,
	YearMfd,
	CompEqCode,
	Region,
	Project,
	Sep,
	Oct,
	Nov,
	Dec,
	Jan,
	Feb,
	Mar,
	Apr,
	May,
	Jun,
	Jul,
	Aug,
	SepC,
	FStatus AS OctN,
	IdleSDate,
	CASE
		WHEN IdleSDate = NULL
		THEN NULL
		ELSE DATEDIFF(month, IdleSDate, '2022-10-25' )
	END AS IdleMonths
FROM
	(
--Getting the status for the last 13 months
		SELECT
			CodeNo,
			Description,
			Make,
			Model,
			Capacity,
			PurchYear,
			YearMfd,
			CompEqCode,
			TRIM(ISNULL([2021-09-25],'')) AS Sep,
			TRIM(ISNULL([2021-10-25],'')) AS Oct,
			TRIM(ISNULL([2021-11-25],'')) AS Nov,
			TRIM(ISNULL([2021-12-25],'')) AS Dec,
			TRIM(ISNULL([2022-01-25],'')) AS Jan,
			TRIM(ISNULL([2022-02-25],'')) AS Feb,
			TRIM(ISNULL([2022-03-25],'')) AS Mar,
			TRIM(ISNULL([2022-04-25],'')) AS Apr,
			TRIM(ISNULL([2022-05-25],'')) AS May,
			TRIM(ISNULL([2022-06-25],'')) AS Jun,
			TRIM(ISNULL([2022-07-25],'')) AS Jul,
			TRIM(ISNULL([2022-08-25],'')) AS Aug,
			TRIM(ISNULL([2022-09-25],'')) AS SepC
		FROM
			(
--Getting the equipment description
				SELECT 
					dbo.tblOpStatus.CodeNo,
					dbo.tblM6a.Description,
					dbo.tblM6a.Make,
					dbo.tblM6a.Model,
					dbo.tblM6a.Capacity,
					dbo.tblM6a.PurchYear,
					dbo.tblM6a.YearMfd,
					dbo.tblM6a.CompEqCode,
					dbo.tblOpStatus.Status,
					CAST(dbo.tblOpStatus.RD AS date) AS rDate
				FROM
					dbo.tblOpStatus
				INNER JOIN
					dbo.tblM6a
				ON
					dbo.tblOpStatus.CodeNo = dbo.tblM6a.CodeNo
				WHERE
					dbo.tblOpStatus.RD BETWEEN '2021-09-25' AND '2022-09-25' AND
					dbo.tblM6a.rMonth = 9 AND
					dbo.tblM6a.rYear = 2022
			)
		AS SourceTable
		PIVOT
			(
				MAX(Status)
				FOR rDate
				IN 
					([2021-09-25],
					[2021-10-25],
					[2021-11-25],
					[2021-12-25],
					[2022-01-25],
					[2022-02-25],
					[2022-03-25],
					[2022-04-25],
					[2022-05-25],
					[2022-06-25],
					[2022-07-25],
					[2022-08-25],
					[2022-09-25])
			)
		AS PivotTable
	)
AS Chunk1
--Project description and region of the site reporting the status
JOIN
	(
		SELECT 
			dbo.tblOpStatus.CodeNo AS ItemCode, 
			dbo.tblSites.siteregion AS Region, 
			dbo.tblSites.sitedescription AS Project,
			CAST(dbo.tblOpStatus.RD AS date) AS rDate
		FROM 
			dbo.tblOpStatus
		JOIN
			dbo.tblSites
		ON
			dbo.tblOpStatus.Site = dbo.tblSites.siteabbreviation
		WHERE 
			dbo.tblOpStatus.RD = '2022-09-25'
	)
AS Chunk2
ON Chunk1.CodeNo = Chunk2.ItemCode
--Number of idle months since the last operational
LEFT JOIN
	(
		SELECT
			dbo.tblOpStatus.CodeNo as CodeNos,
			MAX(dbo.tblOpStatus.Status) as Status,
			DATEADD(month,1,MAX(CAST(dbo.tblOpStatus.RD AS date))) as IdleSDate
		FROM 
			dbo.tblOpStatus
		JOIN
			(
				SELECT *
				FROM 
					dbo.tblOpStatus
				JOIN
					(
						SELECT CodeNo As Code
						FROM
							dbo.tblM6a
						WHERE
							rMonth = 9 AND
							rYear = 2022
					)
				AS Params
				ON
					dbo.tblOpStatus.CodeNo = Params.Code
				WHERE 
					RD = '2022-09-25' AND
					Status LIKE 'I%'
			)
		AS ParamTable
		ON
			dbo.tblOpStatus.CodeNo = ParamTable.CodeNo
		WHERE 
			dbo.tblOpStatus.Status LIKE 'O%'
		GROUP BY 
			dbo.tblOpStatus.CodeNo
	)
AS Chunk3
ON
Chunk1.CodeNo = Chunk3.CodeNos
--Next or forecast status
JOIN
	(
		SELECT
			CodeNo as Code, 
			TRIM(FStatus) as FStatus
		FROM
			dbo.tblOpStatus
		WHERE
			RD = '2022-09-25'
	)
AS Chunk4
ON
Chunk1.CodeNo = Chunk4.Code