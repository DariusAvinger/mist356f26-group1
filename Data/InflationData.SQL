

if object_id('REPORTFORECAST') is not null drop table REPORTFORECAST;
if object_id('REPORT') is not null drop table REPORT;
if object_id('INFLATIONCALCULATOR') is not null drop table INFLATIONCALCULATOR;
if object_id('BASKETITEM') is not null drop table BASKETITEM;
if object_id('BASKET') is not null drop table BASKET;
if object_id('ITEMPRICE') is not null drop table ITEMPRICE;
if object_id('ITEM') is not null drop table ITEM;
if object_id('APPUSER') is not null drop table APPUSER;

go


create table APPUSER (
    UserID UNIQUEIDENTIFIER NOT NULL default NEWID(),
    Username VARCHAR(50) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    CreationDate DATETIME2 NOT NULL default SYSDATETIME(),
    AppUserPassword VARCHAR(255) NOT NULL,                    
    constraint PK_AppUser Primary Key (UserID),
    constraint UQ_AppUser_Username UNIQUE (Username),
    constraint UQ_AppUser_Email UNIQUE (Email)
);

go


create table ITEM (
    ItemID UNIQUEIDENTIFIER NOT NULL default NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,                     
    UnitOfMeasurement VARCHAR(25) NOT NULL,            
    constraint PK_Item Primary Key (ItemID),
    constraint UQ_Item_UserName UNIQUE (UserID, Name),
    constraint FK_Item_AppUser FOREIGN KEY (UserID) REFERENCES APPUSER(UserID),
    constraint CK_Item_Category CHECK (Category IN ('Food and Beverages', 'Housing', 'Apparel',
        'Transportation', 'Medical Care', 'Recreation', 'Education and Communication',
        'Other Goods and Services'))
);

go

create table ITEMPRICE (
    ItemID UNIQUEIDENTIFIER NOT NULL,
    PriceDate DATE NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    constraint PK_ItemPrice Primary Key (ItemID, PriceDate),
    constraint FK_ItemPrice_Item FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    constraint CK_ItemPrice_Price CHECK (Price >= 0)
);

go

create table BASKET (
    BasketID UNIQUEIDENTIFIER NOT NULL default NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL,
    Name VARCHAR(100) NOT NULL,
    BasketTotal DECIMAL(10,2) NOT NULL default 0,
    constraint PK_Basket Primary Key (BasketID),
    constraint UQ_Basket_UserName UNIQUE (UserID, Name),
    constraint FK_Basket_AppUser FOREIGN KEY (UserID) REFERENCES APPUSER(UserID)
);

go

create table BASKETITEM (
    BasketID UNIQUEIDENTIFIER NOT NULL,
    ItemID UNIQUEIDENTIFIER NOT NULL,
    Quantity DECIMAL(10,2) NOT NULL default 1,         -- how many units of the item are in the basket
    constraint PK_BasketItem Primary Key (BasketID, ItemID),
    constraint FK_BasketItem_Basket FOREIGN KEY (BasketID) REFERENCES BASKET(BasketID),
    constraint FK_BasketItem_Item FOREIGN KEY (ItemID) REFERENCES ITEM(ItemID),
    constraint CK_BasketItem_Quantity CHECK (Quantity > 0)
);

go

create table INFLATIONCALCULATOR (
    InflationCalculatorID UNIQUEIDENTIFIER NOT NULL default NEWID(),
    BasketID UNIQUEIDENTIFIER NOT NULL,
    BaseDate DATE NOT NULL,
    constraint PK_InflationCalculator Primary Key (InflationCalculatorID),
    constraint UQ_InflationCalculator_BasketDate UNIQUE (BasketID, BaseDate),
    constraint FK_InflationCalculator_Basket FOREIGN KEY (BasketID) REFERENCES BASKET(BasketID)
);

go


create table REPORT (
    ReportID UNIQUEIDENTIFIER NOT NULL default NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL,
    InflationCalculatorID UNIQUEIDENTIFIER NOT NULL,
    BasketID UNIQUEIDENTIFIER NOT NULL,
    GeneratedDate DATETIME2 NOT NULL default SYSDATETIME(),
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    ObservedInflation FLOAT NOT NULL default 0,        
    OfficialInflation FLOAT NOT NULL default 0,
    Difference FLOAT NOT NULL default 0,               
    ForecastConfidence FLOAT NOT NULL default 0,
    constraint PK_Report Primary Key (ReportID),
    constraint FK_Report_AppUser FOREIGN KEY (UserID) REFERENCES APPUSER(UserID),
    constraint FK_Report_InflationCalculator FOREIGN KEY (InflationCalculatorID) REFERENCES INFLATIONCALCULATOR(InflationCalculatorID),
    constraint FK_Report_Basket FOREIGN KEY (BasketID) REFERENCES BASKET(BasketID),
    constraint CK_Report_Dates CHECK (EndDate > StartDate)
);

go


create table REPORTFORECAST (
    ReportID UNIQUEIDENTIFIER NOT NULL,
    ForecastDate DATE NOT NULL,
    ForecastValue DECIMAL(10,2) NOT NULL default 0,
    constraint PK_ReportForecast Primary Key (ReportID, ForecastDate),
    constraint FK_ReportForecast_Report FOREIGN KEY (ReportID) REFERENCES REPORT(ReportID)
);

go