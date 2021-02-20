# Make logo
library(hexSticker)
library(showtext)

# Add Google Font
font_add_google("Cormorant Garamond", "garamond")
showtext_auto() # Use this font in all rendering

# https://www.seekpng.com/ipng/u2w7a9t4e6q8t4w7_pixar-lamp-png-pixar-luxo-jr-png/
imgurl <- "man/figures/SeekPng.com_pixar-lamp-png_1678537.png"
sticker(
  imgurl,
  # Package settings
  package = "pixarfilms",
  p_size = 25,
  p_color = "#000000",
  p_family = "garamond",
  # Hexagon settings
  h_fill = "#89B9F7",
  h_color = "#000000",
  # Subplot or image settings
  s_x = 1,
  s_y = 0.75,
  s_width = 0.35,
  filename = "man/figures/logo_sticker.png"
)
