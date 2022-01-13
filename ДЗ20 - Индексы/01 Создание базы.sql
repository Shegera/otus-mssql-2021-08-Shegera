
USE master
GO
IF DB_ID(N'MyCompany') IS NOT NULL
	DROP DATABASE MyCompany;
GO

CREATE DATABASE [MyCompany] 
CONTAINMENT = NONE
ON PRIMARY
(
	NAME = MyCompany,
	FILENAME = 'C:\DB_MyCompany\MyCompany.mdf',
	SIZE = 100MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH  = 100MB
)
LOG ON
(
	NAME = MyCompany_log, 
	FILENAME = 'C:\DB_MyCompany\MyCompany_log.ldf',
	SIZE = 100MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH  = 100MB
)
GO



-- Создание таблиц

USE [MyCompany] 
CREATE TABLE [States] (
	StateID	BIGINT NOT NULL IDENTITY(1,1), 
	CONSTRAINT PK_States_StateID  PRIMARY KEY CLUSTERED (StateID),
	StateName NVARCHAR (300) NOT NULL,
	Inactive BIT NOT NULL DEFAULT 0
)
-- Создание базовых статусов для всех процессов и справочников
INSERT INTO States (StateName, Inactive) VALUES
('Черновик',0),
('Удалено',1)

CREATE TABLE [ObjectRoutes] (
	RouteID	BIGINT NOT NULL IDENTITY(1,1), 
	CONSTRAINT PK_ObjectRoutes_RouteID  PRIMARY KEY CLUSTERED (RouteID),
	RouteName NVARCHAR (300) NOT NULL
)

CREATE TABLE [Steps] (
	StepID BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Steps_StepID  PRIMARY KEY CLUSTERED (StepID),
	RouteID BIGINT NOT NULL CONSTRAINT FK_Steps_RouteID FOREIGN KEY (RouteID) REFERENCES ObjectRoutes (RouteID),
	StepName NVARCHAR (300) NOT NULL,
	FromStateID BIGINT NOT NULL CONSTRAINT FK_Steps_FromStateID FOREIGN KEY (FromStateID) REFERENCES States (StateID),
	ToStateID BIGINT NOT NULL CONSTRAINT FK_Steps_ToStateID FOREIGN KEY (ToStateID) REFERENCES States (StateID)
)

CREATE TABLE [Employees] (
	EmployeeID BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Employees_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID),
	Inactive BIT NOT NULL DEFAULT 0,
	CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	StateID BIGINT NOT NULL CONSTRAINT FK_Employees_StateID FOREIGN KEY (StateID) REFERENCES States (StateID) DEFAULT 1,
	Nick NVARCHAR (50) NOT NULL CONSTRAINT Idx_Emplyees_Nick UNIQUE,
	FirstName NVARCHAR(50) NULL,
	SurName NVARCHAR(50) NULL,
	SecondName NVARCHAR(50) NULL,
	FullName NVARCHAR(150) NULL,
	BirthDate DATE NULL CONSTRAINT Constr_Employees_BirthDate CHECK (BirthDate < GETDATE())
)
CREATE NONCLUSTERED INDEX IX_Employees_EmployeeID_FullName ON [Employees] (EmployeeID, FullName)
INSERT INTO Employees (Nick, FirstName, FullName) VALUES ('SystemRobot', 'SystemRobot', 'SystemRobot')
INSERT INTO Employees (Nick, FirstName, FullName) VALUES ('Admin', 'Admin', 'Admin')


CREATE TABLE [Organisations] (
	OrganisationID BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Organisations_OrganisationID PRIMARY KEY CLUSTERED (OrganisationID),
	Inactive BIT NOT NULL DEFAULT 0,
	CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	StateID BIGINT NOT NULL CONSTRAINT FK_Organosations_StateID FOREIGN KEY (StateID) REFERENCES States (StateID) DEFAULT 1,
	OrganisationName NVARCHAR (300) NOT NULL,
	OrganisationFullName NVARCHAR (300) NOT NULL,
	INN NVARCHAR (20) NULL,
	KPP NVARCHAR (20) NULL
)
CREATE NONCLUSTERED INDEX IX_Organisations_OrganisationID_OrganisationName ON [Organisations] (OrganisationID, OrganisationName)
CREATE NONCLUSTERED INDEX IX_Organisations_INN ON [Organisations] (INN) INCLUDE (OrganisationName)

CREATE TABLE [Partners] (
	PartnerID BIGINT NOT NULL IDENTITY (1,1) CONSTRAINT PK_Partners_PartnerID PRIMARY KEY CLUSTERED (PartnerID),
	Inactive BIT NOT NULL DEFAULT 0,
	CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	StateID BIGINT NOT NULL CONSTRAINT FK_Partners_StateID FOREIGN KEY (StateID) REFERENCES States (StateID) DEFAULT 1,
	PartnerName NVARCHAR (300) NOT NULL,
	PartnerFullName NVARCHAR (300) NOT NULL,
	INN NVARCHAR (20) NULL,
	KPP NVARCHAR (20) NULL
)
CREATE NONCLUSTERED INDEX IX_Partners_OrganisationID_OrganisationName ON [Partners] (PartnerID, PartnerName)
CREATE NONCLUSTERED INDEX IX_Partners_INN ON [Partners] (INN) INCLUDE (PartnerName)

CREATE TABLE [ContractTypes] (
	ContractTypeID BIGINT NOT NULL IDENTITY (1,1) CONSTRAINT PK_ContractType_ContractTypeID PRIMARY KEY CLUSTERED (ContractTypeID),
	ContractType NVARCHAR (100) NOT NULL
)
INSERT INTO ContractTypes (ContractType) VALUES 
('Типовой'),
('Не типовой')

