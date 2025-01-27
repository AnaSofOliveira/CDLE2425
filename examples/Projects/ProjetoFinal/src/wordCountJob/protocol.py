import struct

class HadoopSequenceFileProtocol(object):
    def read(self, line):
        key_len = struct.unpack('>I', line[:4])[0]
        key = line[4:4 + key_len]
        value_len = struct.unpack('>I', line[4 + key_len:8 + key_len])[0]
        value = line[8 + key_len:8 + key_len + value_len]
        return key, value

    def write(self, key, value):
        #logging.info("------------------ Protocol Key: %s, Value: %s", key, value)
        key_bytes = key.encode('utf-8')
        value_bytes = str(value).encode('utf-8')
        return struct.pack('>I', len(key_bytes)) + key_bytes + struct.pack('>I', len(value_bytes)) + value_bytes