
USE MyCompany

SELECT
	Orders.OrderID,
	OrderItems.ItemID,
	Items.ItemName
FROM
	Orders
JOIN
	OrderItems ON
	OrderItems.OrderID = Orders.OrderID
JOIN
	Items ON
	Items.ItemID = OrderItems.ItemID
WHERE
	Orders.OrderDate = '2021-04-10'


SELECT
	Contracts.ContractNumber,
	Orders.OrderNumber
FROM
	Contracts
JOIN
	Orders ON
	Orders.ContractID = Contracts.ContractID
WHERE
	Contracts.ContractNumber = 'Ò-4/2021'


SELECT
	Contracts.ManagerID,
	SUM (OrderItems.Price)
FROM
	Contracts
JOIN
	Orders ON
	Orders.ContractID = Contracts.ContractID
JOIN
	OrderItems ON
	OrderItems.OrderID = Orders.OrderID
GROUP BY
	Contracts.ManagerID	

USE master