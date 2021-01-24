---
title: Youtube video of 3D maze game for Sinclair ZX Spectrum
description: James O'Grady plays, reviews and mods a game I wrote in Z80 machine code in 1984
created_at: 2021-01-23 16:42:00 +00:00
updated_at: 2021-01-23 16:42:00 +00:00
guid: 8d8937e0-79a1-4e44-a1df-e37b7d43ff36
published: false
---

<img style="display: block; margin-left: auto; margin-right: auto; width: 33.3%; float:right; padding: 10px" src="/images/graphic-adventures-for-the-spectrum-48k.jpg" alt="Book cover for 'Graphic Adventures for the Spectrum 48K'">

One evening last week I was idly browsing the web when I came across this quirky Youtube video which piqued my interest. In the video [James O'Grady][] demonstrated a 3D maze game. He'd typed in the code for the game from a familiar-sounding book called [Graphic Adventures for the Spectrum 48K][].

The nominal author of this book, Richard Hurley, was one of my teachers and he included programs written by me and a number of my friends. The 3D maze game was one I wrote in about 1984 when I was 16 years old. In the video James goes on to critique the game, to explore some ways to improve it, and to read some reviews of the book from magazines of the time.

The game was the first game I wrote entirely in Z80 machine code using the excellent [Zeus assembler][] and with my trusty copy of [The Complete Spectrum ROM Disassembly][]. It was closely based on the "3D Monster Maze" game by J.K. Greye Software:

<blockquote>
  <p>
    A computer game developed from an idea by J.K. Greye and programmed by Malcolm Evans in 1981 for the Sinclair ZX81 platform with the 16 KB memory expansion. The game was initially released by J. K. Greye Software in early 1982 and re-released later the same year by Evans' own startup, New Generation Software. Rendered using low-resolution character block "graphics", it was one of the first 3D games for a home computer, and the first game incorporating typical elements of the genre that would later be termed survival horror.
    &ndash;
    <cite>
      <a href="https://en.wikipedia.org/wiki/3D_Monster_Maze">Wikipedia: 3D Monster Maze</a>
    </cite>
  </p>
</blockquote>

<div style="text-align: center; padding-bottom: 12px">
  <iframe width="80%" height="315" src="https://www.youtube.com/embed/nKvd0zPfBE4" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

<blockquote>
  <p>
    Most importantly, from the point of view of video game history, the ZX81 was the computer which hosted the world's first ever 3D game on a home computer - JK Greye's 3D Monster Maze. A simple labyrinth is generated, and the player has to find their way out, all the while being stalked by a Tyrannosaurus Rex. The whole experience was rendered in what is now referred to as 'first person' view - ie, you see what you would see out of the eyes of the character in the maze, as pictured in the ZX81's rather blocky but still effective graphics. A quick play of this game on an emulator is recommended to all fans of Doom, Quake, Unreal, Half Life and all the other FPSs which are now so popular, as it really is the literal grandaddy of them all. It is difficult now to describe the impact this game had on a public who had quite literally never seen anything like it.
    &ndash;
    <cite>
      <a href="https://h2g2.com/edited_entry/A821648">The Hitchhiker's Guide to the Galaxy (Earth Edition): The Wonderful Computers of Clive Sinclair</a>
    </cite>
  </p>
</blockquote>

One slight disappointment was that unlike in "3D Monster Maze" there was no "monster" in my version of the game or at least not in the version James was playing. I know that I did eventually add a Tyrannosaurus Rex to the game, but I vaguely remember having to rush for a publication deadline, so the monster might've have missed the cut! If I recall correctly, a friend with better artistic skills than me drew a T Rex for me in a series of "frames" walking towards the observer. I then traced the drawings onto graph paper and converted them into [user-defined graphic characters][]. I do half wonder whether these might be the mystery bytes which James refers to at one point in his video. Otherwise I believe the program uses calls to the ROM, e.g. [this line-drawing subroutine][], to draw the walls of the maze.

<div style="text-align: center; padding-bottom: 12px">
  <iframe width="80%" height="315" src="https://www.youtube.com/embed/Q656CqMIXLY" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

James must've been incredibly patient to type in all the raw numbers for the machine code with only very rudimentary checksums. And, given that the game is written entirely in machine code and the assembler source code is lost in the mists of time, I was impressed that James managed to successfully modify the game in a couple of different ways using a load of judicious [`PEEK`s and `POKE`s][peek-and-poke] and apparently without the use of a disassembler. In particular he's written a nice maze editor program which runs on the Spectrum and allows you to design your own maze. I was quite amused to learn that the maze had to be square - I can't imagine it would've been much harder for me to have allowed rectangular ones!

James is very fair in his criticisms of the game - his main observation is that it's not very interesting to play, bit it is very fast compared to other similar games. I also enjoyed reading the reviews of the book he'd found in a couple of magazines of the time. I had a lovely exchange with him in [the Youtube comments][] and he [changed the title][change-title-tweet] of the Youtube video to include my name which was a nice gesture. Anyway, this was a brilliant trip down memory lane for me and reminded me of my programming roots!

If you feel as if you want the full "type it in" experience, the Portuguese (!) version of the book is available for [download][book-pdf] from [Spectrum Computing][] and you can find the game in "Labirinto" (chapter 4, page 105). Otherwise, [this GitHub repo][3s-maze-repo] includes a set of [TAP format][] files which might work in a Spectrum emulator.

[James O'Grady]: https://twitter.com/JAMOGRAD
[Graphic Adventures for the Spectrum 48K]: https://www.amazon.co.uk/dp/0744700132
[Zeus assembler]: https://en.wikipedia.org/wiki/Zeus_Assembler
[3D Monster Maze]: https://en.wikipedia.org/wiki/3D_Monster_Maze
[the Youtube comments]: https://www.youtube.com/watch?v=Q656CqMIXLY&lc=UgzsXaL19aLWF7T3qCp4AaABAg
[peek-and-poke]: https://en.wikipedia.org/wiki/PEEK_and_POKE
[change-title-tweet]: https://twitter.com/JAMOGRAD/status/1351920870621589506
[The Complete Spectrum ROM Disassembly]: https://archive.org/details/CompleteSpectrumROMDisassemblyThe
[this line-drawing subroutine]: https://speccy.xyz/rom/asm/24b7
[the-wonderful-computers-of-clive-sinclair]: https://web.archive.org/web/20201130205629/http://h2g2.com/edited_entry/A821648
[user-defined graphic characters]: https://en.wikipedia.org/wiki/ZX_Spectrum_character_set
[3s-maze-repo]: https://github.com/floehopper/3d-maze
[book-pdf]: https://archive.org/download/World_of_Spectrum_June_2017_Mirror/World%20of%20Spectrum%20June%202017%20Mirror.zip/World%20of%20Spectrum%20June%202017%20Mirror/sinclair/books/g/GraphicAdventuresForTheSpectrum48K(AventurasGraficasParaOSpectrum48K)(TemposLivres).pdf
[Spectrum Computing]: https://spectrumcomputing.co.uk/index.php?cat=96&id=2000168
[TAP format]: https://worldofspectrum.org/faq/reference/formats.htm#TAP
