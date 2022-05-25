USE master
GO
 
Create database Rent4UDB collate Cyrillic_General_CI_AS
GO
 
USE Rent4UDB
GO
 
create table Categories (
         	CategoryID int not null primary key,       	
         	[Type] nvarchar(10) not null,
         	Rent money not null
)
GO
 
create table Vehicles (
         	CarNumber nvarchar(10) not null primary key,
         	Brand nvarchar(15) not null,
         	Model nvarchar(30) not null,
         	CategoryID int not null foreign key references Categories (CategoryID),
         	PricePerKm real not null
)
GO
create table Customers (
     	 	CustomerID int not null primary key,          	 	
     	 	[Name] nvarchar(30) not null,
     	 	[Address] nvarchar(60) not null,
     	 	Company bit not null,
     	 	PhoneNumber nvarchar(10) not null unique
)
GO


 
CREATE TABLE [dbo].[Contracts](
   	[ContractID] [nvarchar](10) NOT NULL,
   	[CustomerID] [int] NOT NULL,
   	[CarNumber] [nvarchar](10) NOT NULL,
   	[HireDate] [date] NOT NULL,
   	[StartMileage] [int] NOT NULL,
   	[Advance] [money] NOT NULL
 CONSTRAINT [PK_Contracts] PRIMARY KEY CLUSTERED ([ContractId] ASC)
)
GO
 
CREATE TABLE Protocols
(
   	ContractID NVARCHAR(10) UNIQUE,
   	ReturnDate DATE NOT NULL,
   	FinishMileage INT NOT NULL,
)
GO


insert into Categories
values (1,N'Лека кола',25),
         	(2,N'Комби',35),
         	(3,N'Микробус',75),
         	(4,N'Лимузина',100)
 
insert into Vehicles
values (N'СА 3456 СХ',N'Мерцедес',N'S - 300 Long',4,0.07),
         	(N'СА 1783 ВА',N'Фолксваген',N'Пасат',2,0.045),
         	(N'В 1222 АВ',N'Форд',N'Мондео',2,0.05),
         	(N'В 9786 ТА',N'Фиат',N'Стило',1,0.035),
         	(N'В 1088 А',N'Фолксваген',N'Голф 4',1,0.0325),
         	(N'СВ 0102 АВ',N'Ауди',N'A8 Quattro',4,0.065),
         	(N'В 0599 СН',N'Рено',N'Меган',2,0.045),
         	(N'В 4501 Н',N'Мерцедес',N'Спринтер',3,0.075),
         	(N'С 2222 РТ',N'Порше',N'Panamera Turbo S',4,0.105),
         	(N'СА 2332 АС',N'Рено',N'Клио',1,0.035),
         	(N'В 3313 С',N'Тойота',N'Ярис',1,0.03)
 
insert into Customers
values (1,N'Сирма ООД',N'София, бул. "Цариградско шосе" № 234, ет. 10',1,'0884202404'),
         	(2,N'Хепи холидейз',N'Тутракан, ул. "Иван Вазов" № 22, ет. 2',1,'0894100200'),
         	(3,N'Трифон Славев',N'Плевен, ул. "Цар Асен" блок 1, етаж 3',0,'0878121314'),
         	(4,N'Ради Руменов',N'Хасково, ул. "Речна" блок 13, вход А, ап. 3',0,'0877654321'),
         	(5,N'Хюве фарма',N'Разград, ул. "Лудогорец" № 21, ет. 13, офис 2',1,'0876543345'),
         	(6,N'Галена Малинова',N'Разград, ул. "Лудогорец" № 10',0,'0899101101'),
         	(7,N'Никола Пенчев',N'Варна, ул. "Поп Ставри" № 31',0,'0874321123'),
         	(8,N'Сторми хилс',N'Габрово, ул. "Рачо ковача" № 1 В',1,'0888001123'),
         	(9,N'Иванка Лилиева',N'Кубрат, ул. "Княз Борис" № 1 Б',0,'0876000111'),
         	(10,N'Панайот Владигеров',N'Добрич, ул. "Петко Стайнов" № 12',0,'0883288880'),
         	(11,N'Дафка Екатериновска',N'Чепеларе, ул. "Васил Левски" № 11',0,'0893203040')
 
