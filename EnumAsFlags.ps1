[Flags()] enum Lemur
{
  RingTailed  = 1
  AyeAye      = 2
  Sifaka      = 4
  Mouse       = 8
}

<#
  Usage:
  PS C:\ > [Lemur](1 -bxor 8)
  RingTailed, Mouse
#>
