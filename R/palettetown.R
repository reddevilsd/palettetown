
#'Pokemon inspired colour palettes.
#'
#'@name palettetown
#'@author Tim CD Lucas
#'@docType package


NULL



#' Get a pokemon palette.
#'
#' Get a pokemon (R) palette by either giving a pokemon number or name.
#'
#'@param pokemon An integer or character pokemon name
#'@param spread How many, quite distinct, colours should be returned. See details.
#'@param extra If an integer, select one of the extra palettes (i.e. not based on individual pokemon)
#'
#'@name pokepal
#'@details Many of the pure pokemon palettes are not great. I have manually created
#'  a few "extra" palettes (e.g., teamrocket). 
#'  These might be easier to use.
#'  
#'  If \code{spread} is given an integer, the full palette is 
#'  clustered into that many groups (ward clustering in HSV space, using
#'  only hue and downweighted saturation). 
#'  The most common colour in each cluster is then returned. It is
#'  hoped this will give a good balance between reflecting the pokemons
#'  colouring while giving relatively distinct colours.
#'
#'  A few pokemon have odd names. Argument \code{pokemon} ignores letter case.
#'  Female and Male Nidoran are named NidoranF and NidoranM respectively.
#'  Mr. Mime should be either 'Mr. Mime' or 'mr. mime'. The full stop and space
#'  are needed.
#'@seealso \code{\link{ichooseyou}}
#'@examples
#'pal <- pokepal(3)
#'plot(1:length(pal), col = pal)
#'@export

pokepal <- function(pokemon = 1, spread = NULL, extra = NULL){
    
  # Fix lower case to first letter capitilised.
  if(is.character(pokemon)){
    pokemon <- tolower(pokemon)

    # Check that pokemon exists
    if(!pokemon %in% names(pokeColours)){
      message('That pokemon is not available')
      closeMatch <- names(pokeColours)[agrep(pokemon, names(pokeColours))]
      if(length(closeMatch) > 1){
        message(paste('Did you mean', closeMatch[1], '?'))
      }
      stop()
    }
  }

  if(is.numeric(pokemon) & pokemon > length(pokeColours)){
    stop(paste('Pokemon number too high. First', length(pokeColours), 'pokemon are available.'))
  }

  if(!is.null(extra)){
    if(!is.numeric(extra)) stop('Extra must be NULL or an integer')
    if(extra + 386 > length(pokeColours)){
      stop(paste('Extra too high. There are', length(pokeColours) - 386, 'extra palettes.'))
    }
  }


  if(!is.null(extra)){
    pal <- pokeColours[[extra + 386]]
  } else if(is.numeric(spread)){   # Reorder palette if spread is numeric.
    palette <- pokeColours[[pokemon]]
    # unless colour is very important, remove near whites.
    if(length(palette) > 5){
    palette2 <- c(palette[1:4],
      palette[5:length(palette)][
        grDevices::rgb2hsv(grDevices::col2rgb(palette[5:length(palette)]))[2,] > 0.3
      ]
    )
    if(length(palette2) >= spread){
      palette <- palette2
    }
    }
    if(length(palette) < spread){
      stop('Not enough colours available')
    }
    vals <- t(grDevices::rgb2hsv(grDevices::col2rgb(palette))[1:2,])
    
    vals[,2] <- vals[,2]/100
    clusts <- stats::cutree(stats::hclust(stats::dist(vals), method = 'ward.D2'),
    k = spread)
    # First occurence of each cluster number in clusts
    #   is always the most common.
    #   clusNums is a hacky way of seperating the more similar clusters in output
    clusNums <- suppressWarnings(
      c(matrix(c(1:floor(spread/2), spread:floor((spread/2 + 1))), 
      2, byrow = T))[1:spread] 
    )
    pal <- sapply(clusNums, function(x) palette[which(clusts == x)[1]])
            
  } else {
    pal <- pokeColours[[pokemon]]
  }
  
  return(pal)
}


#' Get a pokemon palette. Alias for pokepal.
#'
#' Get a pokemon palette by either giving a pokemon number or name.
#' The recomended syntax for this function is 
#' 'Magikarp' \%>\% ichooseyou using the pipe operator \%>\%
#' from the magrittr package.
#' To specify the \code{spread} parameter use
#' 'Snorlax' \%>\% ichooseyou(5)
#'
#'@inheritParams pokepal
#'
#'@name ichooseyou
#'@details If \code{spread} is given an integer, the full palette is 
#'  clustered into that many groups (ward clustering in HSV space). 
#'  The most common colour in each cluster is then returned. It is
#'  hoped this will give a good balance between reflecting the pokemons
#'  colouring while giving relatively distinct colours.
#'@seealso \code{\link{pokepal}}
#'@examples
#'library(magrittr)
#'pal <- 'Hoothoot' %>% ichooseyou
#'pal2 <- 'Pichu' %>% ichooseyou(6)
#'
#'@export


ichooseyou <- pokepal
