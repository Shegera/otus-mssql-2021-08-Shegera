
USE WideWorldImporters

CREATE PROCEDURE Sales.SendCountOrdersByCustomerAndPeriod
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustomerId INT,
			@DateFrom DATE,
			@DateTo DATE,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SELECT @Message;

	SET @xml = CAST(@Message AS XML);

	SELECT 
		@CustomerID = R.Iv.value('@CustomerID','INT'),
		@DateFrom = R.Iv.value('@DateFrom','DATE'),
		@DateTo = R.Iv.value('@DateTo','DATE')
	FROM @xml.nodes('/RequestMessage/Customers') as R(Iv);

	IF EXISTS (SELECT * FROM Sales.Orders WHERE CustomerID = @CustomerID)
	BEGIN

		DECLARE @OrdersCount AS INT

		SELECT @OrdersCount = COUNT (Orders.OrderID)
		FROM Sales.Orders 
		WHERE 
			Orders.CustomerID = @CustomerId AND
			Orders.OrderDate BETWEEN @DateFrom AND @DateTo
		
		INSERT INTO [ReportCustomerOrders] (CustomerID, OrdersCount, DateFrom, DateTo) VALUES
		(@CustomerId, @OrdersCount, @DateFrom, @DateTo)

	END;


	
	--SELECT @Message AS ReceivedRequestMessage, @MessageType; 
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);


		END CONVERSATION @TargetDlgHandle;
	END 
	
	--SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END