CREATE TABLE [Contracts] (
	ContractID BIGINT NOT NULL IDENTITY (1,1) CONSTRAINT PK_Contracts_ContractID PRIMARY KEY CLUSTERED (ContractID),
	Inactive BIT NOT NULL DEFAULT 0,
	CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	StateID BIGINT NOT NULL CONSTRAINT FK_Contracts_StateID FOREIGN KEY (StateID) REFERENCES States (StateID) DEFAULT 1,
	ContractTypeID BIGINT NOT NULL CONSTRAINT FK_Contracts_ContractTypeID FOREIGN KEY (ContractTypeID) REFERENCES ContractTypes (ContractTypeID),
	ContractNumber NVARCHAR (20) NOT NULL,
	ContractDate DATE NULL,
	Summary NVARCHAR (MAX) NOT NULL,
	ContractStartDate DATE NULL,
	ContractEndDate DATE NULL,
	Indefinite BIT NOT NULL DEFAULT 0,
	OrganisationID BIGINT NOT NULL CONSTRAINT FK_Contracts_OrganisationID FOREIGN KEY (OrganisationID) REFERENCES Organisations (OrganisationID),
	PartnerID BIGINT NOT NULL CONSTRAINT FK_Contracts_PartnerID FOREIGN KEY (PartnerID) REFERENCES Partners (PartnerID)
)
CREATE NONCLUSTERED INDEX IDX_Contracts_ContractNumber ON [dbo].[Contracts] (ContractNumber ASC)
CREATE NONCLUSTERED INDEX IDX_Contracts_CreatedDate ON [dbo].[Contracts] (CreatedDate DESC)
CREATE NONCLUSTERED INDEX IDX_Contracts_PartnerID ON [dbo].[Contracts] (PartnerID ASC)

CREATE TABLE [Items](
	ItemID BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Items_ItemID PRIMARY KEY CLUSTERED (ItemID),
	Inactive BIT NOT NULL DEFAULT 0,
	CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	StateID BIGINT NOT NULL CONSTRAINT FK_Items_StateID FOREIGN KEY (StateID) REFERENCES States (StateID) DEFAULT 1,
	OrganisationID BIGINT NOT NULL CONSTRAINT FK_Items_OrganisationID FOREIGN KEY (OrganisationID) REFERENCES Organisations (OrganisationID),
	ItemName NVARCHAR (300) NOT NULL,
	UnitPrice DECIMAL (12,2) NOT NULL,
	StartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
	EndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (StartTime, EndTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ItemsHistory));
CREATE NONCLUSTERED INDEX IDX_Items_ItemName ON [dbo].[Items] (ItemName ASC) INCLUDE (UnitPrice);



CREATE TABLE [Orders] (
	OrderID BIGINT NOT NULL IDENTITY(1,1) CONSTRAINT PK_Orders_OrderID PRIMARY KEY CLUSTERED (OrderID),
	Inactive BIT NOT NULL DEFAULT 0,
	CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	StateID BIGINT NOT NULL CONSTRAINT FK_Orders_StateID FOREIGN KEY (StateID) REFERENCES States (StateID) DEFAULT 1,
	OrderNumber NVARCHAR (100) NOT NULL,
	OrderDate DATE NOT NULL,
	ContractID BIGINT NOT NULL CONSTRAINT FK_Orders_ContractID FOREIGN KEY (ContractID) REFERENCES Contracts (ContractID),
	ManagerID BIGINT NOT NULL CONSTRAINT FK_Orders_EmployeeID FOREIGN KEY (ManagerID) REFERENCES Employees (EmployeeID)
)
CREATE NONCLUSTERED INDEX IDX_Orders_OrderNumber_OrderDate ON [dbo].[Orders] (OrderNumber DESC, OrderDate DESC);
CREATE NONCLUSTERED INDEX IDX_Orders_OrderDate_OrderNumber ON [dbo].[Orders] (OrderDate DESC, OrderNumber DESC);
CREATE NONCLUSTERED INDEX IDX_Orders_OrderID_ManagerID ON [dbo].[Orders] (OrderID DESC, ManagerID ASC);

CREATE TABLE [OrderItems] (
	OrderItemID BIGINT NOT NULL IDENTITY (1,1) CONSTRAINT PK_OrderItems_OrderItemID PRIMARY KEY CLUSTERED (OrderItemID),
	Inactive BIT NOT NULL DEFAULT 0,
	CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
	StateID BIGINT NOT NULL CONSTRAINT FK_OrderItems_StateID FOREIGN KEY (StateID) REFERENCES States (StateID) DEFAULT 1,
	OrderID BIGINT NOT NULL CONSTRAINT FK_OrderItems_OrderID FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
	ItemID BIGINT NOT NULL CONSTRAINT FK_OrderItems_ItemID FOREIGN KEY (ItemID) REFERENCES Items (ItemID),
	Price DECIMAL (18,2) DEFAULT 0 CONSTRAINT Constr_Price CHECK (Price >= 0),	 
	Quantity DECIMAL (10,4) DEFAULT 0 CONSTRAINT Constr_Quantity CHECK (Quantity >= 0)
)
CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID_ItemID ON [dbo].[OrderItems] (OrderID DESC, ItemID DESC) INCLUDE (Price, Quantity);
CREATE NONCLUSTERED INDEX IDX_OrderItems_CreatedDate_OrderItemID ON [dbo].[OrderItems] (CreatedDate DESC, OrderItemID DESC);

USE master