SET DATEFORMAT MDY

 
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0001',1, N'СА 3456 СХ', CAST(N'1/13/2021' AS DATE), 17340, 200)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0002',2, N'СА 1783 ВА', CAST(N'1/16/2021' AS DATE), 20108, 250)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0003',3, N'В 1222 АВ', CAST(N'1/24/2021' AS DATE), 55463, 300)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0004',4, N'В 9786 ТА', CAST(N'1/30/2021' AS DATE), 81210, 125)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0005',5, N'В 1088 А', CAST(N'2/1/2021' AS DATE), 30404, 175)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0006',6, N'СА 3456 СХ', CAST(N'3/19/2021' AS DATE), 18230, 500)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0007',6, N'СВ 0102 АВ', CAST(N'3/29/2021' AS DATE), 31456, 600)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0008',8, N'СА 1783 ВА', CAST(N'4/22/2021' AS DATE), 22870, 105)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0009',3, N'В 9786 ТА', CAST(N'4/23/2021' AS DATE), 84560, 100)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0010',5, N'СВ 0102 АВ', CAST(N'4/26/2021' AS DATE), 36789, 250)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0011',8, N'В 0599 СН', CAST(N'4/29/2021' AS DATE), 50133, 70)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0012',2, N'В 1222 АВ', CAST(N'4/30/2021' AS DATE), 57313, 250)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0013',1, N'В 0599 СН', CAST(N'5/24/2021' AS DATE), 52003, 105)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0014',3, N'СА 1783 ВА', CAST(N'5/27/2021' AS DATE), 24000, 210)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0015',7, N'В 4501 Н', CAST(N'6/7/2021' AS DATE), 32000, 400)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0016',4, N'СА 3456 СХ', CAST(N'6/24/2021' AS DATE), 20975, 300)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0017',11, N'С 2222 РТ', CAST(N'7/1/2021' AS DATE), 56789, 700)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0018',3, N'СВ 0102 АВ', CAST(N'7/10/2021' AS DATE), 42007, 800)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0019',3, N'В 0599 СН', CAST(N'8/2/2021' AS DATE), 54011, 175)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0020',5, N'СА 3456 СХ', CAST(N'8/5/2021' AS DATE), 25300, 700)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0021',3, N'СА 1783 ВА', CAST(N'8/18/2021' AS DATE), 26340, 140)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0022',9, N'В 4501 Н', CAST(N'8/20/2021' AS DATE), 34804, 550)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0023',11, N'В 1222 АВ', CAST(N'8/24/2021' AS DATE), 61419, 230)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0024',7, N'СА 1783 ВА', CAST(N'8/29/2021' AS DATE), 27700, 230)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0025',8, N'В 9786 ТА', CAST(N'9/1/2021' AS DATE), 93567, 200)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0026',7, N'В 1088 А', CAST(N'9/13/2021' AS DATE), 32300, 220)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0027',7, N'СА 2332 АС', CAST(N'9/13/2021' AS DATE), 49023, 250)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0028',8, N'В 1222 АВ', CAST(N'9/26/2021' AS DATE), 63877, 215)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0029',2, N'В 1088 А', CAST(N'9/29/2021' AS DATE), 35208, 500)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0030',11, N'В 9786 ТА', CAST(N'9/29/2021' AS DATE), 96245, 80)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0031',6, N'СА 1783 ВА', CAST(N'9/30/2021' AS DATE), 30243, 95)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0032',8, N'В 3313 С', CAST(N'10/6/2021' AS DATE), 21133, 250)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0033',10, N'СА 1783 ВА', CAST(N'10/30/2021' AS DATE), 31500, 270)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0034',6, N'В 4501 Н', CAST(N'11/3/2021' AS DATE), 38053, 700)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0035',2, N'В 1222 АВ', CAST(N'11/13/2021' AS DATE), 65550, 250)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0036',11, N'В 0599 СН', CAST(N'11/17/2021' AS DATE), 57101, 150)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0037',4, N'В 0599 СН', CAST(N'11/25/2021' AS DATE), 59122, 140)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0038',1, N'С 2222 РТ', CAST(N'11/25/2021' AS DATE), 59003, 300)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0039',5, N'В 3313 С', CAST(N'12/3/2021' AS DATE), 23062, 200)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate],  [StartMileage], [Advance]) VALUES (N'Д-0040',9, N'С 2222 РТ', CAST(N'12/31/2021' AS DATE), 62454, 200)
GO



INSERT INTO Protocols
VALUES (N'Д-0001', '2021-01-15', 18050), (N'Д-0002', '2021-01-23', 22430), (N'Д-0003', '2021-02-02', 57234),
(N'Д-0004', '2021-02-04', 83545), (N'Д-0005', '2021-02-08', 32120), (N'Д-0006', '2021-03-24', 20223),
(N'Д-0007', '2021-04-05', 33103), (N'Д-0008', '2021-04-25', 23656), (N'Д-0009', '2021-04-30', 85044),
(N'Д-0010', '2021-04-29', 37505), (N'Д-0011', '2021-05-01', 51056), (N'Д-0012', '2021-05-07', 61033),
(N'Д-0013', '2021-05-27', 53255), (N'Д-0014', '2021-06-02', 26056), (N'Д-0015', '2021-06-12', 34567),
(N'Д-0016', '2021-06-28', 22500), (N'Д-0017', '2021-07-07', 57890), (N'Д-0018', '2021-07-21', 44234),
(N'Д-0019', '2021-08-07', 56200), (N'Д-0020', '2021-08-12', 26123), (N'Д-0021', '2021-08-22', 27504),
(N'Д-0022', '2021-08-27', 37345), (N'Д-0023', '2021-08-31', 63599), (N'Д-0024', '2021-09-05', 29355),
(N'Д-0025', '2021-09-10', 94707), (N'Д-0026', '2021-09-22', 34512), (N'Д-0027', '2021-09-24', 50350),
(N'Д-0028', '2021-10-03', 65274), (N'Д-0029', '2021-10-20', 38233), (N'Д-0030', '2021-10-02', 97000),
(N'Д-0031', '2021-10-03', 31026), (N'Д-0032', '2021-10-16', 22673), (N'Д-0033', '2021-11-06', 33340),
(N'Д-0034', '2021-11-13', 41408), (N'Д-0035', '2021-11-23', 68277), (N'Д-0036', '2021-11-22', 58890),
(N'Д-0037', '2021-11-29', 61335), (N'Д-0038', '2021-11-29', 59827), (N'Д-0039', '2021-12-11', 23994),
(N'Д-0040', '2022-01-02', 62890)
GO
 
ALTER TABLE [dbo].[Contracts] ADD CONSTRAINT [FK_Contracts_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
 
ALTER TABLE [dbo].[Contracts] ADD CONSTRAINT [FK_Contracts_Vehicles] FOREIGN KEY([CarNumber])
REFERENCES [dbo].[Vehicles] ([CarNumber])
GO
 
ALTER TABLE [dbo].[Protocols] ADD CONSTRAINT [FK_Contracts_Protocols] FOREIGN KEY([ContractID])
REFERENCES [dbo].[Contracts] ([ContractID])
GO
