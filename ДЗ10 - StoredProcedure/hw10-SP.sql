-- 1. задание

DROP PROC IF EXISTS dbo.sp_BestCustomer 
GO
;

-- Создание процедуры
CREATE PROC [dbo].[sp_BestCustomer]
AS
BEGIN
	SELECT
		TOP 1
		Customers.CustomerID,
		SUM (InvoiceLines.ExtendedPrice) AS MaxPrice
	FROM
		Sales.Customers WITH (NOLOCK)
	JOIN
		Sales.Invoices WITH (NOLOCK) ON
		Invoices.CustomerID = Customers.CustomerID
	JOIN
		Sales.InvoiceLines WITH (NOLOCK) ON
		InvoiceLines.InvoiceID = Invoices.InvoiceID
	GROUP BY
		Customers.CustomerID
	ORDER BY
		MaxPrice DESC
END;
GO

EXEC [dbo].[sp_BestCustomer]

-------------------------------------------------------------------------------------------------------------------
-- 2. задание

DROP PROC IF EXISTS dbo.sp_AllSalesCustomers
GO
;

CREATE PROC dbo.sp_AllSalesCustomers 
	@CustomerID		INT
AS
BEGIN
	SELECT
		SUM (InvoiceLines.ExtendedPrice)
	FROM
		Sales.Invoices WITH (NOLOCK)
	JOIN
		Sales.InvoiceLines WITH (NOLOCK) ON
		Invoices.InvoiceID = InvoiceLines.InvoiceID
	WHERE
		Invoices.CustomerID = @CustomerID
END;



EXEC dbo.sp_AllSalesCustomers @CustomerID = 1
GO
;
