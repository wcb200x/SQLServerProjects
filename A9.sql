--pg. 436 #75 
--a)Calculate the value of the late fee prior to the update that triggered this execution of the trigger. The value of the late fee is the days
--late multiplied by the daily late fee. If the previous value of the late fee was null, then treat it as zero(0)
--b) Calculate the value of the late fee after the update that triggered this execution of the trigger. If the value of the late fee is now null,
--then treat it as zero(0)
--c)Substract the prior value of the late fee from the current value of the late fee to determine the change in late fee for this video rental
--d)If the amount calculated in Part C is not zero(0), then update the membership balance by the amount calculated for the membership associated 
--with this rental
Create Trigger trg_mem_balance 
on DetailRental
After	Insert, Delete, Update As
Begin
select Mem_balance
from MEMBERSHIP
End



ALTER TRIGGER [dbo].[UPDATE_ON_HAND]    ON  [dbo].[ORDER_LINE]    AFTER INSERT,DELETE,UPDATEAS BEGIN DECLARE @ITEM_NUM CHAR(5) DECLARE @NUM_ORDERED DECIMAL(6,2)
 --insert case IF(EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)) BEGIN SELECT @ITEM_NUM = ITEM_NUM,  @NUM_ORDERED = NUM_ORDERED FROM INSERTED
 UPDATE ITEM SET ON_HAND = ON_HAND - @NUM_ORDERED WHERE ITEM_NUM = @ITEM_NUM END
 --delete case IF(NOT EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED)) BEGIN SELECT @ITEM_NUM = ITEM_NUM,  @NUM_ORDERED = NUM_ORDERED FROM DELETED
 UPDATE ITEM SET ON_HAND = ON_HAND + @NUM_ORDERED WHERE ITEM_NUM = @ITEM_NUM END
 --update case IF(EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED)) BEGIN DECLARE @CHANGE INT
 SELECT @ITEM_NUM = I.ITEM_NUM,  @CHANGE = I.NUM_ORDERED - D.NUM_ORDERED FROM DELETED D INNER JOIN INSERTED I ON D.ITEM_NUM = I.ITEM_NUM AND D.ORDER_NUM = I.ORDER_NUM
 UPDATE ITEM SET ON_HAND = ON_HAND - @CHANGE WHERE ITEM_NUM = @ITEM_NUM END
END