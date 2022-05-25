--INSERT Contracts
CREATE OR ALTER PROCEDURE usp_InsertContracts
   	@contract NVARCHAR(10), @customer INT, @car NVARCHAR(10), @hireDate DATE,
   	@start INT, @advance MONEY
AS
BEGIN
   	IF NOT EXISTS (SELECT * FROM Contracts WHERE ContractID = @contract)
         	AND EXISTS (SELECT * FROM Customers WHERE CustomerID = @customer)
         	AND EXISTS (SELECT * FROM Vehicles WHERE CarNumber = @car)
   	BEGIN
         	DECLARE @flag BIT = 0
         	IF (@contract IS NULL) BEGIN
                	PRINT('Не сте въвели идентификационен код на договора!')
                	SET @flag = 1
         	END
           	IF (@hireDate IS NULL) BEGIN
                	PRINT('Не сте въвели дата на наемане!')
                	SET @flag = 1
         	END
         	IF (@start IS NULL) BEGIN
                	PRINT('Не сте въвели данните на километража при наемане!')
                	SET @flag = 1
         	END
         	IF (@advance IS NULL) BEGIN
                	PRINT('Не сте въвели стойността на авансово платената сума!')
                	SET @flag = 1
         	END
 
         	IF(@flag = 0)
         	BEGIN
			SET NOCOUNT ON
                	INSERT INTO Contracts
                	VALUES(@contract, @customer, @car, @hireDate, @start, @advance)
			PRINT 'Въведените данни бяха успешно записани!'
         	END
   	END
   	ELSE BEGIN
         	PRINT('Неправилно въведени данни (някое от следните):')
         	PRINT('1) Договор с такъв идентификационен код вече съществува;')
         	PRINT('2) Клиент с такъв идентификационен код не съществува;')
         	PRINT('3) Няма автомобил с такъв регистрационен код в базата данни.')
		
   	END
END
GO

--DELETE FROM Contracts WHERE ContractID LIKE 'Д-0041'
EXECUTE dbo.usp_InsertContracts 'Д-0041', 11, 'СА 1783 ВА', '2021-09-11', 1515, 150;



--INSERT
--t.Protocols  

create or alter proc usp_InsertProtocols
@contract NVARCHAR(10), @returnDate DATE, @finishKm INT
as begin
   	if exists(select * from Contracts where ContractID = @contract)
         	and not exists(select * from Protocols where ContractID = @contract)
   	begin
			DECLARE @flag BIT = 0
         	if @returnDate is null
         	begin print 'Не сте въвели дата на връщане.' 
				SET @flag = 1
			end
         	if @finishKm is null
         	begin print 'Не сте въвели данни от километраж при връщане.'
				SET @flag = 1
			end
         	if(@flag = 0) begin
		if (@finishKm > (SELECT StartMileage FROM Contracts WHERE ContractID = @contract)
   		and @returnDate > (SELECT HireDate FROM Contracts WHERE ContractID = @contract))
   		begin
         		set nocount on
         		insert into Protocols
         		values (@contract , @returnDate, @finishKm)
         		print 'Въведените данни бяха успешно записани!'
   		end
   		else begin
        	 	print ('Въведените данни са неправилни!')
   		end
   		end
   	else begin
         	print 'Не съществува такъв договор или вече има такъв протокол.'
   	end      	
end
--DELETE FROM Protocols WHERE ContractID LIKE 'Д-0041'
exec usp_InsertProtocols 'Д-0041', '2021-09-15', 1520


--t.Vehicles
create or alter proc usp_InsertVehicles
@carNum nvarchar(10), @brand nvarchar(15), @model nvarchar(30), @catNum int, @priceKm real
as begin
   	if exists(select * from Categories where CategoryID = @catNum)
         	and not exists(select * from Vehicles where CategoryID = @catNum)
   	begin
			DECLARE @flag BIT = 0
         	if @brand is null
         	begin print 'Не сте въвели марка на превозното средство.'
				SET @flag = 1
			end
         	if @model is null
         	begin print 'Не сте въвели модел на превозното средство.' 
				SET @flag = 1
			end
         	if @catNum is null
         	begin print 'Не сте въвели номер на категорията.'
				SET @flag = 1
			end
         	if @priceKm is null
         	begin print 'Не сте въвели цена за километър.'
				SET @flag = 1
			end
         	if(@flag = 0) begin
			set nocount on
                	insert into Vehicles
                	values (@carNum , @brand, @model, @catNum, @priceKm)
			print 'Въведените данни бяха успешно записани!'
         	end
   	end
   	else begin
         	print 'Не съществува такъв номер на категорията или вече има такъв регистрационен номер.'
   	end      	
end
go
--DELETE FROM Vehicles WHERE CarNumber LIKE 'ОВ 4444 АР'
exec usp_InsertVehicles 'ОВ 4444 АР', 'Магаре', 'Ново', 5, 0.01








--INSERT
--t.Customers
 
