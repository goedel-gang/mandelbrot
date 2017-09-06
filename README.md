# mandelbrot
This is a program in java-processing that renders the mandelbrot set. This set is defined as the set of the complex numbers, c such that there is no divergence when 0 is iterated under f(z) = z^2 + c The program works by simply iterating and observing if this number becomes large.  The speed of divergence is then used to give colourings.  The parameters kept track of are - x, y, scale, iteration cap, multibrot value (alternative exponent for z), width and height. See [usage.md](https://github.com/elterminad0r/mandelbrot/blob/master/usage.md) for info about the usage of the sketch.

It supports some mildly sophisticated serialisation - in string format. Any rendering can be described in a couple of terms (x, y, scale, width height, multibrot) which can be quite compactly encoded.

Here are three randomly chosen screenshots from my travels:

![screenshot](https://github.com/elterminad0r/mandelbrot/blob/master/screenshots/mandel1.png)
![screenshot](https://github.com/elterminad0r/mandelbrot/blob/master/screenshots/mandel2.png)
![screenshot](https://github.com/elterminad0r/mandelbrot/blob/master/screenshots/mandel3.png)

[Here](https://drive.google.com/drive/folders/0B3EHq-o9udUMQ2pyZlJKQWZlcDA?usp=sharing) is my full collection of higher quality serialisations for ayone interested.
