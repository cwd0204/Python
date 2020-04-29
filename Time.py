
class Time:
    def __init__(self):
        self.hour = 0
        self.minute = 0
        self.second = 0

    def printMilitary(self):
        print('%.2d:%.2d:%.2d' %(self.hour, self.minute, self.second))

    def printStandard(self):

        standardTime = ''

        if self.hour == 0 or self.hour ==12:
            standardTime += '12:'
        else:
            standardTime += '%.2d' %(self.hour % 12)
        standardTime += '%.2d:%.2d' % (self.minute,self.second)

        if self.hour < 12:
            standardTime += ' AM'
        else:
            standardTime += ' PM'
        print(standardTime)

time1 = Time()

print('The attribute of time1 are: ')
print('Time1.hour:', time1.hour)
print('Time1.minute:', time1.minute)
print('Time1.second:', time1.second)

#access object's methods

print('\nCalling method printMilitary:',time1.printMilitary())
print('\nCalling method printStandard:',time1.printStandard())

#change value of object's attributes

print("\n\nChanging time1's hour attributes...")
time1.hour = 25

print('Calling method printMilitary after alteration:')
time1.printMilitary()