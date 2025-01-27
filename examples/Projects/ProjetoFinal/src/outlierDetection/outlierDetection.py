from protocol import HadoopSequenceFileProtocol
from utils import config_logs

from mrjob.job import MRJob

class OutlierDetection(MRJob):

    FILES = ['parameters.json']

    INPUT_PROTOCOL = HadoopSequenceFileProtocol
    OUTPUT_PROTOCOL = HadoopSequenceFileProtocol

    def configure_args(self):
        super(OutlierDetection, self).configure_args()
        self.add_passthru_arg(
            '--log-level', type=str, default='INFO',
            help="Set log level (e.g., DEBUG, INFO, WARNING, ERROR)"
        )

    def load_args(self, args):
        super(OutlierDetection, self).load_args(args)
        self.logger = config_logs(self.options.log_level)
        self.logger.info(f'[Log level] set to: {self.options.log_level}')

    def mapper(self, key, line):
        user, ts , fs , id = key
        yield (user, ts, fs), line

    def reducer_init(self):
        from biospy_utils import load_json
        self.config = load_json('parameters.json')
        self.alpha = self.config['alpha']
        self.logger.info(f'[mapper_init] alpha: {self.alpha}')
        self.beta = self.config['beta']
        self.logger.info(f'[mapper_init] beta: {self.beta}')

    def reducer(self, key, values):
        from biospy_utils import outlier_detection_dmean
        user, ts, fs = key
        temps = list(values)
        temp, out = outlier_detection_dmean(temps, self.alpha, self.beta)
        yield (user, ts, fs, 'temp'), temp
        yield (user, ts, fs, 'out'), out


if __name__ == '__main__':
    OutlierDetection.run()
    