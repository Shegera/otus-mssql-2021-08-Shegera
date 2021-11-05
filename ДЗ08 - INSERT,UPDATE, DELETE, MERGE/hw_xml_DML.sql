USE [WideWorldImporters]
GO


BEGIN TRAN

DECLARE @T	 AS TABLE (ID	INT)

INSERT INTO [Sales].[Customers]
           ([CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
OUTPUT INSERTED.CustomerID INTO @T
SELECT
	[CustomerName] + CAST (X.CustomerID AS VARCHAR (10))
    ,[BillToCustomerID]
    ,[CustomerCategoryID]
    ,[BuyingGroupID]
    ,[PrimaryContactPersonID]
    ,[AlternateContactPersonID]
    ,[DeliveryMethodID]
    ,[DeliveryCityID]
    ,[PostalCityID]
    ,[CreditLimit]
    ,[AccountOpenedDate]
    ,[StandardDiscountPercentage]
    ,[IsStatementSent]
    ,[IsOnCreditHold]
    ,[PaymentDays]
    ,[PhoneNumber]
    ,[FaxNumber]
    ,[DeliveryRun]
    ,[RunPosition]
    ,[WebsiteURL]
    ,[DeliveryAddressLine1]
    ,[DeliveryAddressLine2]
    ,[DeliveryPostalCode]
    ,[DeliveryLocation]
    ,[PostalAddressLine1]
    ,[PostalAddressLine2]
    ,[PostalPostalCode]
    ,[LastEditedBy]
FROM
	Sales.Customers
JOIN
	(
		SELECT
			CustomerID
		FROM
			Sales.Customers
		WHERE
			CustomerID <= 5
	) AS x ON
	1=1
WHERE
	Customers.CustomerID = 1

SELECT
	Customers.*
FROM
	@T AS t
JOIN
	Sales.Customers WITH (NOLOCK) ON
	CustomerID = t.ID

DELETE Sales.Customers WHERE CustomerID = 
	(
		SELECT
			MAX(CustomerID)
		FROM
			Sales.Customers
	)


SELECT
	PrimaryContactPersonID,
	AlternateContactPersonID
FROM
	Sales.Customers
WHERE
	CustomerID = 
	(
		SELECT
			MAX(CustomerID)
		FROM
			Sales.Customers
	)

UPDATE
	Customers
SET
	PrimaryContactPersonID = 1002,
	AlternateContactPersonID = 1001
FROM
	Sales.Customers
WHERE
	CustomerID = 
	(
		SELECT
			MAX(CustomerID)
		FROM
			Sales.Customers
	)


SELECT
	PrimaryContactPersonID,
	AlternateContactPersonID
FROM
	Sales.Customers
WHERE
	CustomerID = 
	(
		SELECT
			MAX(CustomerID)
		FROM
			Sales.Customers
	)

MERGE Sales.Customers AS TARGET 
USING
	(
		SELECT
			[CustomerName] + CAST (X.CustomerID AS VARCHAR (10)) AS CustomerName
			,[BillToCustomerID]
			,[CustomerCategoryID]
			,[BuyingGroupID]
			,[PrimaryContactPersonID]
			,[AlternateContactPersonID]
			,[DeliveryMethodID]
			,[DeliveryCityID]
			,[PostalCityID]
			,[CreditLimit]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[DeliveryRun]
			,[RunPosition]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[DeliveryPostalCode]
			,[DeliveryLocation]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			,[PostalPostalCode]
			,[LastEditedBy]
		FROM
			Sales.Customers
		JOIN
			(
				SELECT
					CustomerID
				FROM
					Sales.Customers
				WHERE
					CustomerID <= 5
			) AS x ON
			1=1
		WHERE
			Customers.CustomerID = 1
	)
AS SOURCE (
			[CustomerName]
			,[BillToCustomerID]
			,[CustomerCategoryID]
			,[BuyingGroupID]
			,[PrimaryContactPersonID]
			,[AlternateContactPersonID]
			,[DeliveryMethodID]
			,[DeliveryCityID]
			,[PostalCityID]
			,[CreditLimit]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[DeliveryRun]
			,[RunPosition]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[DeliveryPostalCode]
			,[DeliveryLocation]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			,[PostalPostalCode]
			,[LastEditedBy]
)
ON
(TARGET.CustomerName = SOURCE.CustomerName)
WHEN
	MATCHED
THEN
	UPDATE SET
	[CustomerName]					 = SOURCE.[CustomerName]				,	 
	[BillToCustomerID]				 = SOURCE.[BillToCustomerID]			,	 
	[CustomerCategoryID]			 = SOURCE.[CustomerCategoryID]			, 
	[BuyingGroupID]					 = SOURCE.[BuyingGroupID]				,	 
	[PrimaryContactPersonID]		 = SOURCE.[PrimaryContactPersonID]		, 
	[AlternateContactPersonID]		 = SOURCE.[AlternateContactPersonID]	,	 
	[DeliveryMethodID]				 = SOURCE.[DeliveryMethodID]			,	 
	[DeliveryCityID]				 = SOURCE.[DeliveryCityID]				, 
	[PostalCityID]					 = SOURCE.[PostalCityID]				,	 
	[CreditLimit]					 = SOURCE.[CreditLimit]					, 
	[AccountOpenedDate]				 = SOURCE.[AccountOpenedDate]			,	 
	[StandardDiscountPercentage]	 = SOURCE.[StandardDiscountPercentage]	, 
	[IsStatementSent]				 = SOURCE.[IsStatementSent]				, 
	[IsOnCreditHold]				 = SOURCE.[IsOnCreditHold]				, 
	[PaymentDays]					 = SOURCE.[PaymentDays]					, 
	[PhoneNumber]					 = SOURCE.[PhoneNumber]					, 
	[FaxNumber]						 = SOURCE.[FaxNumber]					,	 
	[DeliveryRun]					 = SOURCE.[DeliveryRun]					, 
	[RunPosition]					 = SOURCE.[RunPosition]					, 
	[WebsiteURL]					 = SOURCE.[WebsiteURL]					, 
	[DeliveryAddressLine1]			 = SOURCE.[DeliveryAddressLine1]		,	 
	[DeliveryAddressLine2]			 = SOURCE.[DeliveryAddressLine2]		,	 
	[DeliveryPostalCode]			 = SOURCE.[DeliveryPostalCode]			, 
	[DeliveryLocation]				 = SOURCE.[DeliveryLocation]			,	 
	[PostalAddressLine1]			 = SOURCE.[PostalAddressLine1]			, 
	[PostalAddressLine2]			 = SOURCE.[PostalAddressLine2]			, 
	[PostalPostalCode]				 = SOURCE.[PostalPostalCode]			,	 
	[LastEditedBy]					 = SOURCE.[LastEditedBy]				
WHEN
	NOT MATCHED
THEN
	INSERT (
		[CustomerName]					,
		[BillToCustomerID]				,
		[CustomerCategoryID]			,
		[BuyingGroupID]					,
		[PrimaryContactPersonID]		,
		[AlternateContactPersonID]		,
		[DeliveryMethodID]				,
		[DeliveryCityID]				,
		[PostalCityID]					,
		[CreditLimit]					,
		[AccountOpenedDate]				,
		[StandardDiscountPercentage]	,
		[IsStatementSent]				,
		[IsOnCreditHold]				,
		[PaymentDays]					,
		[PhoneNumber]					,
		[FaxNumber]						,
		[DeliveryRun]					,
		[RunPosition]					,
		[WebsiteURL]					,
		[DeliveryAddressLine1]			,
		[DeliveryAddressLine2]			,
		[DeliveryPostalCode]			,
		[DeliveryLocation]				,
		[PostalAddressLine1]			,
		[PostalAddressLine2]			,
		[PostalPostalCode]				,
		[LastEditedBy]					
	)
	VALUES (
		SOURCE.[CustomerName]					,
		SOURCE.[BillToCustomerID]				,
		SOURCE.[CustomerCategoryID]				,
		SOURCE.[BuyingGroupID]					,
		SOURCE.[PrimaryContactPersonID]			,
		SOURCE.[AlternateContactPersonID]		,
		SOURCE.[DeliveryMethodID]				,
		SOURCE.[DeliveryCityID]					,
		SOURCE.[PostalCityID]					,
		SOURCE.[CreditLimit]					,
		SOURCE.[AccountOpenedDate]				,
		SOURCE.[StandardDiscountPercentage]		,
		SOURCE.[IsStatementSent]				,
		SOURCE.[IsOnCreditHold]					,
		SOURCE.[PaymentDays]					,
		SOURCE.[PhoneNumber]					,
		SOURCE.[FaxNumber]						,
		SOURCE.[DeliveryRun]					,
		SOURCE.[RunPosition]					,
		SOURCE.[WebsiteURL]						,
		SOURCE.[DeliveryAddressLine1]			,
		SOURCE.[DeliveryAddressLine2]			,
		SOURCE.[DeliveryPostalCode]				,
		SOURCE.[DeliveryLocation]				,
		SOURCE.[PostalAddressLine1]				,
		SOURCE.[PostalAddressLine2]				,
		SOURCE.[PostalPostalCode]				,
		SOURCE.[LastEditedBy]					
	)
OUTPUT DELETED.[CustomerID],DELETED.[PrimaryContactPersonID],DELETED.[AlternateContactPersonID], $action, INSERTED.[CustomerName],INSERTED.[PrimaryContactPersonID],INSERTED.[AlternateContactPersonID]  ;
ROLLBACK TRAN

-- Создание таблицы TestBCP
IF NOT EXISTS 
	(
		SELECT * FROM SYSOBJECTS WHERE name = 'TestBCP'
	)
BEGIN

	SELECT 
		TOP 1
		CustomerName,
		Cities.CityName
	INTO TestBCP
	FROM
		Sales.Customers
	JOIN
		Application.Cities ON
		Cities.CityID = Customers.DeliveryCityID
	WHERE
		1=1
END

-- Наполнение таблицы TestBCP
INSERT INTO dbo.TestBCP (
	CustomerName,
	Cities.CityName
)

SELECT 
	TOP 10
	CustomerName,
	Cities.CityName

FROM
	Sales.Customers
JOIN
	Application.Cities ON
	Cities.CityID = Customers.DeliveryCityID
WHERE
	1=1


-- Показываю, что в таблице TestBCP есть данные
SELECT * FROM TestBCP

-- Выгружаю данные таблицы TestBCP в текстовый файл
exec master..xp_cmdshell 'bcp "SELECT TOP 10 Customers.CustomerName, Cities.CityName FROM WideWorldImporters.Sales.Customers JOIN WideWorldImporters.Application.Cities ON Cities.CityID = Customers.DeliveryCityID ORDER BY Customers.CustomerName, Cities.CityName" queryout  "C:\1\BCP.txt" -T -w -t%*% -S MERCURY\SQL2017'

-- Очищаю таблицу TestBCP
TRUNCATE TABLE TestBCP

-- Показываю, что таблица TestBCP пустая
SELECT * FROM TestBCP

-- Загружаю данные в таблицу TestBCP из файла
BULK INSERT [WideWorldImporters].[DBO].[TestBCP]
				FROM "C:\1\BCP.txt"
				WITH 
					(
					BATCHSIZE = 1000, 
					DATAFILETYPE = 'widechar',
					FIELDTERMINATOR = '%*%',
					ROWTERMINATOR ='\n',
					KEEPNULLS,
					TABLOCK        
					);

-- Поуказываю, что данные в таблицу TestBCP загрузились
SELECT * FROM TestBCP

-- Удаляю таблицу TestBCP
DROP TABLE TestBCP
