
USE MyCompany
------------------------------------------------------------------------

--							Загрузка справочников

------------------------------------------------------------------------

-- Необходимо указать путь до папки с XML файлами для загрузки
DECLARE @ScriptPath AS NVARCHAR (MAX) = 'C:\Users\Андрей\Documents\GitHub\otus-mssql-2021-08-Shegera\Проект\'

-- Запрос, который добавляет в конце пути к файлам загразки \
IF 
	(LEFT (REVERSE (@ScriptPath), 1) != '\')
BEGIN
	SET @ScriptPath = @ScriptPath + '\'
END

DECLARE @SQL AS NVARCHAR (MAX) = ''
SET @SQL = 
'DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK ''' + @ScriptPath + 'Employees.xml'', SINGLE_CLOB)
AS DATA

DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML

MERGE MyCompany.dbo.Employees AS target USING
(
	SELECT
		[Nick],
		[FirstName],
		[SurName],
		[SecondName],
		[FullName],
		[BirthDate]
	FROM
		OPENXML (@docHandle, N''/Employees/Employee'')
	WITH (
		[Nick]			NVARCHAR (50)	''@Nick'',
		[FirstName]		NVARCHAR (50)	''FirstName'',
		[SurName]		NVARCHAR (50)	''SurName'',
		[SecondName]	NVARCHAR (50)	''SecondName'',
		[FullName]		NVARCHAR (50)	''FullName'',
		[BirthDate]		DATE			''BirthDate''
		)
)
AS SOURCE (
	[Nick],
	[FirstName],
	[SurName],
	[SecondName],
	[FullName],
	[BirthDate]			
)
ON
	(target.Nick = source.Nick)
WHEN MATCHED
	THEN
		UPDATE SET 
		[Nick]					 = source.[Nick],
		[FirstName]				 = source.[FirstName],	
		[SurName]				 = source.[SurName],	
		[SecondName]			 = source.[SecondName],
		[FullName]				 = source.[FullName],
		[BirthDate]				 = source.[BirthDate]
WHEN NOT MATCHED
	THEN
		INSERT (
			[Nick],
			[FirstName],		
			[SurName],		
			[SecondName],	
			[FullName],
			[BirthDate]
		)
	VALUES
		(
			source.[Nick],
			source.[FirstName],		
			source.[SurName],		
			source.[SecondName],	
			source.[FullName],
			source.[BirthDate]
		)
OUTPUT $action, inserted.*;'
EXEC (@SQL)


SET @SQL = 
'DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK ''' + @ScriptPath + 'Organisations.xml'', SINGLE_CLOB)
AS DATA

DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML

MERGE MyCompany.dbo.Organisations AS target USING
(
	SELECT
		[INN]					,
		[OrganisationName]		,
		[OrganisationFullName]	,
		[KPP]						
	FROM
		OPENXML (@docHandle, N''/Organisations/Organisation'')
	WITH (
		[INN]					NVARCHAR (20)	''@INN'',
		[OrganisationName]		NVARCHAR (300)	''OrganisationName'',
		[OrganisationFullName]	NVARCHAR (300)	''OrganisationFullName'',
		[KPP]					NVARCHAR (20)	''KPP''
		)
)
AS SOURCE (
	[INN]					,
	[OrganisationName]		,
	[OrganisationFullName]	,
	[KPP]								
)
ON
	(target.INN = source.INN)
WHEN MATCHED
	THEN
		UPDATE SET 
		[INN]					 = source.[INN]						,
		[OrganisationName]		 = source.[OrganisationName]		,
		[OrganisationFullName]	 = source.[OrganisationFullName]	,
		[KPP]					 = source.[KPP]					
WHEN NOT MATCHED
	THEN
		INSERT (
			[INN]					,
			[OrganisationName]		,	
			[OrganisationFullName]	,
			[KPP]								
		)
	VALUES
		(
			source.[INN]					,
			source.[OrganisationName]		,
			source.[OrganisationFullName]	,
			source.[KPP]	
		)
OUTPUT $action, inserted.*;'
EXEC (@SQL)


SET @SQL = 
'DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK ''' + @ScriptPath + 'Partners.xml'', SINGLE_CLOB)
AS DATA

DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML

MERGE MyCompany.dbo.Partners AS target USING
(
	SELECT
		[INN]					,
		[PartnerName]		,
		[PartnerFullName]	,
		[KPP]						
	FROM
		OPENXML (@docHandle, N''/Partners/Partner'')
	WITH (
		[INN]					NVARCHAR (20)	''@INN'',
		[PartnerName]		NVARCHAR (300)	''PartnerName'',
		[PartnerFullName]	NVARCHAR (300)	''PartnerFullName'',
		[KPP]					NVARCHAR (20)	''KPP''
		)
)
AS SOURCE (
	[INN]				,
	[PartnerName]		,
	[PartnerFullName]	,
	[KPP]								
)
ON
	(target.INN = source.INN)
WHEN MATCHED
	THEN
		UPDATE SET 
		[INN]				 = source.[INN]				,
		[PartnerName]		 = source.[PartnerName]		,
		[PartnerFullName]	 = source.[PartnerFullName]	,
		[KPP]				 = source.[KPP]					
WHEN NOT MATCHED
	THEN
		INSERT (
			[INN]				,
			[PartnerName]		,	
			[PartnerFullName]	,
			[KPP]								
		)
	VALUES
		(
			source.[INN]				,
			source.[PartnerName]		,
			source.[PartnerFullName]	,
			source.[KPP]	
		)
OUTPUT $action, inserted.*;'
EXEC (@SQL)

SET @SQL = 
'DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK ''' + @ScriptPath + 'Contracts.xml'', SINGLE_CLOB)
AS DATA


DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML



MERGE MyCompany.dbo.Contracts AS target USING
(
	SELECT
		[ContractID]			,
		[ContractTypeID]		,
		[ContractNumber]		,
		[ContractDate]			,
		[ManagerID]				,
		[Summary]				,
		[ContractStartDate]		,
		[ContractEndDate]		,
		[Indefinite]			,
		[OrganisationID]		,
		[PartnerID]				
	FROM
		OPENXML (@docHandle, N''/Contracts/Contract'')
	WITH (
		[ContractID]			NVARCHAR (20)	''@ContractID'',
		[ContractTypeID]		BIGINT			''ContractTypeID'',
		[ContractNumber]		NVARCHAR (20)	''ContractNumber'',
		[ContractDate]			DATE			''ContractDate'',
		[ManagerID]				BIGINT			''ManagerID'',
		[Summary]				NVARCHAR (MAX)	''Summary'',
		[ContractStartDate]		DATE			''ContractStartDate'',
		[ContractEndDate]		DATE			''ContractEndDate'',
		[Indefinite]			BIT				''Indefinite'',
		[OrganisationID]		BIGINT			''OrganisationID'',
		[PartnerID]				BIGINT			''PartnerID''
		)
)
AS SOURCE (
		[ContractID]			,
		[ContractTypeID]		,
		[ContractNumber]		,
		[ContractDate]			,
		[ManagerID]				,
		[Summary]				,
		[ContractStartDate]		,
		[ContractEndDate]		,
		[Indefinite]			,
		[OrganisationID]		,
		[PartnerID]										
)
ON
	(target.ContractID = source.ContractID)
WHEN MATCHED
	THEN
		UPDATE SET 
		[ContractTypeID]	= source.[ContractTypeID]	,
		[ContractNumber]	= source.[ContractNumber]	,
		[ContractDate]		= source.[ContractDate]		,
		[ManagerID]			= source.[ManagerID]		,
		[Summary]			= source.[Summary]			,
		[ContractStartDate]	= source.[ContractStartDate],
		[ContractEndDate]	= source.[ContractEndDate]	,
		[Indefinite]		= source.[Indefinite]		,
		[OrganisationID]	= source.[OrganisationID]	,
		[PartnerID]			= source.[PartnerID]			
WHEN NOT MATCHED
	THEN
		INSERT (
			[ContractTypeID]		,
			[ContractNumber]		,
			[ContractDate]			,
			[ManagerID]				,
			[Summary]				,
			[ContractStartDate]		,
			[ContractEndDate]		,
			[Indefinite]			,
			[OrganisationID]		,
			[PartnerID]											
		)
	VALUES
		(
			source.[ContractTypeID]		,
			source.[ContractNumber]		,
			source.[ContractDate]		,
			source.[ManagerID]			,
			source.[Summary]			,
			source.[ContractStartDate]	,
			source.[ContractEndDate]	,
			source.[Indefinite]			,
			source.[OrganisationID]		,
			source.[PartnerID]			
		)
OUTPUT $action, inserted.*;'
EXEC (@SQL)

SET @SQL = 
'DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK ''' + @ScriptPath + 'Items.xml'', SINGLE_CLOB)
AS DATA


DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML



MERGE MyCompany.dbo.Items AS target USING
(
	SELECT
		[ItemID]			,
		[ItemName]			,
		[UnitPrice]				
	FROM
		OPENXML (@docHandle, N''/Items/Item'')
	WITH (
		[ItemID]			BIGINT			''@ItemID'',
		[ItemName]			NVARCHAR (300)	''ItemName'',
		[UnitPrice]			DECIMAL (12,2)	''UnitPrice''
		)
)
AS SOURCE (
		[ItemID]			,
		[ItemName]			,
		[UnitPrice]												
)
ON
	(target.ItemID = source.ItemID)
WHEN MATCHED
	THEN
		UPDATE SET 
		[ItemName]			= source.[ItemName]			,
		[UnitPrice]			= source.[UnitPrice]		
WHEN NOT MATCHED
	THEN
		INSERT (
			[ItemName]			,
			[UnitPrice]											
		)
	VALUES
		(
			source.[ItemName]		,
			source.[UnitPrice]		
		)
OUTPUT $action, inserted.*;'
EXEC (@SQL)


SET @SQL = 
'DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK ''' + @ScriptPath + 'Orders.xml'', SINGLE_CLOB)
AS DATA


DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML



MERGE MyCompany.dbo.Orders AS target USING
(
	SELECT
		[OrderID]			,
		[ContractID]		,
		[OrderNumber]		,
		[OrderDate]			,
		[ManagerID]
	FROM
		OPENXML (@docHandle, N''/Orders/Order'')
	WITH (
		[OrderID]			BIGINT			''@OrderID'',
		[ContractID]		BIGINT			''ContractID'',
		[OrderNumber]		NVARCHAR (300)	''OrderNumber'',
		[OrderDate]			DATE			''OrderDate'',
		[ManagerID]			BIGINT			''ManagerID''
		)
)
AS SOURCE (
		[OrderID]			,
		[ContractID]		,
		[OrderNumber]		,
		[OrderDate]			,
		[ManagerID]											
)
ON
	(target.OrderID = source.OrderID)
WHEN MATCHED
	THEN
		UPDATE SET 
		[ContractID]		= source.[ContractID]		,
		[OrderNumber]		= source.[OrderNumber]		,
		[OrderDate]			= source.[OrderDate]		,
		[ManagerID]			= source.[ManagerID]			
WHEN NOT MATCHED
	THEN
		INSERT (
			[ContractID]		,
			[OrderNumber]		,
			[OrderDate]			,
			[ManagerID]											
		)
	VALUES
		(
			 source.[ContractID]		,
			 source.[OrderNumber]		,
			 source.[OrderDate]			,
			 source.[ManagerID]			
		)
OUTPUT $action, inserted.*;'
EXEC (@SQL)

SET @SQL = 
'DECLARE @XML	AS XML

SELECT
	@XML = bulkcolumn
FROM
	OPENROWSET
( BULK ''' + @ScriptPath + 'OrderItems.xml'', SINGLE_CLOB)
AS DATA


DECLARE @docHandle AS INT
EXEC sp_xml_preparedocument @docHandle OUT, @XML



MERGE MyCompany.dbo.OrderItems AS target USING
(
	SELECT
		[OrderItemID]	,
		[OrderID]		,
		[OrderDate]		,
		[ItemID]		,
		[Price]			,
		[Quantity]		
	FROM
		OPENXML (@docHandle, N''/OrderItems/OrderItem'')
	WITH (
		[OrderItemID]		BIGINT			''@OrderItemID'',
		[OrderID]		BIGINT			''OrderID'',
		[OrderDate]		DATE			''OrderDate'',
		[ItemID]		BIGINT			''ItemID'',
		[Price]			DECIMAL (12,2)	''Price'',
		[Quantity]		BIGINT			''Quantity''
		)
)
AS SOURCE (
		[OrderItemID]		 ,
		[OrderID]		 ,
		[OrderDate]		 ,
		[ItemID]		 ,
		[Price]			 ,
		[Quantity]										
)
ON
	(target.OrderItemID = source.OrderItemID)
WHEN MATCHED
	THEN
		UPDATE SET 
		[OrderID]		= source.[OrderID]		 ,
		[OrderDate]	 	= source.[OrderDate]	 ,
		[ItemID]	 	= source.[ItemID]		 ,
		[Price]		 	= source.[Price]		 ,
		[Quantity]		= source.[Quantity]				
WHEN NOT MATCHED
	THEN
		INSERT (
			[OrderID]		 ,
			[OrderDate]		 ,
			[ItemID]		 ,
			[Price]			 ,
			[Quantity]											
		)
	VALUES
		(
			source.[OrderID]	 ,
			source.[OrderDate]	 ,
			source.[ItemID]		 ,
			source.[Price]		 ,
			source.[Quantity]				
		)
OUTPUT $action, inserted.*;'
EXEC (@SQL)

UPDATE
OrderItems
SET
OrderItemS.Price = Items.UnitPrice * OrderItemS.Quantity
FROM OrderItems JOIN
Items ON OrderItems.ITEMID = Items.ItemID
SELECT OrderItems.*, Items.UnitPrice FROM OrderItems JOIN
Items ON OrderItems.ITEMID = Items.ItemID

USE master