SELECT Inventory_All.Package_ID,
       Inventory_All.Package_Name,
       Inventory_All.Start_Date AS Designed_Start_Date,
       Inventory_All.End_Date AS Designed_End_Date,
       Booking.Booking_Date,
       Booking.KAM_Owner AS KAM,
       Company.Brand_Name AS Brand,
       Booking.Actual_Start_Date AS Booking_Start_Date,
       Booking.Actual_End_Date AS Booking_End_Date,
       Booking.Actual_Price / DLookUp("Fx_rate", "Currency", "Currency='" & [Booking.Currency] & "'") AS Actual_Price,
       Contract_Mail.Contract_Received_Date,
       Booking.Channel,
       Booking.Department AS Booking_Department,
       Booking.PG,
       Booking.GL,
       Company.VendorCode_SellerID,
       Company.Legal_Entity_Name,
       
       IIF(Inventory_All.Package_Slot LIKE "*AMS*", "HAMS", "HEAD") AS Product
FROM ((Inventory_All
       LEFT JOIN Booking ON Inventory_All.Package_ID = Booking.Package_ID)
      LEFT JOIN Company ON Booking.Advertiser_ID = Company.Advertiser_ID)
LEFT JOIN Contract_Mail ON Booking.Contract_ID = Contract_Mail.Contract_ID
WHERE Booking.Actual_Price > 0
  AND Booking.Channel IN ('Non-Endemic',
                          'AGS')
ORDER BY Inventory_All.Package_ID,
         Booking.Actual_Start_Date;