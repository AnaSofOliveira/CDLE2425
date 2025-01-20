from protocol import HadoopSequenceFileProtocol
from utils import config_logs

from mrjob.job import MRJob

class OutliersCounter(MRJob):

    INPUT_PROTOCOL = HadoopSequenceFileProtocol
    INPUT_SPLITTING = True

    def configure_args(self):
        super(OutliersCounter, self).configure_args()
        self.add_passthru_arg(
            '--log-level', type=str, default='INFO',
            help="Set log level (e.g., DEBUG, INFO, WARNING, ERROR)"
        )

    def load_args(self, args):
        super(OutliersCounter, self).load_args(args)
        self.logger = config_logs(self.options.log_level)
        self.logger.info(f'Log level set to: {self.options.log_level}')

    def mapper(self, key, line):
        user = key[0]
        out = key[3]
        self.logger.debug(f"[Mapper] received key: {(key)} line: {line}")
        yield (user, out), len(line)

    def combiner(self, key, counts):
        total = sum(counts)
        self.logger.debug(f"[Combiner] emitting: ({key}, {total})")
        yield key, total
    
    def reducer(self, key, total):
        res = sum(total)
        self.logger.debug(f"[Reducer] received word: {key}, total count: {res}")
        yield key, res

if __name__ == '__main__':
    OutliersCounter.run()
    