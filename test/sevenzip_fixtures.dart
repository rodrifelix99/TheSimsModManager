/// Small 7z archives, each holding the same three files packed a
/// different way, as base64.
///
/// Four are written by libarchive's own 7z writer (`tar --format=7zip
/// --options 7zip:compression=...`), which covers every coder it can
/// produce. [sevenZipLzma1] is assembled by hand around a raw LZMA
/// stream, because libarchive writes LZMA2 and never LZMA1 - and LZMA1
/// is what 7-Zip itself writes by default, so it is the one that
/// actually matters. All but [sevenZipCopy] carry a compressed header
/// too, which is where reading a real archive starts.
library;

/// What every fixture holds.
const sevenZipContents = {
  'hair.package': 'hair mesh bytes, repeated. hair mesh bytes, repeated. '
      'hair mesh bytes, repeated. ',
  'inner/lamp.package':
      'lamp payload lamp payload lamp payload lamp payload lamp payload ',
  'readme.txt': 'read me',
};

const sevenZipLzma1 =
    'N3q8ryccAAQigjQFOgAAAAAAAACHAAAAAAAAAEyVVsIANBhJctbPUa7x9qgX45'
    '9npp/zdYuCVbkuD1kncLglu00echojkiyrVcgpEPLL2hxpec+wlf/nBEgAAQQG'
    'AAEJOgAHCwEAASMDAQEFXQAAAAEM/5kAAAAAAAAAAAgNAwlRQQAABQMRVwBoAG'
    'EAaQByAC4AcABhAGMAawBhAGcAZQAAAGkAbgBuAGUAcgAvAGwAYQBtAHAALgBw'
    'AGEAYwBrAGEAZwBlAAAAcgBlAGEAZABtAGUALgB0AHgAdAAAAAAA';

const sevenZipLzma2 =
    'N3q8ryccAAOaNRDW2AAAAAAAAAAcAAAAAAAAAG8REe3gAJgANF0ANBhJctbPUa'
    '7x9qgX459npp/zdYuCVbkuD1kncLglu00echojkiyrVcgpEPLL2hxpSQhM1gDg'
    'AOsAlF0AAIEzB64P0bZyEKCQoHdeulg+Es9PPWAl8I59r9PZW7ri9DCBj6xufF'
    '/C0ZzHY2FQBkyDAv/k8/mYv/GXRtRSStrcarF2L9hRjIowUWlkqtJMnNkOLlDR'
    'TP+a7NNBs+ewJbjBCtzi8XNJ9EkmYHPou2cA3qf6rT2e+MZG+9KnfhAJDIbLMC'
    '/yV4OUO4SyGBpbuAAAAAAXBjwBCYCcAAcLAQABISEBFgyA7AoBrt+W1wAA';

const sevenZipCopy =
    'N3q8ryccAAPBwTWjmQAAAAAAAADuAAAAAAAAAFZqmcJoYWlyIG1lc2ggYnl0ZX'
    'MsIHJlcGVhdGVkLiBoYWlyIG1lc2ggYnl0ZXMsIHJlcGVhdGVkLiBoYWlyIG1l'
    'c2ggYnl0ZXMsIHJlcGVhdGVkLiBsYW1wIHBheWxvYWQgbGFtcCBwYXlsb2FkIG'
    'xhbXAgcGF5bG9hZCBsYW1wIHBheWxvYWQgbGFtcCBwYXlsb2FkIHJlYWQgbWUB'
    'BAYAAwlRQQcABwsDAAEBAAEBAAEBAAxRQQcACAoBdxtyUMmiBYPheHJ7AAAFAx'
    'FXAGgAYQBpAHIALgBwAGEAYwBrAGEAZwBlAAAAaQBuAG4AZQByAC8AbABhAG0A'
    'cAAuAHAAYQBjAGsAYQBnAGUAAAByAGUAYQBkAG0AZQAuAHQAeAB0AAAAFBoBAC'
    'gc92qrJN0BhiD3aqsk3QHSI/dqqyTdARIaAQAoHPdqqyTdAYYg92qrJN0B0iP3'
    'aqsk3QETGgEAJz75aqsk3QGqZvlqqyTdAT9o+WqrJN0BFQ4BACCApIEggKSBII'
    'CkgQAA';

const sevenZipDeflate =
    'N3q8ryccAANNVl4azwAAAAAAAAAiAAAAAAAAABH5/e/LSMwsUshNLc5QSK'
    'osSS3WUShKLUhNLElN0VPIIEsqJzG3QKEgsTInPzGFLE5RKpDITQUAAACBMweu'
    'D9E9XiygkKByQ9RZqK9MTIzmdFT18yXS5HCZ3Ug3vy6tz7iRjJx4403BcRJbJm'
    'ZnLbcCwk1EWTQodB4J06R+NiobN5NT2F8PdYtQoJWsScVzNNx/th/Df8vZ5rVV'
    'oTgreDU5RDT5YVMcEucdsjQNrn/S2/Hc2X8iVoNWIq0ns7SnYGrioFUDJVmnz1'
    'rlS8nP//0s0YAXBjQBCYCbAAcLAQABIwMBAQVdAACAAAyA7AoBSgV3wwAA';

const sevenZipBzip2 =
    'N3q8ryccAAOGs+Qj9gAAAAAAAAAiAAAAAAAAAP6lsgtCWmg2MUFZJlNZBweNpQ'
    'AAKZGAQAU2ZtwgIABqG1TIAaARRR6IGj1LDlRQQJqnBjiWpXIE5YWTSHMzOnXG'
    'Ze2smWEtICU5TCbJTbISNOGEt+LuSKcKEgDg8bSgAACBMweuD9NPX71AwJDO5c'
    't29lOABF86w6YKuC/2rLXjSAfckxDub17gAYmsqzaDOKCKcQh4NwIC4T/926vv'
    'GdQoMFrI1SOT3g7vfZ3Bv5oHYAZVfzBf4vQ22Mrm42k0PFUPSJNB4iBNpnw3KA'
    'DnvfQVNu7kIfd8r0N/lQQujJx8SSFL2wdXL6/kUO6y6lPd0YU1IzfX//1CdkAX'
    'BlsBCYCbAAcLAQABIwMBAQVdAACAAAyA7AoB1/TQXwAA';
