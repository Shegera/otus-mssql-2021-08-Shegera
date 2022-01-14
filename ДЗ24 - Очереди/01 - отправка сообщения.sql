
USE WideWorldImporters


CREATE PROCEDURE Sales.GetCountOrdersByCustomerAndPeriod
	@CustomerId INT,
	@DateFrom DATE,
	@DateTo DATE
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Prepare the Message
	SELECT @RequestMessage = (SELECT 
									CustomerID, 
									@DateFrom	AS DateFrom, 
									@DateTo		AS DateTo
							  FROM Sales.Customers AS Customers
							  WHERE Customers.CustomerID = @CustomerId
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);

	COMMIT TRAN 
END
GO



