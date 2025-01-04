-- Catppuccin Frappé
local palette = {
  rosewater = 0xfff2d5cf,
  flamingo = 0xffeebebe,
  pink = 0xfff4b8e4,
  mauve = 0xffca9ee6,
  red = 0xffe78284,
  maroon = 0xffea999c,
  peach = 0xffef9f76,
  yellow = 0xffe5c890,
  green = 0xffa6d189,
  teal = 0xff81c8be,
  sky = 0xff99d1db,
  sapphire = 0xff85c1dc,
  blue = 0xff8caaee,
  lavender = 0xffbabbf1,
  text = 0xffc6d0f5,
  subtext_1 = 0xffb5bfe2,
  subtext_0 = 0xffa5adce,
  overlay_2 = 0xff949cbb,
  overlay_1 = 0xff838ba7,
  overlay_0 = 0xff737994,
  surface_2 = 0xff626880,
  surface_1 = 0xff51576d,
  surface_0 = 0xff414559,
  base = 0xff303446,
  mantle = 0xff292c3c,
  crust = 0xff232634,
}

return {
  palette = palette,

  grey = palette.text,
  black = palette.mantle,
  white = palette.text,
  transparent = 0x00000000,

  bg1 = palette.mantle,
  bg2 = palette.base,

  bar = {
    bg = palette.crust,
  },

  popup = {
    bg = palette.overlay_0,
  },

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
      return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
