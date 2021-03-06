USE [master]
GO
/****** Object:  Database [Copy_Rent4UDB]    Script Date: 05.05.2022 г. 09:16:16 ******/
CREATE DATABASE [Copy_Rent4UDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Copy_Rent4UDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Copy_Rent4UDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Copy_Rent4UDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Copy_Rent4UDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Copy_Rent4UDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Copy_Rent4UDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Copy_Rent4UDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Copy_Rent4UDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Copy_Rent4UDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Copy_Rent4UDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Copy_Rent4UDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Copy_Rent4UDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Copy_Rent4UDB] SET  MULTI_USER 
GO
ALTER DATABASE [Copy_Rent4UDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Copy_Rent4UDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Copy_Rent4UDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Copy_Rent4UDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Copy_Rent4UDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Copy_Rent4UDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [Copy_Rent4UDB] SET QUERY_STORE = OFF
GO
USE [Copy_Rent4UDB]
GO
/****** Object:  UserDefinedFunction [dbo].[CountRents]    Script Date: 05.05.2022 г. 09:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[CountRents] (@StartDate date, @FinishDate date, @CarNumber nvarchar(10))
returns int 
as
begin
   	declare @count int
   	select @count = count(*)
                              	from Contracts
                              	where HireDate between @StartDate and @FinishDate
                                    	and CarNumber = @CarNumber
   	return @count
end
GO
/****** Object:  UserDefinedFunction [dbo].[DetectMileage]    Script Date: 05.05.2022 г. 09:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   function [dbo].[DetectMileage](@date date)
returns @final table
         	(
                	ID int identity(1,1),
                	CarNumber nvarchar(10),
                	DetectedMileage int default 0
         	)
as
begin
   	
 
   	insert into @final (CarNumber)
   	select distinct CarNumber from Contracts
 
   	declare @index int = 1
   	declare @count int
   	select @count = count(*) from @final
 
   	declare @sum int = 0
 
   	while(@index<=@count)
   	begin
                	declare @table table
         	(
                	CarNumber nvarchar(10),
                	HireDate date,
                	StartMileage int,
                	ReturnDate date,
                	FinishMileage int
         	)
 
         	declare @subs table
         	(
                	CarNumber nvarchar(10),
                	Mileage int
         	)
 
         	insert into @table
         	select CarNumber, HireDate, StartMileage, ReturnDate, FinishMileage
         	from Contracts as c inner join Protocols as p on c.ContractId=p.ContractID
         	where CarNumber = (select CarNumber from @final where ID = @index)
 
         	insert into @subs
         	select CarNumber, isnull(FinishMileage - StartMileage, 0)
         	from @table
         	where @date > ReturnDate
 
 
         	update @final
         	set DetectedMileage = isnull((select sum(Mileage) from @subs),0)
         	where CarNumber = (select CarNumber from @final where ID = @index)
 
         	set @index += 1
         	delete  @table 
         	delete  @subs
end
   	return
   	
end
GO
/****** Object:  UserDefinedFunction [dbo].[udf_GetRemainingPayment]    Script Date: 05.05.2022 г. 09:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[udf_GetRemainingPayment]()
   	RETURNS @tblRemainingPayment TABLE
   	(
         	ContractID NVARCHAR(10),
         	Advance MONEY,
         	RemainingPayment MONEY
   	)
   	AS BEGIN
         	INSERT INTO @tblRemainingPayment
         	(
                	ContractID, Advance, RemainingPayment
         	)
         	SELECT ContractID, Advance, ROUND((DATEDIFF(DAY, (SELECT HireDate FROM Contracts S WHERE S.ContractID = C.ContractID),
                       	(SELECT ReturnDate FROM Protocols WHERE ContractID = C.ContractID))
                	* (SELECT Rent FROM Categories WHERE CategoryID = (SELECT CategoryID FROM Vehicles WHERE CarNumber = C.CarNumber))
                	+ ((SELECT FinishMileage FROM Protocols WHERE ContractID = C.ContractID) - (SELECT StartMileage FROM Contracts
                       	WHERE ContractID = C.ContractID))
                	* IIF((SELECT Company FROM Customers WHERE CustomerID =
                       	C.CustomerID) = 1, (SELECT PricePerKm FROM Vehicles WHERE CarNumber = C.CarNumber), (SELECT PricePerKm FROM Vehicles
                       	WHERE CarNumber = C.CarNumber) * (100 - 10)/100)
                	- Advance), 2) AS [RemainingPayment]
         	FROM Contracts C
   	RETURN
END;
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 05.05.2022 г. 09:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] NOT NULL,
	[Type] [nvarchar](10) NOT NULL,
	[Rent] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Contracts]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contracts](
	[ContractID] [nvarchar](10) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[CarNumber] [nvarchar](10) NOT NULL,
	[HireDate] [date] NOT NULL,
	[StartMileage] [int] NOT NULL,
	[Advance] [money] NOT NULL,
 CONSTRAINT [PK_Contracts] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	[Address] [nvarchar](60) NOT NULL,
	[Company] [bit] NOT NULL,
	[PhoneNumber] [nvarchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Protocols]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Protocols](
	[ContractID] [nvarchar](10) NULL,
	[ReturnDate] [date] NOT NULL,
	[FinishMileage] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vehicles]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicles](
	[CarNumber] [nvarchar](10) NOT NULL,
	[Brand] [nvarchar](15) NOT NULL,
	[Model] [nvarchar](30) NOT NULL,
	[CategoryID] [int] NOT NULL,
	[PricePerKm] [real] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CarNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Categories] ([CategoryID], [Type], [Rent]) VALUES (1, N'Лека кола', 25.0000)
INSERT [dbo].[Categories] ([CategoryID], [Type], [Rent]) VALUES (2, N'Комби', 35.0000)
INSERT [dbo].[Categories] ([CategoryID], [Type], [Rent]) VALUES (3, N'Микробус', 75.0000)
INSERT [dbo].[Categories] ([CategoryID], [Type], [Rent]) VALUES (4, N'Лимузина', 100.0000)
GO
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0001', 1, N'СА 3456 СХ', CAST(N'2021-01-13' AS Date), 17340, 200.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0002', 2, N'СА 1783 ВА', CAST(N'2021-01-16' AS Date), 20108, 250.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0003', 3, N'В 1222 АВ', CAST(N'2021-01-24' AS Date), 55463, 300.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0004', 4, N'В 9786 ТА', CAST(N'2021-01-30' AS Date), 81210, 125.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0005', 5, N'В 1088 А', CAST(N'2021-02-01' AS Date), 30404, 175.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0006', 6, N'СА 3456 СХ', CAST(N'2021-03-19' AS Date), 18230, 500.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0007', 6, N'СВ 0102 АВ', CAST(N'2021-03-29' AS Date), 31456, 600.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0008', 8, N'СА 1783 ВА', CAST(N'2021-04-22' AS Date), 22870, 105.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0009', 3, N'В 9786 ТА', CAST(N'2021-04-23' AS Date), 84560, 100.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0010', 5, N'СВ 0102 АВ', CAST(N'2021-04-26' AS Date), 36789, 250.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0011', 8, N'В 0599 СН', CAST(N'2021-04-29' AS Date), 50133, 70.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0012', 2, N'В 1222 АВ', CAST(N'2021-04-30' AS Date), 57313, 250.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0013', 1, N'В 0599 СН', CAST(N'2021-05-24' AS Date), 52003, 105.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0014', 3, N'СА 1783 ВА', CAST(N'2021-05-27' AS Date), 24000, 210.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0015', 7, N'В 4501 Н', CAST(N'2021-06-07' AS Date), 32000, 400.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0016', 4, N'СА 3456 СХ', CAST(N'2021-06-24' AS Date), 20975, 300.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0017', 11, N'С 2222 РТ', CAST(N'2021-07-01' AS Date), 56789, 700.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0018', 3, N'СВ 0102 АВ', CAST(N'2021-07-10' AS Date), 42007, 800.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0019', 3, N'В 0599 СН', CAST(N'2021-08-02' AS Date), 54011, 175.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0020', 5, N'СА 3456 СХ', CAST(N'2021-08-05' AS Date), 25300, 700.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0021', 3, N'СА 1783 ВА', CAST(N'2021-08-18' AS Date), 26340, 140.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0022', 9, N'В 4501 Н', CAST(N'2021-08-20' AS Date), 34804, 550.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0023', 11, N'В 1222 АВ', CAST(N'2021-08-24' AS Date), 61419, 230.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0024', 7, N'СА 1783 ВА', CAST(N'2021-08-29' AS Date), 27700, 230.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0025', 8, N'В 9786 ТА', CAST(N'2021-09-01' AS Date), 93567, 200.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0026', 7, N'В 1088 А', CAST(N'2021-09-13' AS Date), 32300, 220.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0027', 7, N'СА 2332 АС', CAST(N'2021-09-13' AS Date), 49023, 250.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0028', 8, N'В 1222 АВ', CAST(N'2021-09-26' AS Date), 63877, 215.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0029', 2, N'В 1088 А', CAST(N'2021-09-29' AS Date), 35208, 500.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0030', 11, N'В 9786 ТА', CAST(N'2021-09-29' AS Date), 96245, 80.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0031', 6, N'СА 1783 ВА', CAST(N'2021-09-30' AS Date), 30243, 95.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0032', 8, N'В 3313 С', CAST(N'2021-10-06' AS Date), 21133, 250.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0033', 10, N'СА 1783 ВА', CAST(N'2021-10-30' AS Date), 31500, 270.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0034', 6, N'В 4501 Н', CAST(N'2021-11-03' AS Date), 38053, 700.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0035', 2, N'В 1222 АВ', CAST(N'2021-11-13' AS Date), 65550, 250.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0036', 11, N'В 0599 СН', CAST(N'2021-11-17' AS Date), 57101, 150.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0037', 4, N'В 0599 СН', CAST(N'2021-11-25' AS Date), 59122, 140.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0038', 1, N'С 2222 РТ', CAST(N'2021-11-25' AS Date), 59003, 300.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0039', 5, N'В 3313 С', CAST(N'2021-12-03' AS Date), 23062, 200.0000)
INSERT [dbo].[Contracts] ([ContractID], [CustomerID], [CarNumber], [HireDate], [StartMileage], [Advance]) VALUES (N'Д-0040', 9, N'С 2222 РТ', CAST(N'2021-12-31' AS Date), 62454, 200.0000)
GO
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (1, N'Сирма ООД', N'София, бул. "Цариградско шосе" № 234, ет. 10', 1, N'0884202404')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (2, N'Хепи холидейз', N'Тутракан, ул. "Иван Вазов" № 22, ет. 2', 1, N'0894100200')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (3, N'Трифон Славев', N'Плевен, ул. "Цар Асен" блок 1, етаж 3', 0, N'0878121314')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (4, N'Ради Руменов', N'Хасково, ул. "Речна" блок 13, вход А, ап. 3', 0, N'0877654321')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (5, N'Хюве фарма', N'Разград, ул. "Лудогорец" № 21, ет. 13, офис 2', 1, N'0876543345')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (6, N'Галена Малинова', N'Разград, ул. "Лудогорец" № 10', 0, N'0899101101')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (7, N'Никола Пенчев', N'Варна, ул. "Поп Ставри" № 31', 0, N'0874321123')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (8, N'Сторми хилс', N'Габрово, ул. "Рачо ковача" № 1 В', 1, N'0888001123')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (9, N'Иванка Лилиева', N'Кубрат, ул. "Княз Борис" № 1 Б', 0, N'0876000111')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (10, N'Панайот Владигеров', N'Добрич, ул. "Петко Стайнов" № 12', 0, N'0883288880')
INSERT [dbo].[Customers] ([CustomerID], [Name], [Address], [Company], [PhoneNumber]) VALUES (11, N'Дафка Екатериновска', N'Чепеларе, ул. "Васил Левски" № 11', 0, N'0893203040')
GO
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0001', CAST(N'2021-01-15' AS Date), 18050)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0002', CAST(N'2021-01-23' AS Date), 22430)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0003', CAST(N'2021-02-02' AS Date), 57234)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0004', CAST(N'2021-02-04' AS Date), 83545)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0005', CAST(N'2021-02-08' AS Date), 32120)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0006', CAST(N'2021-03-24' AS Date), 20223)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0007', CAST(N'2021-04-05' AS Date), 33103)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0008', CAST(N'2021-04-25' AS Date), 23656)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0009', CAST(N'2021-04-30' AS Date), 85044)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0010', CAST(N'2021-04-29' AS Date), 37505)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0011', CAST(N'2021-05-01' AS Date), 51056)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0012', CAST(N'2021-05-07' AS Date), 61033)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0013', CAST(N'2021-05-27' AS Date), 53255)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0014', CAST(N'2021-06-02' AS Date), 26056)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0015', CAST(N'2021-06-12' AS Date), 34567)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0016', CAST(N'2021-06-28' AS Date), 22500)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0017', CAST(N'2021-07-07' AS Date), 57890)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0018', CAST(N'2021-07-21' AS Date), 44234)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0019', CAST(N'2021-08-07' AS Date), 56200)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0020', CAST(N'2021-08-12' AS Date), 26123)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0021', CAST(N'2021-08-22' AS Date), 27504)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0022', CAST(N'2021-08-27' AS Date), 37345)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0023', CAST(N'2021-08-31' AS Date), 63599)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0024', CAST(N'2021-09-05' AS Date), 29355)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0025', CAST(N'2021-09-10' AS Date), 94707)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0026', CAST(N'2021-09-22' AS Date), 34512)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0027', CAST(N'2021-09-24' AS Date), 50350)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0028', CAST(N'2021-10-03' AS Date), 65274)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0029', CAST(N'2021-10-20' AS Date), 38233)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0030', CAST(N'2021-10-02' AS Date), 97000)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0031', CAST(N'2021-10-03' AS Date), 31026)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0032', CAST(N'2021-10-16' AS Date), 22673)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0033', CAST(N'2021-11-06' AS Date), 33340)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0034', CAST(N'2021-11-13' AS Date), 41408)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0035', CAST(N'2021-11-23' AS Date), 68277)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0036', CAST(N'2021-11-22' AS Date), 58890)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0037', CAST(N'2021-11-29' AS Date), 61335)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0038', CAST(N'2021-11-29' AS Date), 59827)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0039', CAST(N'2021-12-11' AS Date), 23994)
INSERT [dbo].[Protocols] ([ContractID], [ReturnDate], [FinishMileage]) VALUES (N'Д-0040', CAST(N'2022-01-02' AS Date), 62890)
GO
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'В 0599 СН', N'Рено', N'Меган', 2, 0.045)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'В 1088 А', N'Фолксваген', N'Голф 4', 1, 0.0325)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'В 1222 АВ', N'Форд', N'Мондео', 2, 0.05)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'В 3313 С', N'Тойота', N'Ярис', 1, 0.03)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'В 4501 Н', N'Мерцедес', N'Спринтер', 3, 0.075)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'В 9786 ТА', N'Фиат', N'Стило', 1, 0.035)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'С 2222 РТ', N'Порше', N'Panamera Turbo S', 4, 0.105)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'СА 1783 ВА', N'Фолксваген', N'Пасат', 2, 0.045)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'СА 2332 АС', N'Рено', N'Клио', 1, 0.035)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'СА 3456 СХ', N'Мерцедес', N'S - 300 Long', 4, 0.07)
INSERT [dbo].[Vehicles] ([CarNumber], [Brand], [Model], [CategoryID], [PricePerKm]) VALUES (N'СВ 0102 АВ', N'Ауди', N'A8 Quattro', 4, 0.065)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Customer__85FB4E3803D7C903]    Script Date: 05.05.2022 г. 09:16:17 ******/
ALTER TABLE [dbo].[Customers] ADD UNIQUE NONCLUSTERED 
(
	[PhoneNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Protocol__C90D340870A49D55]    Script Date: 05.05.2022 г. 09:16:17 ******/
ALTER TABLE [dbo].[Protocols] ADD UNIQUE NONCLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Customers]
GO
ALTER TABLE [dbo].[Contracts]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Vehicles] FOREIGN KEY([CarNumber])
REFERENCES [dbo].[Vehicles] ([CarNumber])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Contracts] CHECK CONSTRAINT [FK_Contracts_Vehicles]
GO
ALTER TABLE [dbo].[Protocols]  WITH CHECK ADD  CONSTRAINT [FK_Contracts_Protocols] FOREIGN KEY([ContractID])
REFERENCES [dbo].[Contracts] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Protocols] CHECK CONSTRAINT [FK_Contracts_Protocols]
GO
ALTER TABLE [dbo].[Vehicles]  WITH CHECK ADD FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
ON DELETE CASCADE
GO
/****** Object:  StoredProcedure [dbo].[DetectMileageOnAPeriod]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   procedure [dbo].[DetectMileageOnAPeriod](@StartDate date, @FinishDate date)
as
begin
   	declare @table table
   	(
         	CarNumber nvarchar(10),
         	Mileage int
   	)
 
   	declare @first table
   	(
         	CarNumber nvarchar(10),
         	StartM int
   	)
   	insert into @first
   	select CarNumber, DetectedMileage from dbo.DetectMileage(@StartDate)
 
   	declare @second table
   	(
         	CarNumber nvarchar(10),
         	FinishM int
   	)
   	insert into @second
   	select CarNumber, DetectedMileage from dbo.DetectMileage(@FinishDate)
 
   	insert into @table (CarNumber, Mileage)
   	select s.CarNumber, FinishM- StartM 
   	from @first as f
   	inner join @second as s
   	on f.CarNumber = s.CarNumber
 
 
   	select * from @table
end
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteCategories]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_DeleteCategories] @id INT
AS
BEGIN
   	IF EXISTS (SELECT * FROM Categories WHERE CategoryID = @id)
   	begin
		set nocount on
          	delete from Categories
          	where CategoryID = @id
		print 'Въведените данни бяха успешно изтрити!'

   	end
   	ELSE BEGIN
          	PRINT('Въведените данни са неправилни! Категория с такъв идентификационен код не съществува!')
   	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteContracts]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_DeleteContracts] @id NVARCHAR(10)
AS
BEGIN
   	IF EXISTS (SELECT * FROM Contracts WHERE ContractID = @id)
   	begin
		set nocount on
          	delete from Contracts
          	where ContractID = @id
		print 'Въведените данни бяха успешно изтрити!'
   	end
   	ELSE BEGIN
          	PRINT('Въведените данни са неправилни! Договор с такъв идентификационен код не съществува!')
   	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteCustomers]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_DeleteCustomers] @customerID int
AS
BEGIN
   	IF EXISTS (SELECT * FROM Customers WHERE CustomerID = @customerID)
   	begin
		set nocount on
          	delete from Customers
          	where CustomerID = @customerID
		print 'Въведените данни бяха успешно изтрити!'
   	end
   	ELSE BEGIN
          	PRINT('Въведените данни са неправилни! Клиент с такъв идентификационен код не съществува!')
   	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteProtocols]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_DeleteProtocols] @id NVARCHAR(10)
AS
BEGIN
   	IF EXISTS (SELECT * FROM Protocols WHERE ContractID = @id)
   	begin
		set nocount on
          	delete from Protocols
          	where ContractID = @id
		print 'Въведените данни бяха успешно изтрити!'
   	end
   	ELSE BEGIN
          	PRINT('Въведените данни са неправилни! Договор с такъв идентификационен код не съществува!')
   	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteVehicles]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_DeleteVehicles] @carNum nvarchar(10)
AS
BEGIN
   	IF EXISTS (SELECT * FROM Vehicles WHERE CarNumber = @carNum)
   	begin
		set nocount on
          	delete from Vehicles
          	where @carNum = @carNum
		print 'Въведените данни бяха успешно изтрити!'
   	end
   	ELSE BEGIN
          	PRINT('Въведените данни са неправилни! Превозно средство с такъв идентификационен код не съществува!')
   	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_FindIncomeByCarNumber]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_FindIncomeByCarNumber]
   	@carNum nvarchar(10) = null
as begin
   	if exists(select * from Vehicles where CarNumber = @carNum)
   	begin
         	select V.CarNumber,
                	Round(Sum(abs(datediff(DD,P.ReturnDate,Cn.HireDate)) * Ct.Rent +
                	(P.FinishMileage - Cn.StartMileage) * V.PricePerKm * IIF(Cs.Company=1,1,0.9)), 2) as [Income]
         	from Vehicles V
         	inner join Categories Ct
         	on Ct.CategoryID = V.CategoryID
         	inner join Contracts Cn
         	on Cn.CarNumber = V.CarNumber
         	inner join Protocols P
         	on Cn.ContractID = P.ContractID
         	inner join Customers Cs
         	on Cs.CustomerID = Cn.CustomerID
         	where V.CarNumber = @carNum
         	group by V.CarNumber
         	order by [Income] desc
   	end
   	else begin
         	select V.CarNumber,
                	Round(Sum(abs(datediff(DD,P.ReturnDate,Cn.HireDate)) * Ct.Rent +
                	(P.FinishMileage - Cn.StartMileage) * V.PricePerKm * IIF(Cs.Company=1,1,0.9)), 2) as [Income]
         	from Vehicles V
         	inner join Categories Ct
         	on Ct.CategoryID = V.CategoryID
         	inner join Contracts Cn
         	on Cn.CarNumber = V.CarNumber
         	inner join Protocols P
         	on Cn.ContractID = P.ContractID
         	inner join Customers Cs
         	on Cs.CustomerID = Cn.CustomerID
         	group by V.CarNumber
         	order by [Income] desc
   	end
end
 
GO
/****** Object:  StoredProcedure [dbo].[usp_FindIncomeByCategory]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_FindIncomeByCategory]
as begin
         	select Ct.Type,
                	Round(Sum(abs(datediff(DD,P.ReturnDate,Cn.HireDate)) * Ct.Rent +
                	(P.FinishMileage - Cn.StartMileage) * V.PricePerKm * IIF(Cs.Company=1,1,0.9)), 2) as [Income]
         	from Vehicles V
         	inner join Categories Ct
         	on Ct.CategoryID = V.CategoryID
         	inner join Contracts Cn
         	on Cn.CarNumber = V.CarNumber
         	inner join Protocols P
         	on Cn.ContractID = P.ContractID
         	inner join Customers Cs
         	on Cs.CustomerID = Cn.CustomerID
         	group by Ct.Type
         	order by [Income] desc
end
GO
/****** Object:  StoredProcedure [dbo].[usp_FindIncomeByCustomerName]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_FindIncomeByCustomerName]
   	@custName nvarchar(30) = null
as begin
   	if exists(select * from Customers where Name like '%'+@custName+'%')
   	begin
         	select Cs.Name,
                	Round(Sum(abs(datediff(DD,P.ReturnDate,Cn.HireDate)) * Ct.Rent +
                	(P.FinishMileage - Cn.StartMileage) * V.PricePerKm * IIF(Cs.Company=1,1,0.9)), 2) as [Income]
         	from Vehicles V
         	inner join Categories Ct
         	on Ct.CategoryID = V.CategoryID
         	inner join Contracts Cn
         	on Cn.CarNumber = V.CarNumber
         	inner join Protocols P
         	on Cn.ContractID = P.ContractID
         	inner join Customers Cs
         	on Cs.CustomerID = Cn.CustomerID
         	where Cs.Name like ('%'+@custName+'%')
         	group by Cs.Name
         	order by [Income] desc
   	end
   	else begin
         	if @custName is null
         	begin
                	select Cs.Name,
                       	Round(Sum(abs(datediff(DD,P.ReturnDate,Cn.HireDate)) * Ct.Rent +
                       	(P.FinishMileage - Cn.StartMileage) * V.PricePerKm * IIF(Cs.Company=1,1,0.9)), 2) as [Income]
                	from Vehicles V
                	inner join Categories Ct
                	on Ct.CategoryID = V.CategoryID
                	inner join Contracts Cn
                	on Cn.CarNumber = V.CarNumber
                	inner join Protocols P
                	on Cn.ContractID = P.ContractID
                	inner join Customers Cs
                	on Cs.CustomerID = Cn.CustomerID
                	group by Cs.Name
                	order by [Income] desc
         	end
         	else begin print 'Няма такъв клиент.' end
   	end
end
 
GO
/****** Object:  StoredProcedure [dbo].[usp_FindVehicleByRent]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_FindVehicleByRent]
   	@rent money = null
as begin
   	if exists(select * from Categories where Rent = @rent)
   	begin
         	select CarNumber, Brand, Model, PricePerKm, C.Type
         	from Vehicles V
         	inner join Categories C
         	on C.CategoryID = V.CategoryID
         	where C.Rent = @rent
   	end
   	else begin
         	print 'Не отдаваме под наем превозно средство с такава цена за ден.'
   	end
end
GO
/****** Object:  StoredProcedure [dbo].[usp_FindVehicleByType]    Script Date: 05.05.2022 г. 09:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [dbo].[usp_FindVehicleByType]
   	@type nvarchar(10) = null
as begin
   	if exists(select * from Categories where Type = @type)
   	begin
         	select CarNumber, Brand, Model, PricePerKm, Rent
         	from Vehicles V
         	inner join Categories C
         	on C.CategoryID = V.CategoryID
         	where C.Type = @type
   	end
   	else begin
         	print 'Не отдаваме под наем превозно средство от тази категория.'
   	end
end
GO
USE [master]
GO
ALTER DATABASE [Copy_Rent4UDB] SET  READ_WRITE 
GO
