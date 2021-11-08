


-- 1. �������

DROP FUNCTION IF EXISTS dbo.fn_BestCustomer 
GO
;

CREATE FUNCTION dbo.fn_BestCustomer ()
	RETURNS TABLE
AS
	RETURN (	
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
	)
GO
;


-- ����� �������
SELECT
	*
FROM
	dbo.fn_BestCustomer()





-------------------------------------------------------------------------------------------------------------------
-- 2. �������

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


-------------------------------------------------------------------------------------------------------------------
-- 3. �������

DROP PROC IF EXISTS dbo.sp_Top10CustomerInvoices;
GO
;

CREATE PROC dbo.sp_CustomerInvoices 
	@CustomerID		INT
AS
BEGIN
	SELECT
		FORMAT (Invoices.InvoiceDate, '01.MM.yyyy') AS InvoiceMonth,
		SUM (InvoiceLines.ExtendedPrice) AS Price
	FROM
		Sales.Invoices WITH (NOLOCK)
	JOIN
		Sales.InvoiceLines WITH (NOLOCK) ON
		InvoiceLines.InvoiceID = Invoices.InvoiceID
	WHERE
		Invoices.CustomerID = @CustomerID
	GROUP BY
		FORMAT (Invoices.InvoiceDate, '01.MM.yyyy') 
	ORDER BY 
		CAST (FORMAT (Invoices.InvoiceDate, '01.MM.yyyy') AS DATE)
END	;
GO;

DROP FUNCTION IF EXISTS dbo.fn_CustomerInvoices;
GO
;

CREATE FUNCTION dbo.fn_CustomerInvoices (@CustomerID INT)
	RETURNS TABLE 
AS
	RETURN (
		SELECT
			FORMAT (Invoices.InvoiceDate, '01.MM.yyyy') AS InvoiceMonth,
			SUM (InvoiceLines.ExtendedPrice) AS Price
		FROM
			Sales.Invoices WITH (NOLOCK)
		JOIN
			Sales.InvoiceLines WITH (NOLOCK) ON
			InvoiceLines.InvoiceID = Invoices.InvoiceID
		WHERE
			Invoices.CustomerID = @CustomerID
		GROUP BY
			FORMAT (Invoices.InvoiceDate, '01.MM.yyyy') 

	)
;

-- ����� ������� � �������� ��� ��������� ������������������.
-- �������� � �� ��� ����� �������, �� � ���� ������� � �������� �������� ��������� ������ ��� ������������� ������ � ���� �� ����.
-- �� �������� � ������� � ���������� ����� ����������� ���������.
EXEC dbo.sp_CustomerInvoices @CustomerID = 1

SELECT
	*
FROM
	dbo.fn_CustomerInvoices (1) AS T
ORDER BY 
	CAST (t.InvoiceMonth AS DATE)


-------------------------------------------------------------------------------------------------------------------
-- 4. �������
-- �� ����� ���� �������. ���� ������� n-��� �������, ������� ���������� �������?
