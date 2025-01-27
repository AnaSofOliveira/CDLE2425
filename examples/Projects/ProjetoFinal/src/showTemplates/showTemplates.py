from protocol import HadoopSequenceFileProtocol
from utils import config_logs
#import matplotlib.pyplot as plt
#import numpy as np
#import io
#import base64
from mrjob.job import MRJob

class ShowTemplates(MRJob):

    FILES = ['parameters.json']

    INPUT_PROTOCOL = HadoopSequenceFileProtocol
    INPUT_SPLITTING = True

    def configure_args(self):
        super(ShowTemplates, self).configure_args()
        self.add_passthru_arg(
            '--log-level', type=str, default='INFO',
            help="Set log level (e.g., DEBUG, INFO, WARNING, ERROR)"
        )
        self.add_passthru_arg('--output-img', help='Directory to save plots')

    def load_args(self, args):
        super(ShowTemplates, self).load_args(args)
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

    def mapper(self, key, line):
        from biospy_utils import filter_value, filter_date
        user, ts , fs , id = key
        self.logger.debug(f'[mapper] key: {key} valid user:{filter_value(self.user, user)}')
        self.logger.debug(f'[mapper] key: {key} valid date:{filter_date(self.start_date, self.end_date, ts)}')
        self.logger.debug(f'[mapper] key: {key} valid fs:{filter_value(self.fs, fs)}')
        if filter_value(self.user, user) and \
            filter_date(self.start_date, self.end_date, ts) and \
            filter_value(self.fs, fs):
            yield (user, ts , fs), line

    def reducer(self, key, values):
        yield key, list(values)

    '''
    def reducer(self, key, values):
        user, ts = key
        temps = np.array(list(values)[0])
        self.logger.debug(f'[reducer] key: {key} values {temps}')
        plt.figure(f'{user}_{ts}')
        plt.plot(temps.T)
        plt.title('Templates person {}'.format(user))

        #self.logger.info(f'reducer output_dir: {self.options.output_img}')
        #self.logger.info(f'reducer options: {self.options}')
        buffer = io.BytesIO()
        plt.savefig(buffer, format="png")
        buffer.seek(0) 
        #output_dir = self.options.output_img
        #os.makedirs(output_dir, exist_ok=True)
        #output_file = os.path.join(output_dir, f'{user}.png')
        #plt.savefig(output_file)
        encoded_image = base64.b64encode(buffer.read()).decode('utf-8')
        buffer.close()
        plt.close()

        yield key, encoded_image
    '''

if __name__ == '__main__':
    ShowTemplates.run()
    