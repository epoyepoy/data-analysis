CREATE VIEW vwEqUtilizationWithCostPerYear AS
SELECT 
	dbo.vwEquipmentCostPerYear.EQPTCODE AS CodeNo,
	dbo.vwEquipmentCostPerYear.YEAR AS OperatingYear,
	dbo.vwEquipmentUtilization.Idle AS IdleMonths,
	dbo.vwEquipmentUtilization.Oper AS OperatingMonths,
	dbo.vwEquipmentUtilization.IdlePercent,
	dbo.vwEquipmentUtilization.OperPercent,
	dbo.vwEquipmentUtilization.OpHours AS TotalOpHours,
	dbo.vwEquipmentUtilization.AvgOpHours,
	dbo.vwEquipmentCostPerYear.Depreciation,
	dbo.vwEquipmentCostPerYear.Insurance,
	dbo.vwEquipmentCostPerYear.RegFees,
	dbo.vwEquipmentCostPerYear.Fuel,
	dbo.vwEquipmentCostPerYear.Lubes,
	dbo.vwEquipmentCostPerYear.Labour,
	dbo.vwEquipmentCostPerYear.SpareParts,
	dbo.vwEquipmentCostPerYear.Repair3rdP,
	dbo.vwEquipmentCostPerYear.ConsIndir,
	dbo.vwEquipmentCostPerYear.ConsDirect,
	dbo.vwEquipmentCostPerYear.TyresTubes,
	dbo.vwEquipmentCostPerYear.Materials,
	dbo.vwEquipmentCostPerYear.DryDock,
	dbo.vwEquipmentCostPerYear.TotalCost
FROM
	dbo.vwEquipmentCostPerYear
LEFT JOIN
	dbo.vwEquipmentUtilization
ON
	dbo.vwEquipmentCostPerYear.id = dbo.vwEquipmentUtilization.id