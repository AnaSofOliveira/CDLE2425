import re

from protocol import HadoopSequenceFileProtocol
from utils import config_logs

from mrjob.job import MRJob
from mrjob.step import MRStep

WORD_RE = re.compile(r"[\w']+")

class WordCount(MRJob):
    OUTPUT_PROTOCOL = HadoopSequenceFileProtocol

    def configure_args(self):
        super(WordCount, self).configure_args()
        self.add_passthru_arg(
            '--log-level', type=str, default='INFO',
            help="Set log level (e.g., DEBUG, INFO, WARNING, ERROR)"
        )

    def load_args(self, args):
        super(WordCount, self).load_args(args)
        self.logger = config_logs(self.options.log_level)
        self.logger.info(f'Log level set to: {self.options.log_level}')


    def mapper(self, _, line):
        self.logger.debug(f"Mapper received line: {line}")
        for word in WORD_RE.findall(line):
            self.logger.debug(f"Mapper emitting: ({word}, 1)")
            yield word.lower(), 1

    def combiner(self, word, counts):
        total = sum(counts)
        self.logger.debug(f"Combiner received word: {word}, counts: {list(counts)}")
        self.logger.debug(f"Combiner emitting: ({word}, {total})")
        yield word, total
    
    def reducer(self, word, total):
        self.logger.debug(f"Reducer received word: {word}, total count: {total}")
        yield word, sum(total)


    def steps(self):
        return [
            MRStep(mapper=self.mapper,
                   combiner=self.combiner,
                   reducer=self.reducer)
        ]

if __name__ == '__main__':
    WordCount.run()
    