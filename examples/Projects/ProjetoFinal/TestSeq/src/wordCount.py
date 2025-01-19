from mrjob.job import MRJob
from mrjob.step import MRStep
from mrjob.protocol import BytesValueProtocol, JSONProtocol, RawValueProtocol


class MRWordCount(MRJob):
    NUM_REDUCERS = 3
     
    OUTPUT_PROTOCOL = RawValueProtocol
    #output_protocol = BytesValueProtocol

    def mapper(self, _, line):
        # Split each line into words
        for word in line.split():
            yield word.lower(), 1

    def combiner(self, key, values):
        yield key, sum(values)

    def reducer(self, word, counts):
        # Sum the counts for each word
        yield word, sum(counts)
        #yield None, f"{word}\t{total_count}".encode('utf-8')
    
    def steps(self):
        return [
            MRStep(
                mapper=self.mapper,
                combiner=self.combiner,
                reducer=self.reducer,
                jobconf={
                    'mapred.reduce.tasks': '2' # Set the number of reducers
                }
            )
        ]

if __name__ == "__main__":
    MRWordCount.run()
