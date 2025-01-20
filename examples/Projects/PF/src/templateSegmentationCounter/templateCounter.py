from protocol import HadoopSequenceFileProtocol
from utils import config_logs

from mrjob.job import MRJob

class TemplateCounter(MRJob):

    INPUT_PROTOCOL = HadoopSequenceFileProtocol

    def configure_args(self):
        super(TemplateCounter, self).configure_args()
        self.add_passthru_arg(
            '--log-level', type=str, default='INFO',
            help="Set log level (e.g., DEBUG, INFO, WARNING, ERROR)"
        )

    def load_args(self, args):
        super(TemplateCounter, self).load_args(args)
        self.logger = config_logs(self.options.log_level)
        self.logger.info(f'[Log level] set to: {self.options.log_level}')

    def mapper(self, key, line):
        user = key[0]
        self.logger.debug(f"[Mapper] received key: {(key)} line: {line}")
        yield user, 1

    def combiner(self, user, counts):
        total = sum(counts)
        self.logger.debug(f"[Combiner] emitting: ({user}, {total})")
        yield user, total
    
    def reducer(self, user, total):
        res = sum(total)
        self.logger.debug(f"[Reducer] received word: {user}, total count: {res}")
        yield user, res

if __name__ == '__main__':
    TemplateCounter.run()
    