import json
import struct

def load_json(file):
    with open(file, 'r') as f:
        return json.load(f)

def print_config(config):
    for key, value in config.items():
        print("{}: {}".format(key, value))


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

        

'''
def steps(self):
    print_config(self.config)
    return [
        MRStep(mapper=self.mapper,
                reducer=self.reducer,
                jobconf={
                'mapreduce.job.reduces': self.config['reducers']
            }
        )
    ]
'''
'''
def steps(self):
    print("jobconf", 'test2')
    print("reducers", self.options.config)
    return [
        MRStep(mapper=self.mapper,
                reducer=self.reducer,
                jobconf={
                'mapreduce.job.reduces': 1
            }
        )
    ]

def jobconf(self):
    print("configure_args", self.options.config)
    home_directory = os.path.expanduser("~")
    print("Home directory:", home_directory)
    #config = load_json(self.options.config)
    #print_config(config)
    return {
        'mapreduce.job.reduces': '1',
        #'stream.num.map.output.key.fields': '1',
        #'mapreduce.output.fileoutputformat.outputformat.class': 'org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat',
        #'mapreduce.input.fileinputformat.split.maxsize': '64'
    }

def jobconf(self):
    print("jobconf", 'test')
    return {
        'mapreduce.job.reduces': '1',
        #'stream.num.map.output.key.fields': '1',
        #'mapreduce.output.fileoutputformat.outputformat.class': 'org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat',
        #'mapreduce.input.fileinputformat.split.maxsize': '64'
    }

def mapper_get_words(self, _, line):
    # Split line into words and yield each word with a count of 1
    for word in line.split():
        yield word.lower(), 1

def reducer_count_words(self, word, counts):
    # Sum all the counts for each word
    yield word, sum(counts)

def reducer_sort(self, _, values): # key was None
    """Sort the words by frequency.
    The ouput will the the word counts,
    starting with the less frequent words (singletons).
    """
    for count, key in sorted(values):
        yield count, key

'''