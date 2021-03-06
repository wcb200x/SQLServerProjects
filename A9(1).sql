--Create Trigger [dbo].[trg_mem_balance]
--On [dbo].TableName
--After Insert, Delete, Update
--As
--Begin
--select 'content of inserted' --just for visuals for all inserted and deleted items
--		select *
--		from inserted
--		select 'content of deleted'
--		select *
--		from deleted
--End
--Go
Alter Trigger [dbo].[trg_mem_balance] 
on [dbo].[DETAILRENTAL]
After	Insert, Delete, Update As
	Begin
		select 'content of inserted' --just for visuals for all inserted and deleted items
		select *
		from inserted
		select 'content of deleted'
		select *
		from deleted
if((exists(select * from inserted)) AND (exists(select* from deleted))) --check if it is a daily event
	Begin
		Declare Update_Cursor Cursor For --update cursor
		select I.Rent_Num, I.Detail_DueDate, I.Detail_ReturnDate, I.Detail_DailyLateFee, D.Detail_DueDate, D.Detail_ReturnDate, D.Detail_DailyLateFee
		from Inserted I Inner Join Deleted D on i.rent_num = d.rent_num AND i.vid_num = D.Vid_num
		
		--Object variables
		declare @Late_Fee decimal(5,2) 
		declare @Return_Date datetime 
		declare @Due_Date datetime 
		declare @Due_Date_After datetime 
		declare @Return_Date_After datetime
		declare @Rent_Num int 
		declare @Late_Fee_After decimal (5,2)
		declare @Late_Fee_Before decimal (5,2)
		declare @Late_Fee_Post decimal (5,2)
		declare @Difference decimal (5,2)
		declare @Mem_Num int 

		Open Update_Cursor --Stores all table values into new declared variables
			Fetch Next --Fetches each item until it reaches the end
				From Update_Cursor
					Into @Rent_Num, @Due_Date_After, @Return_Date_After, @Late_Fee_After, @Due_Date, @Return_Date, @Late_Fee 
	While(@@Fetch_Status = 0) --system variable(status will be zero when holding a record)
	Begin
	--a)
			if(@Return_Date > @Due_Date) -- check if late fee prior to update
			Begin --calculate late fee
				select @Late_Fee_Before = DateDiff(Day, @Due_Date, @Return_Date) * @Late_Fee --get datediff from deleted table
			End
			Else --If no late fee prior set to zero
			select @Late_Fee_Before = 0

			select 'Prior to Update Late Fee:'
			select @Late_Fee_Before
	

		--b) 
			If(@Return_Date_After > @Due_Date_After) --Check if late fee post update
				Begin
					select @Late_Fee_Post = DateDiff(Day, @Due_Date_After, @Return_Date_After) * @Late_Fee_After --get datediff from inserted table
				End
				Else --If no late fee prior set to zero
				select @Late_Fee_Post = 0

				select 'Post Update Late Fee:'
				select @Late_Fee_Post
		

		--c)
			select @Difference = (@Late_Fee_Before - @Late_Fee_Post) --new variable to hold difference of prior late fee from current late fee
			select 'Late Fee Change:'
			select @Difference

		--d)
			if (@Difference <> 0) --variable that holds @Late_Fee_Before - @Late_Fee_Post
			Begin
				select @Mem_Num = m.mem_num
				from Rental R inner join Membership M on r.mem_num = m.mem_num AND r.rent_num = @rent_num
			Update Membership
			Set Mem_Balance = Mem_Balance - @Difference
			Where Mem_Num = @Mem_Num		  
			End

			Fetch Next --Fetches each item until it reaches the end
				From Update_Cursor
					Into @Rent_Num, @Due_Date_After, @Return_Date_After, @Late_Fee_After, @Due_Date, @Return_Date, @Late_Fee 
		END
			Close Update_Cursor
			Deallocate Update_Cursor
	END
END 
	