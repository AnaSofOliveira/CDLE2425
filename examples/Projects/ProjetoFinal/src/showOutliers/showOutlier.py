from protocol import HadoopSequenceFileProtocol
from utils import config_logs
from mrjob.job import MRJob

class ShowOutlier(MRJob):

    FILES = ['parameters.json']

    INPUT_PROTOCOL = HadoopSequenceFileProtocol
    OUTPUT_PROTOCOL = HadoopSequenceFileProtocol

    def configure_args(self):
        super(ShowOutlier, self).configure_args()
        self.add_passthru_arg(
            '--log-level', type=str, default='INFO',
            help="Set log level (e.g., DEBUG, INFO, WARNING, ERROR)"
        )
        self.add_passthru_arg('--output-img', help='Directory to save plots')

    def load_args(self, args):
        super(ShowOutlier, self).load_args(args)
        self.logger = config_logs(self.options.log_level)
        self.logger.info(f'[Log level] set to: {self.options.log_level}')
        
    
    def mapper_init(self):
        from biospy_utils import load_json
        self.config = load_json('parameters.json')
        self.start_date = self.config['start_date']
        self.logger.debug(f'[mapper_init] start_date: {self.start_date}')
        self.end_date = self.config['end_date']
        self.logger.debug(f'[mapper_init] end_date: {self.end_date}')
        self.user = self.config['user']
        self.logger.debug(f'[mapper_init] user: {self.user}')
        self.fs = self.config['fs']
        self.logger.debug(f'[mapper_init] fs: {self.fs}')
        self.type = self.config['type']
        self.logger.debug(f'[mapper_init] type: {self.type}')

    def mapper(self, key, line):
        from biospy_utils import filter_value, filter_date
        user, ts , fs , type = key
        self.logger.debug(f'[mapper] key: {key} valid user:{filter_value(self.user, user)}')
        self.logger.debug(f'[mapper] key: {key} valid date:{filter_date(self.start_date, self.end_date, ts)}')
        self.logger.debug(f'[mapper] key: {key} valid fs:{filter_value(self.fs, fs)}')
        self.logger.debug(f'[mapper] key: {key} valid type:{filter_value(self.type, type)}')
        if filter_value(self.user, user) and \
            filter_date(self.start_date, self.end_date, ts) and \
            filter_value(self.fs, fs)and \
            filter_value(self.type, type):
            yield (user, ts , fs, type), line

if __name__ == '__main__':
    ShowOutlier.run()
    