function string_split(str, delimiter) {
	var p = string_pos(delimiter, str), o = 1;
	var dl = string_length(delimiter);
	var rw = array_create(0);
	if (dl) while (p) {
		array_push(rw, string_copy(str, o, p - o));
	    o = p + dl;
	    p = string_pos_ext(delimiter, str, o);
	}
	return rw;
}

function string_is_real(str)
{
	var s = argument0;
	var n = string_length(string_digits(s));
	var p = string_pos(".", s);
	var e = string_pos("e", s);
	switch (e) {
	    case 0: break; // ok!
	    case 1: return false; // "e#"
	    case 2: if (p > 0) return false; break; // ".e#" or "1e."
	    default: if (p > 0 && e < p) return false; break; // "1e3.3"
	}
	return n && n == string_length(s) - (string_char_at(s, 1) == "-") - (p != 0) - (e != 0);
}

function string_hex(dec, len)
{
    len = is_undefined(len) ? 1 : len;
    var hex = "";
 
    if (dec < 0) {
        len = max(len, ceil(logn(16, 2*abs(dec))));
    }
 
    var dig = "0123456789ABCDEF";
    while (len-- || dec) {
        hex = string_char_at(dig, (dec & $F) + 1) + hex;
        dec = dec >> 4;
    }
 
    return hex;
}