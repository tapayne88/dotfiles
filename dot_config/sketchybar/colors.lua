-- Catppuccin Frappé
return {
  black = 0xff232634,
  white = 0xffc6d0f5,
  red = 0xffe78284,
  green = 0xffa6d189,
  blue = 0xff8caaee,
  yellow = 0xffe5c890,
  orange = 0xffef9f76,
  mauve = 0xffcba6f7,
  grey = 0xff949cbb,
  transparent = 0x00000000,

  bar = {
    bg = 0xff1e1e2e,
    border = 0xff292c3c,
  },
  popup = {
    bg = 0xff737994,
    border = 0xff7f8490,
  },
  bg1 = 0xff292c3c,
  bg2 = 0xff303446,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
      return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
