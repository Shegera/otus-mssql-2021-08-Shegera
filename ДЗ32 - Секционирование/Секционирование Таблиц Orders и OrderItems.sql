
USE MyCompany

SELECT  
	$PARTITION.fnQuarterPartition(OrderDate) AS Partition, 
	COUNT(*) AS [COUNT], 
	MIN(OrderDate),
	MAX(OrderDate) 
FROM Orders
GROUP BY $PARTITION.fnQuarterPartition(OrderDate) 
ORDER BY Partition ; 

SELECT  
	$PARTITION.fnQuarterPartition(OrderDate) AS Partition, 
	COUNT(*) AS [COUNT], 
	MIN(OrderDate),
	MAX(OrderDate) 
FROM OrderItems
GROUP BY $PARTITION.fnQuarterPartition(OrderDate) 
ORDER BY Partition ; 

