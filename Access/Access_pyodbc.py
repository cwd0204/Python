import pyodbc

driver = '{Microsoft Access Driver(*.mdb,*.accdb)}'
filepath = r'C:\Users\weidongc\Desktop\Booking\2020\2020 CN Ads Booking v12.accdb'

myDataSource = pyodbc.dataSources()
access_drive = myDataSource['MS Access Database']

cnxn = pyodbc.connect(driver=access_drive,dbq=filepath,autocommit=True)
crsr = cnxn.cursor()

#grab all the tables

table_list = list(crsr.tables())

# for i in table_list:
#     print(i)
table_name = 'wbr'

query = 'select * from {}'.format(table_name)


crsr.execute(query)

#print(result)
# df = pd.DataFrame()
#
# df.append(query)

# one_row = crsr.fetchall()
