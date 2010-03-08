# Emergence

An easy-to-use graphical frontend for [Synergy] [1].

# Requirements

Emergence has been built, and designed, for Mac OS X 10.5 or later.

In  order to build Emergence you will need to [download] [2] Synergy and install
the two binaries, synergyc and synergys, under the following directory:

    Synergy/synergy-1.3.1

The Xcode project depends on the Synergy binaries being at this location so that
Emergence includes them within its application bundle.

In  addition  to Synergy, [Sparkle] [3] and [ZeroKit] [4] are also required when
building Emergence. Please download and install these frameworks to:

    /Library/Frameworks/

If everything is in its proper place the Xcode build should succeed.

# What if I find a bug, or what if I want to help?

Please, contact me with any questions, comments, suggestions, or problems. I try
to  make the time to answer every request.

Those  wishing to contribute to the project should begin by obtaining the latest
source  with  Git. The project is hosted on GitHub, making it easy for anyone to
make contributions. Simply create a fork and make your changes.

# Acknowledgments

My  thanks  to  Chris  Schoeneman  and  the  rest of the Synergy team for making
Emergence actually work.

# License

Copyright (c) 2010 Eric Czarny.

Emergence  should  be  accompanied  by  a  LICENSE  file  containing the license
relevant to this distribution.

If no LICENSE exists please contact Eric Czarny <eczarny@gmail.com>.

[1]: http://synergy2.sourceforge.net
[2]: http://sourceforge.net/projects/synergy2/files/Binaries
[3]: http://sparkle.andymatuschak.org
[4]: http://github.com/eczarny/zerokit
