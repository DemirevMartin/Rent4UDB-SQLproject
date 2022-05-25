--1.1
create or alter proc usp_FindVehicleByType
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
 
exec usp_FindVehicleByType


---------
--1.2
 
create or alter proc usp_FindVehicleByRent
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
 
exec usp_FindVehicleByRent
 
/*Действителен брой дни * Наем за 1 ден + Изминати километри * Цена за
километър
Физическите лица ползват 10% отстъпка от цената за изминат километър.*/



------
--2.1
create or alter function DetectMileage(@date date)
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
 
select * from dbo.DetectMileage('2021-05-25')



-------
--2.2
create or alter procedure DetectMileageOnAPeriod(@StartDate date, @FinishDate date)
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
 
exec dbo.DetectMileageOnAPeriod '2021-03-15','2021-08-17'








--3.1
create or alter proc usp_FindIncomeByCarNumber
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
 
exec usp_FindIncomeByCarNumber


---------
--3.2
 
create or alter proc usp_FindIncomeByCategory
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
 
exec usp_FindIncomeByCategory

---------
--3.3
 
create or alter proc usp_FindIncomeByCustomerName
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
 
exec usp_FindIncomeByCustomerName





--4
CREATE OR ALTER FUNCTION udf_GetRemainingPayment()
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
 
SELECT *
FROM udf_GetRemainingPayment();

------
--5.
create function CountRents (@StartDate date, @FinishDate date, @CarNumber nvarchar(10))
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
 
select dbo.CountRents('2021-03-28', '2021-10-5', 'В 0599 СН') as [Брой наемания]



 
--6
SELECT TOP(10) *
FROM Contracts
ORDER BY HireDate DESC;