create proc usp_InsertIntoCustomers @customerID int, @name nvarchar(30), @address nvarchar(60), @company bit, @phone_number nvarchar(10)
as
begin
   	if not exists (select * from Customers where CustomerID = @customerID)
   	begin
             	   declare @flag bit = 0
 
 	     	if @customerID is null
             	   begin
 	           	print 'Не е въведен номер на клиент'
                   		set @flag = 1
             	   end
 	     	if @name is null
             	   begin
 	           	print 'Не е въведено име на клиент'
                   		set @flag = 1
             	   end
 	     	if @address is null
             	   begin
 	           	print 'Не е въведен адрес на клиент'
                   		set @flag = 1
             	   end
 	     	if @company is null
             	   begin
 	           	print 'Не е въведено фирма или физическо лице е клиентът'
                   		set @flag = 1
             	   end
             	   if @phone_number is null
             	   begin
 	           	print 'Не е въведен телефонен номер на клиента'
                   		set @flag = 1
             	   end
 	     	if (@flag = 0)
        	begin
                              	set nocount on
        	    	insert into Customers
        	    	values (@customerID, @name, @address, @company, @phone_number)
                              	print 'Въведените данни бяха успешно записани!'
 	     	end
 
   	end
   	else begin
 	     	if exists (select * from Customers where CustomerID = @customerID)
 	     	print 'Вече съществува клиент с такъв клиентски номер'
 	     	
   	end
end
go
exec usp_InsertIntoCustomers 12, 'Бай Иван', 'с. Венелин', 0, 0882222222
 
 
 

--INSERT
--t.Categories
create proc usp_InsertIntoCategories @categoryID int, @type nvarchar(10), @rent money
as
begin
   	if not exists (select * from Categories where CategoryID = @categoryID)
      	   and not exists (select * from Categories where Type = @type)
   	begin
             	   declare @flag bit = 0
 	     	if @categoryID is null
             	   begin
 	           	print 'Не е въведен номер на категорията'
                   		set @flag = 1
             	   end
 	     	if @type is null
             	   begin
 	           	print 'Не е въведен вида на превозното средство'
                       	set @flag = 1
             	   end
 	     	if @rent is null
             	   begin
 	           	print 'Не е въведен наем на превозното средство'
                   		set @flag = 1
             	   end
 	     	if @flag = 0
 	     	begin
                              	set nocount on
        	    	insert into Categories
        	    	values ( @categoryID, @type, @rent)
                              	print 'Въведените данни бяха успешно записани!'
 	     	end
   	end
   	else begin
 	     	if exists (select * from Categories where CategoryID = @categoryID)
 	     	print 'Вече съществува такъв номер категория'
 	     	else print 'Вече съществува такъв вид превозно средство'
 	     	
   	end
end
 
exec usp_InsertIntoCategories 5, 'каруца', 5









--UPDATE
--t.Contracts
 
create or alter proc usp_UpdateContracts
 @contract nvarchar(10), @custId int, @carNum nvarchar(10),   @hireDate date, @startKm int, @adv money
as begin
   	set @custId = Isnull(@custId, (select CustomerID from Contracts where ContractID = @contract))
   	set @carNum = Isnull(@carNum, (select CarNumber from Contracts where ContractID = @contract))
   	
   	if exists(select * from Customers where CustomerID = @custId)
         	and exists(select * from Vehicles where CarNumber = @carNum)
         	and exists(select * from Contracts where ContractID = @contract)
   	begin
		set @hireDate = Isnull(@hireDate, (select HireDate from Contracts where ContractID = @contract))
   	set @startKm = Isnull(@startKm, (select StartMileage from Contracts where ContractID = @contract))
   	set @adv = Isnull(@adv, (select Advance from Contracts where ContractID = @contract))

if(@startKm < (SELECT FinishMileage FROM Protocols WHERE ContractID = @contract)
and @hireDate < (SELECT ReturnDate FROM Protocols WHERE ContractID = @contract))  
begin
   	set nocount on
   	update Contracts
      set CustomerID = @custId, CarNumber = @carNum,
         	 HireDate = @hireDate, StartMileage = @startKm, Advance = @adv
      where ContractID = @contract
   	print 'Въведените данни бяха успешно обновени!'
end
else begin
   	print ('Въведените данни са неправилни!')
end
   	end
   	else begin
         	print 'Не съществува такъв идентификатор на клиент или няма такъв регистрационен номер, или вече има такъв договор.'
         	print 'Ако искате да добавите клиент ...'
         	print 'Ако искате да добавите превозно средство ...'
   	end      	
end
go
exec usp_UpdateContracts 'Д-0041', null, null, null, 1515, null



--UPDATE t.Protocols
 
CREATE OR ALTER PROCEDURE usp_UpProtocols
   	@id NVARCHAR(10), @returnDate DATE, @finish INT
