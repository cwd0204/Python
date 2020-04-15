import pyodbc

driver = '{Microsoft Access Driver(*.mdb,*.accdb)}'
filepath = r'C:\Users\weidongc\Desktop\Booking\2020\2020 CN Ads Booking v11.accdb'

myDataSource = pyodbc.dataSources()
access_drive = myDataSource['MS Access Database']

cnxn = pyodbc.connect(driver=access_drive,dbq=filepath,autocommit=True)
crsr = cnxn.cursor()

#grab all the tables

table_list = list(crsr.tables())

# for i in table_list:
#     print(i)
table_name = 'sample taaa'

query = 'select * from {}'.format(table_name)

crsr.execute(query)

one_row = crsr.fetchone()

display(one_row[0])
