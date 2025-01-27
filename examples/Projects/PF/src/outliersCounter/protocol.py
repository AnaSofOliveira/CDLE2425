import json

class HadoopSequenceFileProtocol(object):

    def read(self, line):
        """Deserialize a line into a key-value pair."""
        key, value = line.split(b'\t', 1)
        key = json.loads(key.decode('utf-8'))
        #key = eval(json.loads(key.decode('utf-8')))
        value = json.loads(value.decode('utf-8'))
        return key, value

    def write(self, key, value):
        """Serialize a key-value pair into a line."""
        key = json.dumps(key).encode('utf-8')
        value = json.dumps(value).encode('utf-8')
        return key + b'\t' + value