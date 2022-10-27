USE equipment

SELECT
	 _Group,
	 Class,
	 _GroupDesc,
	MIN(Capacity) as MinCapacity,
	MAX(Capacity) as MaxCapacity,
	UoM,
	COUNT(_Group) as TotalUnits,
	MAX(TotalOperUnits) as OperUnits,
	MAX(TotalIdleUnits) as IdleUnits,
	Country,
	ID
FROM
	(
		SELECT
			LEFT(NewCode, 6) as _Group,
			CONVERT(int,Class) as Class,
			NewCode,
			CONVERT(decimal(18,2),CONCAT(LEFT(LEFT(RIGHT(NewCode, 15), 6),5),'.',RIGHT(LEFT(RIGHT(NewCode, 15), 6),1))) as Capacity,
			SiteCode,
			sitecountry as Country,
			CONCAT(LEFT(NewCode, 6), sitecountry) as ID
		FROM
			dbo.tblM6a
		JOIN
			(
				SELECT
					sitecodeone,
					sitecountry
				FROM
					dbo.tblSites
			)
		AS CountryRef
		ON
			dbo.tblM6a.SiteCode = CountryRef.sitecodeone
		WHERE
			rMonth = 9 AND
			rYear = 2022 AND
			NewCode <> '' AND
			SiteCode <> ''
		) AS Source1
JOIN
	(
		SELECT
			_Group as Grp,
			_GroupDesc,
			ISNULL(UOM,'') as UoM
		FROM
			dbo.tblSubClassAndGroup
	) AS Source2
ON Source1._Group = Source2.Grp

LEFT JOIN
	(
		SELECT
			GP,
			SUM(Idle) as TotalIdleUnits,
			SUM(Oper) as TotalOperUnits,
			sitecountry as SiteC,
			IDs
		FROM
			(
				SELECT
					_Group as GP,
					CONVERT(int,[IC]+[IS]) as Idle,
					CONVERT(int,[O]+[OR]) as Oper,
					sitecountry,
					CONCAT(_Group,sitecountry) as IDs
				FROM
					(
						SELECT
							CodeNo,
							LEFT(NewCode, 6) as _Group,
							NewCode,
							SiteCode,
							sitecountry,
							TRIM(Status) as OST
						FROM
							dbo.tblM6a
						JOIN
							(
								SELECT	
									CodeNo as CN,
									Status
								FROM
									dbo.tblOpStatus
								WHERE RD = '2022-09-25'
							) as StatusRef
						ON dbo.tblM6a.CodeNo = StatusRef.CN
						JOIN
							(
								SELECT
									sitecodeone,
									sitecountry
								FROM
									dbo.tblSites
							) as SitesRefe
						ON dbo.tblM6a.SiteCode = SitesRefe.sitecodeone
							WHERE
									rMonth = 9 AND
									rYear = 2022 AND
									NewCode <> '' AND
									SiteCode <> ''
							)as DigitCodeRef
					PIVOT
						(
							COUNT(OST)
							FOR OST
							IN([IC], [IS], [O], [OR])
						) as PivotTable
			) as ST
		GROUP BY GP, sitecountry, IDs
	) as Source3
ON Source1.ID = Source3.IDs

GROUP BY _Group,
					Class,
					_GroupDesc,
					UoM,
					Country,
					ID
ORDER BY Class, _GroupDesc