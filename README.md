wikimapR, an R package for importing Wikimapia data as Simple Features
via API
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

`wikimapR` is an R package for accessing the raw vector data from
Wikimapia via official [Wikimapia API](http://wikimapia.org/api). Map
data can be returned either as [Simple Features
(`sf`)](https://cran.r-project.org/package=sf) objects or R `lists`.

### Installation

To install:

``` r
# Install the development version
# install.packages("devtools")
devtools::install_github("e-kotov/wikimapR")
```

To load the package and check the version:

``` r
library(wikimapR)
packageVersion("wikimapR")
#> [1] '0.1.0'
```

### Usage

#### Choose a bbox

Have a look at <https://boundingbox.klokantech.com> and choose a
bounding box. For example: `37.322997,55.485442,37.962686,55.981041` for
Moscow and it’s surroundings.

``` r
bbox <- c(37.322997,55.485442,37.962686,55.981041)
# bbox <- c(37.287362,55.492401,37.939676,56.001)
# bbox <- c(37.3190992757524,55.4878936531495,37.3839052968042,55.5246736421731)
```

#### Get the number of objects in this bounding box

``` r
wm <- wm_get_from_bbox(x = bbox, get_location = F)
#> Warning in wm_get_from_bbox(x = bbox, get_location = F): Using 'example'
#> API key. This key can only be used for testing. The interval for using
#> this key is 30 seconds. Get your own API key at http://wikimapia.org/api?
#> action=create_key .
```

``` r
wm$found
#> [1] "172925"
```

### Citation

``` r
citation ("wikimapR")
#> Warning in citation("wikimapR"): no date field in DESCRIPTION file of
#> package 'wikimapR'
#> Warning in citation("wikimapR"): could not determine year for 'wikimapR'
#> from package DESCRIPTION file
#> 
#> To cite package 'wikimapR' in publications use:
#> 
#>   person and comment = c) (NA). wikimapR: Import 'Wikimapia' Data
#>   as Simple Features via API. R package version 0.1.0.
#>   http://github.com/e-kotov/wikimapR/
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {wikimapR: Import 'Wikimapia' Data as Simple Features via API},
#>     author = {{person} and comment = c)},
#>     note = {R package version 0.1.0},
#>     url = {http://github.com/e-kotov/wikimapR/},
#>   }
#> 
#> ATTENTION: This citation information has been auto-generated from
#> the package DESCRIPTION file and may need manual editing, see
#> 'help("citation")'.
```

### License

The MIT License (MIT) + License File

Copyright © 2018 Egor Kotov

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
“Software”), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
