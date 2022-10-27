USE equipment

SELECT
	codeyr as ID,
	CodeNo,
	Year,
	TotalMonths,
	ISNULL(OperMonths,0) as OperMonths,
	FORMAT(ISNULL(CAST(OperMonths as decimal(18,2))/CAST(TotalMonths as decimal(18,2)), 0), 'P') as OperPercent
FROM
		(
		SELECT
			codeyr,
			CodeNo,
			Yr as Year,
			COUNT(Status) as TotalMonths
		FROM
			dbo.tblOpStatus
			GROUP BY CodeNo, Yr, codeyr
		) AS TM
LEFT JOIN
	(
		SELECT
			codeyr as cy,
			CodeNo as CN,
			Yr,
			COUNT(TRIM(Status)) as OperMonths
		FROM
			dbo.tblOpStatus
		WHERE TRIM(Status) = 'O'
		GROUP BY CodeNo, Yr, codeyr
	) AS OM
ON
	TM.codeyr = OM.cy
	
	


