class   MyStuff(object):
    def __init__(self):
        self.tangerine = 'And now a thousand years between'

    def apple(self):
        print('I AM CLASSY APPLES!')


a = MyStuff()

a.apple()
print(a.tangerine)

print('*'*40)


class Song(object):
    def __init__(self,lyrics):
        self.lyrics = lyrics

    def sing_me_a_song(self):
        for line in self.lyrics:
            print(line)

happy_bday = Song(['Happy birthday to you',
                    'I dont want to get sued',
                    'So I will stop  right there'])

bulls_on_parade = Song(['They rally around the family',
                        'With pockets full of shells'])

happy_bday.sing_me_a_song()

bulls_on_parade.sing_me_a_song()