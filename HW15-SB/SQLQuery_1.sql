GO
ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing DATETIME;


USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER WITH ROLLBACK IMMEDIATE; 

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];
GO

GO
USE WideWorldImporters
CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML;
GO
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 
GO
CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );
GO
GO
GO
CREATE QUEUE TargetQueueWWI;

CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);
GO

CREATE QUEUE InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);
GO
GO
CREATE or ALTER PROCEDURE Sales.SendNewInvoice
	@invoiceId INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	SELECT @RequestMessage = (SELECT InvoiceID
							  FROM Sales.Invoices AS Inv
							  WHERE InvoiceID = @invoiceId
							  FOR XML AUTO, root('RequestMessage')); 
	
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	SELECT @RequestMessage AS SentRequestMessage;
	COMMIT TRAN 
END
GO
GO
CREATE or ALTER PROCEDURE Sales.GetNewInvoice
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@InvoiceID INT,
			@xml XML; 
	
	BEGIN TRAN; 

	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SELECT @Message;

	SET @xml = CAST(@Message AS XML);

	SELECT @InvoiceID = R.Iv.value('@InvoiceID','INT')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	IF EXISTS (SELECT * FROM Sales.Invoices WHERE InvoiceID = @InvoiceID)
	BEGIN
		UPDATE Sales.Invoices
		SET InvoiceDate = GETUTCDATE()
		WHERE InvoiceId = @InvoiceID;
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; 
	
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage;

	COMMIT TRAN;
END
GO

GO
CREATE or ALTER PROCEDURE Sales.ConfirmInvoice
AS
BEGIN
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage;

	COMMIT TRAN; 
END
GO

USE [WideWorldImporters]
GO
ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = OFF ,
        PROCEDURE_NAME = Sales.ConfirmInvoice, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = OFF ,
        PROCEDURE_NAME = Sales.GetNewInvoice, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO




-- drop

DROP SERVICE [//WWI/SB/TargetService]
GO

DROP SERVICE [//WWI/SB/InitiatorService]
GO

DROP QUEUE [dbo].[TargetQueueWWI]
GO 

DROP QUEUE [dbo].[InitiatorQueueWWI]
GO

DROP CONTRACT [//WWI/SB/Contract]
GO

DROP MESSAGE TYPE [//WWI/SB/RequestMessage]
GO

DROP MESSAGE TYPE [//WWI/SB/ReplyMessage]
GO

DROP PROCEDURE IF EXISTS  Sales.SendNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.GetNewInvoice;

DROP PROCEDURE IF EXISTS  Sales.ConfirmInvoice;


ALTER TABLE Sales.Invoices 
DROP COLUMN InvoiceConfirmedForProcessing;