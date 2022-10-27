USE equipment

CREATE VIEW vwEquipmentUtilization AS
SELECT 
	dbo.vwOperationIdlePerYear.CodeNo,
	dbo.vwOperationIdlePerYear.Year,
	CAST(dbo.vwOperationIdlePerYear.IdleCom AS INT) + CAST(dbo.vwOperationIdlePerYear.IdleSite AS INT) AS Idle,
	CAST(dbo.vwOperationIdlePerYear.Oper AS INT) + CAST(dbo.vwOperationIdlePerYear.ORock AS INT) AS Oper,
	FORMAT(CAST(CAST(CAST(dbo.vwOperationIdlePerYear.IdleCom AS FLOAT(2)) + 
		CAST(dbo.vwOperationIdlePerYear.IdleSite AS FLOAT(2)) AS FLOAT(2)) / 
		CAST(CAST(dbo.vwOperationIdlePerYear.IdleCom AS FLOAT(2)) + CAST(dbo.vwOperationIdlePerYear.IdleSite AS FLOAT(2)) + 
		CAST(dbo.vwOperationIdlePerYear.Oper AS FLOAT(2)) + CAST(dbo.vwOperationIdlePerYear.ORock AS FLOAT(2)) AS FLOAT(2)) AS FLOAT(2)), 'P') AS IdlePercent,
	FORMAT(CAST(CAST(CAST(dbo.vwOperationIdlePerYear.Oper AS FLOAT(2)) + 
		CAST(dbo.vwOperationIdlePerYear.ORock AS FLOAT(2)) AS FLOAT(2)) / 
		CAST(CAST(dbo.vwOperationIdlePerYear.IdleCom AS FLOAT(2)) + CAST(dbo.vwOperationIdlePerYear.IdleSite AS FLOAT(2)) + 
		CAST(dbo.vwOperationIdlePerYear.Oper AS FLOAT(2)) + CAST(dbo.vwOperationIdlePerYear.ORock AS FLOAT(2)) AS FLOAT(2)) AS FLOAT(2)),'P') AS OperPercent,
	CAST(ISNULL(dbo.vwTotalOperatingHoursPerYear.OpHours,0) AS INT) AS OpHours,
	CAST(CAST(ISNULL(dbo.vwTotalOperatingHoursPerYear.OpHours,0) AS INT) /
		CASE
			WHEN CAST(dbo.vwOperationIdlePerYear.Oper AS FLOAT(2)) + CAST(dbo.vwOperationIdlePerYear.ORock AS FLOAT(2)) > 0 
			THEN CAST(dbo.vwOperationIdlePerYear.Oper AS FLOAT(2)) + CAST(dbo.vwOperationIdlePerYear.ORock AS FLOAT(2)) 
			ELSE 1
		END AS FLOAT(2)) AS AvgOpHours,
	dbo.vwOperationIdlePerYear.id
FROM
	dbo.vwOperationIdlePerYear
LEFT JOIN
	dbo.vwTotalOperatingHoursPerYear
ON 
	dbo.vwOperationIdlePerYear.id = dbo.vwTotalOperatingHoursPerYear.id
ORDER BY 
	dbo.vwOperationIdlePerYear.CodeNo,
	dbo.vwOperationIdlePerYear.Year
OFFSET 0 ROWS