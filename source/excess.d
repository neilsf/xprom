module excess;

import std.math;
import std.conv;
import std.stdio;
import std.string;

ubyte[5] excessConvert(real value) {

  string toBinary(real fraction) {
      real exp = -1;
      int precision = 32;
      real div;
      real mod;
      string result = "";

      if(fraction == 0) {
          return "0";
      }

      while(fraction > 0 && (-exp <= precision)) {
          div = floor(fraction / pow(2,exp));
          mod = fraction - div * pow(2,exp);
          result ~= to!string(div);
          fraction = mod;
          exp -= 1;
      }

      return result;
    }

    bool is_negative;
    int whole;
    real fraction;
    string binary_fraction;
    string binary_whole;
    string mantissa;
    string binary_exponent;
    string m1, m2, m3, m4;
    int exponent;

    is_negative = value < 0;
    value = abs(value);
    whole = to!int(floor(value));
    fraction = value - whole;

    binary_fraction = toBinary(fraction);
    binary_whole = to!string(to!int(whole), 2);
    exponent = to!int(binary_whole.length) + 128;
    mantissa = rightJustify(binary_whole ~ binary_fraction, 32, 0);
    mantissa = (is_negative ? '1' : '0') ~ mantissa[1..32];

    m4 = mantissa[0..8];
    m3 = mantissa[8..16];
    m2 = mantissa[16..24];
    m1 = mantissa[24..32];

    binary_exponent = to!string(exponent, 2);

    writeln(m1 ~ "," ~ m2 ~ "," ~ m3 ~ "," ~ m4 ~ "," ~ binary_exponent);
    return [to!ubyte(exponent),
        to!ubyte(to!int(m4,2)),
        to!ubyte(to!int(m3,2)),
        to!ubyte(to!int(m2,2)),
        to!ubyte(to!int(m1,2))
    ];
}
