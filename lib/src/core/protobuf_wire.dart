import 'dart:convert';
import 'dart:typed_data';

/// A minimal protobuf wire-format reader.
///
/// The Sims 4 serializes its save data as protocol buffers, and all this
/// app wants out of them is a handful of named fields: strings, numbers
/// and submessages at known field numbers. That needs the wire format -
/// tag, wire type, varint - and nothing else, so this is a walker over
/// raw fields rather than a generated-code dependency: no schema, no
/// codegen, unknown fields skipped for free (which is also what keeps it
/// working when a game patch adds fields).
///
/// Reading is tolerant by design: a malformed byte ends the walk and the
/// fields parsed so far stand. Every value that came off the disk is a
/// claim, not a fact, and the caller treats absence as "unknown".

/// One field as it sits on the wire. [value] carries varint/fixed32/
/// fixed64 payloads (unsigned, wrapped into Dart's signed 64-bit int);
/// [bytes] carries length-delimited payloads (strings, submessages,
/// packed arrays) and is null for the numeric wire types.
class ProtoField {
  const ProtoField(this.number, this.wireType, this.value, this.bytes);

  final int number;
  final int wireType;
  final int value;
  final Uint8List? bytes;
}

/// Parses [data] as one protobuf message and returns its fields in wire
/// order (repeated fields appear once per occurrence). Never throws; a
/// malformed tail is dropped.
List<ProtoField> readProtoFields(Uint8List data) {
  final fields = <ProtoField>[];
  final len = data.length;
  var pos = 0;

  int? varint() {
    var result = 0;
    var shift = 0;
    while (pos < len) {
      final byte = data[pos++];
      if (shift < 64) result |= (byte & 0x7F) << shift;
      if (byte & 0x80 == 0) return result;
      shift += 7;
      if (shift > 70) return null; // malformed: longer than any 64-bit varint
    }
    return null; // truncated
  }

  // Group wire types (3/4) died with proto2 but a walker must still not
  // trip on them: skip nested fields until the matching end tag.
  bool skipGroup() {
    while (pos < len) {
      final tag = varint();
      if (tag == null) return false;
      final wireType = tag & 7;
      switch (wireType) {
        case 0:
          if (varint() == null) return false;
        case 1:
          pos += 8;
        case 2:
          final size = varint();
          if (size == null || size < 0 || pos + size > len) return false;
          pos += size;
        case 3:
          if (!skipGroup()) return false;
        case 4:
          return true;
        case 5:
          pos += 4;
        default:
          return false;
      }
      if (pos > len) return false;
    }
    return false;
  }

  while (pos < len) {
    final tag = varint();
    if (tag == null) break;
    final number = tag >>> 3;
    final wireType = tag & 7;
    if (number == 0) break;
    switch (wireType) {
      case 0:
        final value = varint();
        if (value == null) return fields;
        fields.add(ProtoField(number, wireType, value, null));
      case 1:
        if (pos + 8 > len) return fields;
        fields.add(ProtoField(number, wireType,
            ByteData.sublistView(data).getUint64(pos, Endian.little), null));
        pos += 8;
      case 2:
        final size = varint();
        if (size == null || size < 0 || pos + size > len) return fields;
        fields.add(ProtoField(number, wireType, size,
            Uint8List.sublistView(data, pos, pos + size)));
        pos += size;
      case 3:
        if (!skipGroup()) return fields;
      case 5:
        if (pos + 4 > len) return fields;
        fields.add(ProtoField(number, wireType,
            ByteData.sublistView(data).getUint32(pos, Endian.little), null));
        pos += 4;
      default:
        return fields; // unknown wire type: nothing after it can be trusted
    }
  }
  return fields;
}

/// Lookups over a parsed message. Field numbers are the schema's; a field
/// that isn't there (older save, renumbered pack) answers null.
extension ProtoFieldLookup on List<ProtoField> {
  int? firstInt(int number) {
    for (final f in this) {
      if (f.number == number && f.bytes == null) return f.value;
    }
    return null;
  }

  String? firstString(int number) {
    final bytes = firstBytes(number);
    if (bytes == null) return null;
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  Uint8List? firstBytes(int number) {
    for (final f in this) {
      if (f.number == number && f.bytes != null) return f.bytes;
    }
    return null;
  }

  Iterable<Uint8List> allBytes(int number) sync* {
    for (final f in this) {
      if (f.number == number && f.bytes != null) yield f.bytes!;
    }
  }

  /// A repeated integer field, whichever way it was written: packed
  /// (one length-delimited blob of varints) or expanded (one varint
  /// field per element).
  List<int> repeatedInts(int number) {
    final values = <int>[];
    for (final f in this) {
      if (f.number != number) continue;
      final bytes = f.bytes;
      if (bytes == null) {
        values.add(f.value);
        continue;
      }
      var pos = 0;
      while (pos < bytes.length) {
        var result = 0;
        var shift = 0;
        var ok = false;
        while (pos < bytes.length) {
          final byte = bytes[pos++];
          if (shift < 64) result |= (byte & 0x7F) << shift;
          if (byte & 0x80 == 0) {
            ok = true;
            break;
          }
          shift += 7;
          if (shift > 70) break;
        }
        if (!ok) break;
        values.add(result);
      }
    }
    return values;
  }
}