AS
BEGIN
   	IF EXISTS (SELECT * FROM Protocols WHERE ContractID = @id)
   	BEGIN
         	SET @returnDate = ISNULL(@returnDate, (SELECT ReturnDate FROM Protocols WHERE ContractID = @id))
         	SET @finish = ISNULL(@finish, (SELECT FinishMileage FROM Protocols WHERE ContractID = @id))
 
         	IF (@finish > (SELECT StartMileage FROM Contracts WHERE ContractID = @id) 
			and @returnDate > (SELECT HireDate FROM Contracts WHERE ContractID = @id))
         	BEGIN
			SET NOCOUNT ON
                	UPDATE Protocols
                	SET ReturnDate = @returnDate, FinishMileage = @finish
                	WHERE ContractID = @id
			PRINT 'Въведените данни бяха успешно обновени!'
         	END
         	ELSE PRINT('Въведените данни са неправилни! Стойността на километража при връщане е по-малка, отколкото при наемане!')
   	END
 
   	ELSE
   	BEGIN
         	PRINT('Въведените данни са неправилни! Договор с такъв идентификационен код не съществува!')
   	END
END
GO
 
EXECUTE dbo.usp_UpdateProtocols 'Д-0041', null, 1520

--UPDATE Categories
 
CREATE OR ALTER PROCEDURE usp_UpdateCategories
   	@id INT, @type NVARCHAR(10), @rent MONEY
AS
BEGIN
   	IF EXISTS (SELECT * FROM Categories WHERE CategoryID = @id)
   	BEGIN
		SET NOCOUNT ON
         	SET @type = ISNULL(@type, (SELECT Type FROM Categories WHERE CategoryID = @id))
         	SET @rent = ISNULL(@rent, (SELECT Rent FROM Categories WHERE CategoryID = @id))
 
         	UPDATE Categories
         	SET Type = @type, Rent = @rent
         	WHERE CategoryID = @id
		PRINT 'Въведените данни бяха успешно обновени!'
   	END
   	ELSE
   	BEGIN
         	PRINT('Въведените данни са неправилни! Категория с такъв идентификационен код не съществува!')
   	END
END
GO
 
EXECUTE dbo.usp_UpdateCategories 5, null, 0.01
--UPDATE t.CUSTOMERS
create or alter proc usp_UpdateCustomers (@customerID int, @name nvarchar(30), @address nvarchar(60), @company bit, @phone_number nvarchar(10))
as
begin
   	if exists (select * from Customers where CustomerID = @customerID)
   	begin
		set nocount on
          	set @name = isnull(@name, (select [Name] from Customers where CustomerID = @customerID))
          	set @address = isnull(@address, (select Address from Customers where CustomerID = @customerID))
          	set @company = isnull(@company, (select Company from Customers where CustomerID = @customerID))
          	set @phone_number = isnull(@phone_number, (select PhoneNumber from Customers where CustomerID = @customerID))
 
          	update Customers
          	set [Name] = @name, Address = @address,
                 	Company = @company, PhoneNumber = @phone_number
          	where CustomerID = @customerID
 		print 'Въведените данни бяха успешно обновени!'
   	end
   	else
   	begin
          	print 'Не съществува такъв идентификатор на клиент.'
   	end
end
go
exec usp_UpdateCustomers 12, null, null, null, '0882222222'









--t.Vehicles 
create or alter proc usp_UpdateVehicles(@carNumber nvarchar(10), @brand nvarchar(15), @model nvarchar(30), @categoryID int, @pricePerKm real)
as
begin
   	set @categoryID = isnull(@categoryID, (select CategoryID from Vehicles where @carNumber = CarNumber))
 
   	if exists (select * from Categories where CategoryID = @categoryID)
          	and exists (select * from Vehicles where CarNumber = @carNumber)
   	begin
		set nocount on
          	set @brand = isnull(@brand, (select Brand from Vehicles where CarNumber = @carNumber))
          	set @model = isnull(@model, (select Model from Vehicles where CarNumber = @carNumber))
          	set @pricePerKm = isnull(@pricePerKm, (select PricePerKm from Vehicles where CarNumber = @carNumber))
 
          	update Vehicles
          	set Brand = @brand, Model = @model, CategoryID = @categoryID, PricePerKm = @pricePerKm
          	where CarNumber = @carNumber
 		print 'Въведените данни бяха успешно обновени!'
   	end
   	else
   	print 'Не съществува такъв номер на автомобил или не съществува такава категория.'
 
end

go
exec usp_UpdateVehicles 'ОВ 4444 АР', null, 'Породисто', null, null









--DELETE
-- on delete cascade 

-- Protocols
USE Copy_Rent4UDB
create or alter proc dbo.usp_DeleteProtocols @id NVARCHAR(10)
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
 
-- Contracts
USE Rent4UDB_copy
create or alter proc dbo.usp_DeleteContracts @id NVARCHAR(10)
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
 
--Categories
USE Rent4UDB_copy
create or alter proc dbo.usp_DeleteCategories @id INT
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
 
--Customers
USE Rent4UDB_copy
create or alter proc dbo.usp_DeleteCustomers @customerID int
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
 
--Vehicles
USE Rent4UDB_copy
create or alter proc dbo.usp_DeleteVehicles @carNum nvarchar(10)
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
