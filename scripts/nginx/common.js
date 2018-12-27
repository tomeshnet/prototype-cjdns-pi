// CJDNS pubkey to IPv6
// BASE32 code form CJDNS library
var numForAscii = [
    99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
    99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
    99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
     0, 1, 2, 3, 4, 5, 6, 7, 8, 9,99,99,99,99,99,99,
    99,99,10,11,12,99,13,14,15,99,16,17,18,19,20,99,
    21,22,23,24,25,26,27,28,29,30,31,99,99,99,99,99,
    99,99,10,11,12,99,13,14,15,99,16,17,18,19,20,99,
    21,22,23,24,25,26,27,28,29,30,31,99,99,99,99,99,
  ];
  
  // see util/Base32.h
  var Base32_decode = function (input) {
    var output = [];
  
    var outputIndex = 0;
    var inputIndex = 0;
    var nextByte = 0;
    var bits = 0;
  
    while (inputIndex < input.length) {
        var o = input.charCodeAt(inputIndex);
        if (o & 0x80) { throw new Error(); }
        var b = numForAscii[o];
        inputIndex++;
        if (b > 31) { throw new Error("bad character " + input[inputIndex] + " in " + input); }
  
        nextByte |= (b << bits);
        bits += 5;
  
        if (bits >= 8) {
            output[outputIndex] = nextByte & 0xff;
            outputIndex++;
            bits -= 8;
            nextByte >>= 8;
        }
    }
  
    if (bits >= 5 || nextByte) {
        throw new Error("bits is " + bits + " and nextByte is " + nextByte);
    }
    return output;
  };
  
// Convert Public Key to IPv6
// TODO add :
var publicKeyCache = [];
function public2IPv6(PubKey) {
    if (!publicKeyCache[PubKey]) {
        var IPv6=Base32_decode(PubKey);
        IPv6=sha512(sha512.array(IPv6));
        IPv6=IPv6.substr(0,32);
        publicKeyCache[PubKey]=IPv6;
    }
    return publicKeyCache[PubKey];
}